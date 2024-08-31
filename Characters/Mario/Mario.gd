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
var projectile_cooldown = 30
var grabbing = false
var throwDir = "u"

#Ledge
var last_ledge = false
var regrab = 30
var catch = false
var airJump = 0
var special = false

#hitboxes
@export var hitbox: PackedScene = load('res://Hitbox/hitbox.tscn')
@export var fox_laser: PackedScene = load('res://Characters/Mario/fireball/fireball.tscn')
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
@onready var hand_pos = $hand

#Attributes
var RUNSPEED = 340*2
var DASHSPEED = 390*2
var WALKSPEED = 200*2
var GRAVITY = 1800*1
var JUMPFORCE = 800
var MAX_JUMPFORCE = 1300
var DOUBLEJUMPFORCE = 1300
var MAXAIRSPEED = 300*1.5
var AIR_ACCEL = 50
var FALLSPEED = 60
var FALLINGSPEED = 1800
var MAXFALLSPEED = 1800
var TRACTION = 80
var ROLL_DISTANCE = 350*3
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
	if direction() == 1:
		projectile_instance.dir(dir_x,dir_y)
		projectile_instance.set_global_position(self.position+Vector2(100,0))
	else:
		projectile_instance.dir(-(dir_x),dir_y)
		projectile_instance.set_global_position(self.position+Vector2(-100,0))
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
	hand_pos.position.x = dir*hand_pos.position.x
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
	airJump = AIRJUMPS
	special = true

func play_animation(animation_name):
	anim.play(animation_name)
	#if(anim.finished == true):
		#anim.stop()

func reset_ledge():
	last_ledge = false

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
	projectile_cooldown -= 1
	selfState = state.text
	
	
	
	
	
	
	
	
func GRAB():
	if frame == 2:
		create_grabbox(100,30,0,3,Vector2(40,0))
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
		
#TILTS
func DOWN_TILT():
	var width = 120
	var height = 70
	var damage = 8
	var angle = 90
	var base_kb = 3
	var kb_scaling = 100
	var duration = 3
	var type = 'normal'
	var points = Vector2(80,40)
	var angle_flipper = 0
	if frame == 5:
		create_hitbox(width, height, damage, angle, base_kb, kb_scaling, duration, type, points, angle_flipper)
	if frame >= 20:
		return true
func UP_TILT():
	if frame == 7:
		create_hitbox(120,60,5,100,10,120,1,'normal',Vector2(-70,-20),0)
	if frame == 8:
		create_hitbox(70,70,5,70,10,120,1,'normal',Vector2(-137,-137),0)
		create_hitbox(70,70,5,100,10,120,1,'normal',Vector2(-90,-90),0)
	if frame == 9:
		create_hitbox(70,150,5,70,10,120,1,'normal',Vector2(0,-137),0)
	if frame == 10:
		create_hitbox(70,70,5,45,10,120,1,'normal',Vector2(120,-100),0)
		create_hitbox(70,70,5,45,10,120,1,'normal',Vector2(70,-50),0)
		
	if frame >= 40:
		return true
		
func FORWARD_TILT():
	if frame == 6:
		#create_hitbox(w,h,dam,ang,bkb,kbs,dur, type, points, angle_flipper)
		create_hitbox(140, 30, 7, 20, 3, 90, 2, 'normal', Vector2(80,0), 0)
	if frame >= 35:
		return true
		
		
		
		
		

func UP_SMASH():
	var centerx = 60
	var centery = -250
	var width = 130
	if frame == 10:
		pass
		create_hitbox(70, 150, 1, 90, 5000, 0, 3, 'normal', Vector2(50,-30), 0)
	if frame == 13:
		create_hitbox(70, 150, 1, 90, 5000, 0, 3, 'normal', Vector2(50, -80), 0)
	if frame > 16 and frame < 64:
		if int(frame) % 6 == 0:
			#create_hitbox(150,150,2,30,3000,0,2,'normal',Vector2(50,-250),0,0)
			create_hitbox(width/2,width/2,0.3,135,3000,0,1,'normal',Vector2(centerx+width/4,centery+width/4),0,0)
			create_hitbox(width/2,width/2,0.3,225,3000,0,1,'normal',Vector2(centerx+width/4,centery-width/4),0,0)
			create_hitbox(width/2,width/2,0.3,45,3000,0,1,'normal',Vector2(centerx-width/4,centery+width/4),0,0)
			create_hitbox(width/2,width/2,0.3,315,3000,0,1,'normal',Vector2(centerx-width/4,centery-width/4),0,0)
	if frame == 64:
		create_hitbox(150,150,10,80,1000,100,3,'normal',Vector2(centerx,centery),0,1)
	if frame >= 94:
		return true
		
func FORWARD_SMASH():
	var centerx = 260
	var centery = 25
	var width = 130
	var start = 15
	if frame == start:
		create_hitbox(100, 70, 1, 10, 5000, 0, 3, 'normal', Vector2(100, 24), 0)
	if frame == start+3:
		create_hitbox(100, 70, 1, 10, 3000, 0, 3, 'normal', Vector2(180, 24), 0)
	if frame > start+6 and frame < start+63:
		if int(frame) % 6 == 0:
			#create_hitbox(150,150,2,30,3000,0,2,'normal',Vector2(50,-250),0,0)
			create_hitbox(width/2,width/2,0.3,135,3000,0,1,'normal',Vector2(centerx+width/4,centery+width/4),0,0)
			create_hitbox(width/2,width/2,0.3,225,3000,0,1,'normal',Vector2(centerx+width/4,centery-width/4),0,0)
			create_hitbox(width/2,width/2,0.3,45,3000,0,1,'normal',Vector2(centerx-width/4,centery+width/4),0,0)
			create_hitbox(width/2,width/2,0.3,315,3000,0,1,'normal',Vector2(centerx-width/4,centery-width/4),0,0)
	if frame == start+63:
		create_hitbox(150,150,10,80,1000,100,3,'normal',Vector2(centerx,centery),0,1)		
	if frame >= start+97:
		return true
		
func DOWN_SMASH():
	var size = 75
	var start = 15
	var angle = 60
	var damage = 13
	var base_kb = 1000
	var kb_scaling = 90
	var inc = 3
	#var knockback = 
	if frame == start:
		create_hitbox(size,size,damage,angle,base_kb,kb_scaling,1,'normal',Vector2(75,55),0,1)
	elif frame == (start + inc):
		create_hitbox(size,size,damage,angle,base_kb,kb_scaling,1,'normal',Vector2(150,33),0,1)
	elif frame == start + 2*inc:
		create_hitbox(size,size,damage,angle,base_kb,kb_scaling,1,'normal',Vector2(90,6),0,1)	
	
	elif frame == start + 3*inc:
		create_hitbox(size,size,damage,180-angle,base_kb,kb_scaling,1,'normal',Vector2(-90,10),0,1)
	elif frame == start + 4*inc:
		create_hitbox(size,size,damage,180-angle,base_kb,kb_scaling,1,'normal',Vector2(-150,25),0,1)
	elif frame == start + 5*inc:
		create_hitbox(size,size,damage,180-angle,base_kb,kb_scaling,1,'normal',Vector2(-80,80),0,1)
	
	elif frame == start + 6*inc:
		create_hitbox(size,size,damage,angle,base_kb,kb_scaling,1,'normal',Vector2(90,80),0,1)
	elif frame == start + 7*inc:
		create_hitbox(size,size,damage,angle,base_kb,kb_scaling,1,'normal',Vector2(200,34),0,1)
	elif frame == start + 8*inc:
		create_hitbox(size,size,damage,angle,base_kb,kb_scaling,1,'normal',Vector2(100,-15),0,1)
	
	elif frame == start + 9*inc:
		create_hitbox(size,size,damage,180-angle,base_kb,kb_scaling,1,'normal',Vector2(-100,-7),0,1)
	elif frame == start + 10*inc:
		create_hitbox(size,size,damage,180-angle,base_kb,kb_scaling,1,'normal',Vector2(-175,28),0,1)
	elif frame == start + 11*inc:
		create_hitbox(size,size,damage,180-angle,base_kb,kb_scaling,1,'normal',Vector2(-91,85),0,1)
	
	elif frame == start + 12*inc:
		create_hitbox(size,size,damage,angle,base_kb,kb_scaling,1,'normal',Vector2(109,96),0,1)
	elif frame == start + 13*inc:
		create_hitbox(size,size,damage,angle,base_kb,kb_scaling,1,'normal',Vector2(239,38),0,1)
	elif frame == start + 14*inc:
		create_hitbox(size,size,damage,angle,base_kb,kb_scaling,1,'normal',Vector2(128,-23),0,1)
		
	elif frame == start + 15*inc:
		create_hitbox(size,size,damage,180-angle,base_kb,kb_scaling,1,'normal',Vector2(-120,-16),0,1)
	elif frame == start + 16*inc:
		create_hitbox(size,size,damage,180-angle,base_kb,kb_scaling,1,'normal',Vector2(-195,23),0,1)
	elif frame == start + 17*inc: #54
		create_hitbox(size,size,damage,180-angle,base_kb,kb_scaling,1,'normal',Vector2(-84,95),0,1)
	elif frame >= 90:
		return true
		
		
		
		
		
		
		
#Air attacks
func NAIR():
		
	var angle = velocity.angle()*180/PI 
	var centerx = 0
	var centery = 0
	var width = 100
	var scale = 4000
	if angle > 0:
		angle * -1
	else :
		angle += 180
	if frame > 4 and frame < 27:
		if int(frame) % 2 == 0:
			#create_hitbox(100,100,2,angle,4000,0,2,'normal',Vectora2(0,0),0,0)
			create_hitbox(width/2,width/2,0.2,(135),3000,0,1,'normal',Vector2(centerx+width/4,centery+width/4),0,0)
			create_hitbox(width/2,width/2,0.2,(225),3000,0,1,'normal',Vector2(centerx+width/4,centery-width/4),0,0)
			create_hitbox(width/2,width/2,0.2,(45),3000,0,1,'normal',Vector2(centerx-width/4,centery+width/4),0,0)
			create_hitbox(width/2,width/2,0.2,(315),3000,0,1,'normal',Vector2(centerx-width/4,centery-width/4),0,0)
		else:
			create_hitbox(width,width,0.2,angle,velocity.length()*4,0,1,'normal',Vector2(centerx,centery),0,0)			
		#create_hitbox(width,width,0.1,angle,velocity.length()*4,0,1,'normal',Vector2(centerx,centery),0,0)				
		#if angle >= 0 and angle < 90:
			#create_hitbox(width/2,width/2,0.1,(135),scale/2,0,1,'normal',Vector2(centerx+width/4,centery+width/4),0,0)
			#create_hitbox(width/2,width/2,0.1,(225),scale/4,0,1,'normal',Vector2(centerx+width/4,centery-width/4),0,0)
			#create_hitbox(width/2,width/2,0.1,(45),scale,0,1,'normal',Vector2(centerx-width/4,centery+width/4),0,0)
			#create_hitbox(width/2,width/2,0.1,(315),scale/2,0,1,'normal',Vector2(centerx-width/4,centery-width/4),0,0)
		#if angle >= 90 and angle < 180:
			#create_hitbox(width/2,width/2,0.1,(135),scale,0,1,'normal',Vector2(centerx+width/4,centery+width/4),0,0)
			#create_hitbox(width/2,width/2,0.1,(225),scale/2,0,1,'normal',Vector2(centerx+width/4,centery-width/4),0,0)
			#create_hitbox(width/2,width/2,0.1,(45),scale/2,0,1,'normal',Vector2(centerx-width/4,centery+width/4),0,0)
			#create_hitbox(width/2,width/2,0.1,(315),scale/4,0,1,'normal',Vector2(centerx-width/4,centery-width/4),0,0)
		#if angle >= 180 and angle < 270:
			#create_hitbox(width/2,width/2,0.1,(135),scale/2,0,1,'normal',Vector2(centerx+width/4,centery+width/4),0,0)
			#create_hitbox(width/2,width/2,0.1,(225),scale,0,1,'normal',Vector2(centerx+width/4,centery-width/4),0,0)
			#create_hitbox(width/2,width/2,0.1,(45),scale/4,0,1,'normal',Vector2(centerx-width/4,centery+width/4),0,0)
			#create_hitbox(width/2,width/2,0.1,(315),scale/2,0,1,'normal',Vector2(centerx-width/4,centery-width/4),0,0)
		#if angle >= 270 and angle <= 360:
			#create_hitbox(width/2,width/2,0.1,(135),scale/4,0,1,'normal',Vector2(centerx+width/4,centery+width/4),0,0)
			#create_hitbox(width/2,width/2,0.1,(225),scale/2,0,1,'normal',Vector2(centerx+width/4,centery-width/4),0,0)
			#create_hitbox(width/2,width/2,0.1,(45),scale/2,0,1,'normal',Vector2(centerx-width/4,centery+width/4),0,0)
			#create_hitbox(width/2,width/2,0.1,(315),scale,0,1,'normal',Vector2(centerx-width/4,centery-width/4),0,0)
	if frame == 27:
		create_hitbox(150,150,5,80,100,120,2,'normal',Vector2(0,0),0,0)
	if frame == 29:
		return true
		
#func NAIR():
	#var angle = velocity.angle()  # This returns the angle in radians
	#var angle_degrees = rad_to_deg(angle)  # Convert to degrees for easier handling
#
	## Normalize angle to be between 0 and 360 degrees
	#if angle_degrees < 0:
		#angle_degrees += 360
#
	## Print for debugging purposes
	#print(angle_degrees)
#
	#var centerx = 0
	#var centery = 0
	#var width = 100
#
	#if frame > 4 and frame < 27:
		#if int(frame) % 1 == 0:
			## Calculate hitbox positions relative to the player
			#var hitbox_positions = [
				#Vector2(width / 4, width / 4),
				#Vector2(width / 4, -width / 4),
				#Vector2(-width / 4, width / 4),
				#Vector2(-width / 4, -width / 4)
			#]
#
			#for pos in hitbox_positions:
				## Adjust the hitbox angle to keep them pointed towards the center
				#var adjusted_angle = angle_degrees + pos.angle()
				#create_hitbox(width / 2, width / 2, 0.1, adjusted_angle, 5000, 0, 1, 'normal', pos, 0, 0)
#
	#if frame == 27:
		#create_hitbox(150, 150, 2, 80, 100, 120, 2, 'normal', Vector2(0, 0), 0, 0)
#
	#if frame == 29:
		#return true


func UAIR():
	if frame == 22:
		create_hitbox(150,150,20,80,1000,60,3,'normal',Vector2(0,-130),0,1)
	if frame == 60:
		return true 

func BAIR():
	if frame == 9:
		create_hitbox(120,100,15,135,1,100,3,'normal',Vector2(-50,0),0,1)
	if frame == 50:
		return true
		
func FAIR():
	if frame == 8:
		create_hitbox(150,200,8,40,5,100,3,'normal',Vector2(65,-20),0,1)
		#create_hitbox(125,100,4,40,5,100,1,'normal',Vector2(50,-60),0,1)
	#if frame == 9:
		#create_hitbox(150,200,4,40,5,100,1,'normal',Vector2(65,-20),0,1)	
	#if frame == 10:
		#create_hitbox(100,115,4,40,5,100,1,'normal',Vector2(25,25),0,1)
	if frame == 37:
		return true 

func DAIR():
	var box = null
	if frame == 20:
		box = create_hitbox(70,70,12,270,5,120,7,'normal',Vector2(0,0),0,1)
	if frame > 20 and frame < 27:
		if box:
			box.position = self.position
	if frame == 39:
		return true
		
		
		
		
		
func DASH_ATTACK():
	var box = null
	var start = 5
	var end = 30
	if frame == 5:
		box = create_hitbox(70,70,12,45,10,80,end-start,'normal',Vector2(0,0),0,1)
	if frame > start and frame < end:
		if box:
			box.position = self.position
	if frame == end+5:
		return true
		
func STRONG_DASH_ATTACK():
	var box = null
	var strongduration = 10
	var strongstart = 17
	var weakduration = 10
	var weakstart = strongstart+strongduration+1
	if frame == strongstart:
		box = create_hitbox(100,70,15,45,20,130,strongduration,'normal',Vector2(0,0),0,1)
	if frame > strongstart and frame < strongstart + strongduration:
		if box:
			box.position = self.position
	if frame == weakstart:
		box = create_hitbox(70,70,12,45,10,80,weakduration,'normal',Vector2(0,0),0,1)
	if frame > weakstart and frame < weakstart + weakduration:
		if box:
			box.position = self.position
	if frame == strongduration + strongstart + weakduration + 18:
		return true
		
func DAIR_LANDING():
	pass
	#create_hitbox(500,50,12,45,20,110,600,'normal',Vector2(0,0),0,1)

# Special Attacks
func NEUTRAL_SPECIAL():
	print(projectile_cooldown)
	if frame == 8:
		if projectile_cooldown < 0:
			create_projectile(1,0,Vector2(50,0))
			projectile_cooldown = 70
	if frame == 30:
		return true

func UP_SPECIAL():
	fastfall = false
	var box = null
	var start = 5
	var end = 30
	if frame == 5:
		box = create_hitbox(70,70,12,90,10,80,end-start,'normal',Vector2(0,0),0,1)
	if frame > start and frame < end:
		if box:
			box.position = self.position
	if frame == 20:
		return true

