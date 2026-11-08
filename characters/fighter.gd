class_name Fighter
extends CharacterBody2D
## Base class for every playable character.
##
## Holds everything characters have in common: bookkeeping (frames, hit pause,
## damage, stocks), hitbox/grabbox/projectile creation, turning, and the
## tuning values. A character script extends this and provides:
##   * its move set: override the upper-case functions (NAIR, FAIR, GRAB, ...).
##     They run once per frame while the move is active and return true on
##     the frame the move is over.
##   * `projectile_scene` plus `_projectile_spawn_position()` if it has a
##     projectile for its neutral special.
##   * any tuning that differs from the defaults below, set in the scene's
##     Inspector (everything under "Movement" / "Jumps" / ... is exported).
## The matching state machine (see FighterStateMachine) drives the states.

var frame = 0
@export var id: int

#buffers
var shield_buffer = 0
var cooldown = 0

#attributes
@export_group("Stats")
@export var percentage = 0
@export var stocks = 3
@export var weight = 100

@export_group("Ground movement")
@export var walk_speed: float = 200*2
@export var dash_speed: float = 390*2
@export var run_speed: float = 450*2
## Deceleration per frame on the ground. Higher stops faster.
@export var traction: float = 80
@export var roll_distance: float = 500*2

@export_group("Jumps")
@export var jump_force: float = 1000
@export var max_jump_force: float = 1700
@export var double_jump_force: float = 1700
## Number of midair jumps. 1 = a standard double jump.
@export var air_jumps: int = 1

@export_group("Air movement")
@export var gravity: float = 1800
@export var max_air_speed: float = 300*2
@export var air_accel: float = 60
@export var fall_speed: float = 80
@export var falling_speed: float = 900*2
@export var max_fall_speed: float = 900*2
@export var air_dodge_speed: float = 700*5
@export var up_b_launch_speed: float = 700*2
@export_group("")

#knockback
var hdecay
var vdecay
var knockback
var hitstun
var connected:bool

#Ground variables
var dash_duration = 5
var jump_squat = 3
var landing_frames = 0
var lag_frames = 0
var fastfall = false

#Temporary_Variables
var hit_pause = 0
var hit_pause_dur = 0
var temp_pos = Vector2(0,0)
var temp_vel = Vector2(0,0)
var freezeframes = 0

#attacks
var projectile_cooldown = 0
var grabbing = false
var throwDir = "u"
var special = true

#Ledge
var last_ledge = false
var regrab = 30
var catch = false
var airJump = 0

#hitboxes / projectiles
@export var hitbox: PackedScene = load('res://hitbox/hitbox.tscn')
@export var grabbox: PackedScene = load('res://hitbox/grabbox.tscn')
## Scene spawned by create_projectile(). Needs player_list and dir(x, y).
@export var projectile_scene: PackedScene
var selfState

#onready variables
@onready var hurtbox = $Hurtbox/Hurtbox_shape
@onready var GroundL = get_node('RayCasts/GroundL')
@onready var GroundR = get_node('RayCasts/GroundR')
@onready var Ledge_Grab_F = get_node('RayCasts/Ledge_Grab_F')
@onready var Ledge_Grab_B = get_node('RayCasts/Ledge_Grab_B')
@onready var state = $State
@onready var anim = $Sprite/AnimationPlayer
@onready var sprite = $Sprite


func create_hitbox(width, height, damage, angle, base_kb, kb_scaling, duration, type, points, angle_flipper, hitlag = 1):
	var hitbox_instance = hitbox.instantiate()
	self.add_child(hitbox_instance)
	if direction() == 1:
		hitbox_instance.set_parameters(width, height, damage, angle, base_kb, kb_scaling, duration, type, points, hitlag, angle_flipper)
	else:
		var flip_x_points = Vector2(-points.x, points.y)
		hitbox_instance.set_parameters(width, height, damage,-angle+180,base_kb, kb_scaling, duration, type, flip_x_points, hitlag, angle_flipper)
	return hitbox_instance

func create_projectile(dir_x,dir_y,point):
	var projectile_instance = projectile_scene.instantiate()
	projectile_instance.player_list.append(self)
	get_parent().add_child(projectile_instance)
	if direction() == 1:
		projectile_instance.dir(dir_x,dir_y)
	else:
		projectile_instance.dir(-(dir_x),dir_y)
	projectile_instance.set_global_position(_projectile_spawn_position(point))
	return projectile_instance

## Where a projectile appears. `point` is the move's requested offset from
## the character, already facing right; flip it with direction() as needed.
func _projectile_spawn_position(point) -> Vector2:
	return global_position + Vector2(point.x * direction(), point.y)

func create_grabbox(width, height, damage, duration, points):
	var grabbox_instance = grabbox.instantiate()
	self.add_child(grabbox_instance)
	if direction() == 1:
		grabbox_instance.set_parameters(width, height, damage, duration, points)
	else:
		var flip_x_points = Vector2(-points.x, points.y)
		grabbox_instance.set_parameters(width, height, damage, duration, flip_x_points)
	return grabbox_instance

func _hit_pause(delta):
	if hit_pause < hit_pause_dur:
		self.position = temp_pos
		hit_pause += floor((1 * delta) * 60)
	else:
		if temp_vel != Vector2(0,0):
			self.velocity.x = temp_vel.x
			self.velocity.y = temp_vel.y
			temp_vel = Vector2(0,0)
		hit_pause_dur = 0
		hit_pause = 0

func updateframes(delta):
	frame += floor(delta*60)
	if Input.is_action_pressed("shield_%s" % id):
		shield_buffer = 0
	else:
		shield_buffer += floor(delta*60)
	if freezeframes > 0:
		freezeframes -= floor(delta*60)
	freezeframes = clamp(freezeframes,0,freezeframes)

func turn(direction):
	var dir = 0
	if direction:
		dir = -1
	else:
		dir = 1
	$Sprite.set_flip_h(direction)
	Ledge_Grab_F.set_target_position(Vector2(dir*abs(Ledge_Grab_F.get_target_position().x),Ledge_Grab_F.get_target_position().y))
	Ledge_Grab_F.position.x = dir * abs(Ledge_Grab_F.position.x)
	Ledge_Grab_B.position.x = dir * abs(Ledge_Grab_B.position.x)
	Ledge_Grab_B.set_target_position(Vector2(-dir*abs(Ledge_Grab_B.get_target_position().x),Ledge_Grab_B.get_target_position().y))
	_on_turn(dir)

## Called at the end of turn() with -1 (now facing left) or 1 (facing right).
## Override to mirror character-specific nodes.
func _on_turn(_dir):
	pass

## 1 when facing right, -1 when facing left.
func direction():
	if Ledge_Grab_F.get_target_position().x > 0:
		return 1
	else:
		return -1

func newframe():
	frame = 0

func reset_jumps():
	special = true
	airJump = air_jumps

func play_animation(animation_name):
	anim.play(animation_name)

func reset_ledge():
	last_ledge = false

## Slows the fighter down horizontally; `coeff` scales the `traction` stat.
func apply_traction(coeff):
	if velocity.x > 0:
		velocity.x += -traction*coeff
		velocity.x = clampf(velocity.x,0,velocity.x)
	elif velocity.x < 0:
		velocity.x += traction*coeff
		velocity.x = clampf(velocity.x,velocity.x,0)

func _physics_process(delta):
	$Frames.text = str(frame)
	$Percent.text = str(percentage)
	if position.x > 2100 or position.x < -2100 or position.y > 1500 or position.y < -1500:
		position.x = 0
		position.y = 0
		percentage = 0
		stocks -= 1
		velocity.x = 0
		velocity.y = 0
		hdecay = 0
		vdecay = 0
		knockback = 0
		hitstun = 0
	if cooldown > 0:
		cooldown -= 1
	_physics_extra()
	selfState = state.text

## Extra per-frame work for a character (e.g. ticking its own cooldowns).
func _physics_extra():
	pass

# ---------------------------------------------------------------------------
# Move set. Override these in a character. They are called every frame while
# the move is active (`frame` counts up from 0) and must return true on the
# frame the move ends. A character without a move simply ends it immediately.
# ---------------------------------------------------------------------------
func GRAB(): return true
func THROW(): return true
func DASH_ATTACK(): return true
func STRONG_DASH_ATTACK(): return true
func DOWN_TILT(): return true
func UP_TILT(): return true
func FORWARD_TILT(): return true
func FORWARD_SMASH(): return true
func DOWN_SMASH(): return true
func UP_SMASH(): return true
func NAIR(): return true
func UAIR(): return true
func BAIR(): return true
func FAIR(): return true
func DAIR(): return true
func DAIR_LANDING(): return true
func UP_SPECIAL(): return true
func NEUTRAL_SPECIAL(): return true
