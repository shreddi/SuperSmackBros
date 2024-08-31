extends CharacterBody2D

var frame = 0
@export var id: int

#buffers
var shield_buffer = 0
var cooldown = 0

#attributes
@export var percentage = 0
@export var stocks = 3
@export var weight = 100

#knockback
var hdecay
var vdecay
var knockback
var hitstun
var connected:bool

#var temp_vel = Vector2(0,0)
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

#hitboxes
@export var hitbox: PackedScene = load('res://Hitbox/hitbox.tscn')
@export var fox_laser: PackedScene = load('res://Characters/Fox/fox_laser.tscn')
@export var grabbox: PackedScene = load('res://Hitbox/grabbox.tscn')
var selfState

#onready variables
@onready var hurtbox = $Hurtbox/Hurtbox_shape
@onready var GroundL = get_node('RayCasts/GroundL')
@onready var GroundR = get_node('RayCasts/GroundR')
@onready var Ledge_Grab_F = get_node('RayCasts/Ledge_Grab_F')
@onready var Ledge_Grab_B = get_node('RayCasts/Ledge_Grab_B')
@onready var state = $State
@onready var anim = $Sprite/AnimationPlayer
@onready var gun_pos = $gun_pos

#Attributes
var RUNSPEED = 450*2
var DASHSPEED = 390*2
var WALKSPEED = 200*2
var GRAVITY = 1800*1
var JUMPFORCE = 1000
var MAX_JUMPFORCE = 1700
var DOUBLEJUMPFORCE = 1700
var MAXAIRSPEED = 300*2
var AIR_ACCEL = 60
var FALLSPEED = 80
var FALLINGSPEED = 900*2
var MAXFALLSPEED = 900*2
var TRACTION = 80
var ROLL_DISTANCE = 500*2
var air_dodge_speed = 700*5
var UP_B_LAUNCHSPEED = 700*2
var AIRJUMPS = 1

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
	var projectile_instance = fox_laser.instantiate()
	projectile_instance.player_list.append(self)
	get_parent().add_child(projectile_instance)
	gun_pos.set_position(point)
	if direction() == 1:
		projectile_instance.dir(dir_x,dir_y)
		projectile_instance.set_global_position(gun_pos.get_global_position())
	else:
		gun_pos.position.x = -gun_pos.position.x
		projectile_instance.dir(-(dir_x),dir_y)
		projectile_instance.set_global_position(gun_pos.get_global_position())
	return projectile_instance
	
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

func direction(): 
	if Ledge_Grab_F.get_target_position().x > 0:
		return 1 
	else:
		return -1
		
		
func newframe():
	frame = 0
	
func reset_jumps():
	special = true
	airJump = AIRJUMPS

func play_animation(animation_name):
	anim.play(animation_name)

func reset_ledge():
	last_ledge = false
	
func traction(coeff):
	if velocity.x > 0:
			velocity.x += -TRACTION*coeff
			velocity.x = clampf(velocity.x,0,velocity.x)
	elif velocity.x < 0:
		velocity.x += TRACTION*coeff
		velocity.x = clampf(velocity.x,velocity.x,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _physics_process(delta):
	#print(id)
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
	selfState = state.text
	
func GRAB():
	if frame == 2:
		create_grabbox(30,40,0,3,Vector2(64,0))
	if frame == 5:
		if grabbing == true:
			return false
	if frame > 20:
		return true
	
func THROW():
	if frame == 12:
		if throwDir == "u":
			create_hitbox(40,20,8,90,3000,50,9,'normal',Vector2(64,0),0,0)
		if throwDir == "f":
			create_hitbox(40,20,8,45,3000,50,9,'normal',Vector2(64,0),0,0)
		if throwDir == "b":
			create_hitbox(40,20,8,135,3000,50,9,'normal',Vector2(64,0),0,0)
		if throwDir == "d":
			create_hitbox(40,20,8,20,2000,50,9,'normal',Vector2(64,0),0,0)
	if frame == 32:
		return true
		
func DASH_ATTACK():
	if frame == 3:
		velocity.y -= 200
		if velocity.x > 0:
			velocity.x += 600
		elif velocity.x < 0:
			velocity.x -= 600
	elif frame >= 3:
		velocity.y += 20
		if velocity.x > 0:
			velocity.x -= 25
		elif velocity.x < 0:
			velocity.x += 25
	if frame == 4:
		create_hitbox(80, 80, 8, 70, 100, 130, 2, 'normal', Vector2(0,0), 0)
	if frame == 6:
		create_hitbox(60, 60, 8, 80, 100, 90, 10, 'normal', Vector2(30,0), 0)
	if frame == 30:
		return true

func STRONG_DASH_ATTACK():
	var start = 25
	var end = 35
	if frame == start:
		if self.direction() == 1:
			self.velocity.x += 2000
		else:
			self.velocity.x -= 2000
		create_hitbox(60, 60, 15, 270, 100, 110, start-end, 'normal', Vector2(30,0), 0)
	if frame == end:
		self.velocity.x = 0
	if frame == end + 10:
		return true
		
#TILTS
func DOWN_TILT():
	var width = 60
	var height = 40
	var damage = 8
	var angle = 90
	var base_kb = 3
	var kb_scaling = 100
	var duration = 3
	var type = 'normal'
	var points = Vector2(64,40)
	var angle_flipper = 0
	if frame == 5:
		create_hitbox(width, height, damage, angle, base_kb, kb_scaling, duration, type, points, angle_flipper)
	if frame >= 20:
		return true
func UP_TILT():
	if frame == 3:
		#create_hitbox(width, height, damage, angle, base_kb, kb_scaling, duration, type, points, angle_flipper)
		create_hitbox(80, 150, 8, 80, 5, 100, 3, 'normal', Vector2(-50,0), 0)
	if frame >= 23:
		return true
func FORWARD_TILT():
	if frame == 4:
		#create_hitbox(w,h,dam,ang,bkb,kbs,dur, type, points, angle_flipper)
		create_hitbox(60, 30, 7, 20, 3, 90, 2, 'normal', Vector2(41,3), 0)
	if frame >= 12:
		return true
		
func FORWARD_SMASH():
	var start = 13
	var duration = 4
	var endlag = 30
	if frame < start:
		traction(3)
	if frame == start:
		velocity.x+=600*direction()
		velocity.y-=200
		create_hitbox(100,100,16,40,50,100,duration,'normal',Vector2(20,0),0)
	if frame > start:
		#if(direction):
			#velocity.x = clampf(velocity.x,velocity.x,0)
		#else:
			#velocity.x = clampf(velocity.x,0,velocity.x)
		velocity.x -= 18*direction()
		velocity.y += 30
	if frame == start+duration+endlag:
		return true
	
func DOWN_SMASH():
	var start = 6
	var duration = 2
	var endlag = 45
	if frame >= 1:
		traction(3)
	if frame == start:
		create_hitbox(70,50,14,30,100,100,duration,'normal',Vector2(60,30),0)
		create_hitbox(70,50,14,150,100,100,duration,'normal',Vector2(-60,30),0)
	if frame == start + duration + endlag:
		return true
		
func UP_SMASH():
	var start = 20
	var duration = 42
	var endlag = 20
	var height = -30
	if frame == 22:
		create_hitbox(100,100,14,90,300,95,3,'normal',Vector2(0,height),0)
	if frame == 37:
		create_hitbox(120,120,15,90,300,100,3,'normal',Vector2(0,height),0)
	if frame == 52:
		create_hitbox(140,140,16,90,300,105,3,'normal',Vector2(0,height),0)
	if frame == start + duration + endlag:
		return true
		
	
		
		
		
	
#Air attacks
func NAIR():
	if frame == 1:
		pass
	if frame == 5:
		create_hitbox(90,70,12,30,1,70,3,'normal',Vector2(20,10),0,0)
	if frame == 8:
		create_hitbox(60,40,5,30,0,60,27,'normal',Vector2(20,10),0,0)
	if frame == 36:
		return true 

func UAIR():
	var start1 = 8
	var start2 = start1 + 4
	var endlag = 20
	var size1 = 70
	if frame == start1:
		create_hitbox(size1,size1,5,90,130,0,2,'normal',Vector2(0,-45),0,1)
	if frame == start2:
		create_hitbox(size1+10,size1+10,10,90,20,108,3,'normal',Vector2(0,-48),0,2)
	if frame == start2+endlag:
		return true 

func BAIR():
	var start = 8
	var duration = 2
	var endlag = 20
	var end = start + duration + endlag
	if frame == start:
		create_hitbox(100,80,15,135,1,100,duration,'normal',Vector2(-60,7),0,1)
	if frame == end:
		return true

func FAIR():
	var start = 6
	if frame == start:
		create_hitbox(35,47,3,76,10,150,3,'normal',Vector2(60,-7),0,1)
	if frame == start + 9:
		create_hitbox(35,47,3,76,10,150,3,'normal',Vector2(60,-7),0,1)
	if frame == start + 18:
		return true 

func DAIR():
	var angle = velocity.angle()*180/PI 
	var centerx = 0
	var centery = 50
	var width = 100
	var scale = 4000
	var start = 7
	var duration = 8
	if angle > 0:
		angle * -1
	else :
		angle += 180
	if frame > start and frame < start+duration:
		if int(frame) % 2 == 0:
			#create_hitbox(100,100,2,angle,4000,0,2,'normal',Vectora2(0,0),0,0)
			create_hitbox(width/2,width/2,0.3,(135),3000,0,1,'normal',Vector2(centerx+width/4,centery+width/4),0,0)
			create_hitbox(width/2,width/2,0.3,(225),3000,0,1,'normal',Vector2(centerx+width/4,centery-width/4),0,0)
			create_hitbox(width/2,width/2,0.3,(45),3000,0,1,'normal',Vector2(centerx-width/4,centery+width/4),0,0)
			create_hitbox(width/2,width/2,0.3,(315),3000,0,1,'normal',Vector2(centerx-width/4,centery-width/4),0,0)
		else:
			create_hitbox(width,width,1,angle,velocity.length()*4,0,1,'normal',Vector2(centerx,centery),0,0)
	if frame == start+duration:
		create_hitbox(width+5,width+5,5,270,100,150,2,'normal',Vector2(centerx,centery),0,0)
	if frame == start+duration+8:
		return true


func DAIR_LANDING():
	if frame == 2:
		create_hitbox(70,70,2,50,300,100,2,'normal',Vector2(0,30),0,1)
	if frame == 17:
		return true







func UP_SPECIAL():
	special = false
	var start = 5
	var trans1 = 60
	var end = 90
	#if abs(velocity.x)==abs(velocity.y):
		#velocity.x = velocity.x/1.15
		#velocity.y = velocity.y/1.15
	if frame > 5 and frame < trans1:
		velocity.y = 0
		velocity.x = 0
	if frame == trans1:
		#var deadzone = (Input.get_action_strength("right_%s" % id)-Input.get_action_strength("left_%s" % id) in range(-0.2,1.2) and Input.get_action_strength("up_%s" % id)-Input.get_action_strength("down_%s" % id) in range(-0.2,1.2))
		#var direction = Vector2(Input.is_action_pressed("right_%s" % id)-Input.is_action_pressed("left_%s" % id),Input.is_action_pressed("down_%s" % id)-Input.is_action_pressed("up_%s" % id))
		var direction = Vector2(0, 0)

		if Input.is_action_pressed("right_%s" % id):
			direction.x += 1
		if Input.is_action_pressed("left_%s" % id):
			direction.x -= 1
		if Input.is_action_pressed("up_%s" % id):
			direction.y -= 1
		if Input.is_action_pressed("down_%s" % id):
			direction.y += 1

		if direction.length() > 0:
			direction = direction.normalized()

		velocity = 1750 * direction
		print(velocity)
		
	if frame == end:
		return true

# Special Attacks
func NEUTRAL_SPECIAL():
	if frame == 4:
		create_projectile(1,0,Vector2(50,0))
	if frame == 14:
		return true

