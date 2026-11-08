extends Fighter

@onready var gun_pos = $gun_pos

func _init():
	projectile_scene = load('res://characters/fux/fux_laser.tscn')

## Lasers come out of the gun node, mirrored when facing left.
func _projectile_spawn_position(point) -> Vector2:
	gun_pos.set_position(point)
	if direction() != 1:
		gun_pos.position.x = -gun_pos.position.x
	return gun_pos.get_global_position()

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
	var width = 90
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
		create_hitbox(100, 30, 7, 20, 3, 90, 2, 'normal', Vector2(61,3), 0)
	if frame >= 15:
		return true
		
func FORWARD_SMASH():
	var start = 13
	var duration = 4
	var endlag = 30
	if frame < start:
		apply_traction(3)
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
		apply_traction(3)
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
		create_hitbox(75,55,5,30,0,60,27,'normal',Vector2(20,10),0,0)
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
		create_hitbox(70,70,12,90,10,80,trans1-end,'normal',Vector2(0,0),0,1)
		if Input.is_action_pressed("right_%s" % id):
			direction.x += 1
		if Input.is_action_pressed("left_%s" % id):
			direction.x -= 1
		if Input.is_action_pressed("up_%s" % id):
			direction.y -= 1
		if Input.is_action_pressed("down_%s" % id):
			direction.y += 1

		#if direction.length() > 0:
			#direction = direction.normalized()
		
		#print("angle: ", rad_to_deg(direction.angle()))
		var directions = [Vector2(1,0),Vector2(1,-1),Vector2(0,-1),Vector2(-1,-1),Vector2(-1,0),Vector2(-1,1),Vector2(0,1),Vector2(1,1)]
		for dir in directions:
			dir.y *= -1
			var ang = round(rad_to_deg(dir.angle()))
			dir.y *= -1
			if ang < 0:
				ang+=360
			ang*=-1
			ang+=90
		direction.y *= -1
		var angle = round(rad_to_deg(direction.angle()))
		direction.y *= -1
		if angle < 0:
			angle+=360
		angle*=-1
		angle+=90
			#
		#90
		#45
		#-45
		#-90
		#-135
		#-180
		#-235
		#$Sprite.scale.x *= -1
		sprite.rotation_degrees = angle
		velocity = 1750 * direction
		
	if frame == end:
		sprite.rotation_degrees = 0
		return true

# Special Attacks
func NEUTRAL_SPECIAL():
	if frame == 4:
		create_projectile(1,0,Vector2(50,0))
	if frame == 14:
		return true

