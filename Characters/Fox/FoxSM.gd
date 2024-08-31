extends StateMachine
@onready var id = get_parent().id

# Called when the node enters the scene tree for the first time.
func _ready():
	#Ground Movement
	add_state('STAND')
	add_state('DASH')
	add_state('MOONWALK')
	add_state('RUN')
	add_state('TURN')
	#Air Movement
	add_state('LANDING')
	add_state('JUMP_SQUAT')
	add_state('WALK')
	add_state('CROUCH')
	add_state('SHORT_HOP')
	add_state('FULL_HOP')
	add_state('AIR')
	#Ledge
	add_state('LEDGE_CATCH')
	add_state('LEDGE_HOLD')
	add_state('LEDGE_CLIMB')
	add_state('LEDGE_JUMP')
	add_state('LEDGE_ROLL')
	#Ground Attacks
	add_state('DASH_ATTACK')
	add_state('STRONG_DASH_ATTACK')
	add_state('TILT_ATTACK')
	add_state('SMASH_ATTACK')
	add_state('UP_SMASH')
	add_state('FORWARD_SMASH')
	add_state('DOWN_SMASH')
	add_state('DOWN_TILT')
	add_state('UP_TILT')
	add_state('FORWARD_TILT')
	#Aerials
	add_state('NAIR')
	add_state('UAIR')
	add_state('DAIR')
	add_state('FAIR')
	add_state('AIR_ATTACK') #27
	add_state('BAIR')
	#defensive
	add_state('SHIELD')
	add_state('ROLL_LEFT')
	add_state('ROLL_RIGHT')
	add_state('AIRDODGE')
	add_state('FREEFALL')
	#Specials
	add_state('NEUTRAL_SPECIAL')
	add_state('UP_SPECIAL')
	#Misc
	add_state('HITSTUN')
	add_state('HITFREEZE')
	add_state('GRABBED')
	add_state('GRAB')
	add_state('THROW')
	call_deferred("set_state", states.STAND) #As the character is loading, have default be standing.

func state_logic(delta):
	parent.updateframes(delta)
	parent._physics_process(delta)
	if parent.regrab > 0:
		parent.regrab-=1
	parent._hit_pause(delta)
	
func get_transition(delta):
	id = get_parent().id
	#parent.move_and_slide_with_snap(parent.velocity*2,Vector2.ZERO,Vector2.UP)	
	#parent.state.text = str(state)
	parent.set_up_direction(Vector2.UP)
	parent.move_and_slide()
	#print(parent.velocity.y)
	
	if Ledge() == true:
		parent.newframe()
		return states.LEDGE_CATCH
	else:
		parent.reset_ledge()
	
	if Landing() == true:
		if state == states.DAIR:
			parent.DAIR_LANDING()
		parent.newframe()
		return states.LANDING
	
	if Falling() == true:
		return states.AIR
		
	if Input.is_action_just_pressed("attack_%s" % id) && TILT() == true:
		parent.newframe()
		return states.TILT_ATTACK
	
	if Input.is_action_just_pressed("strong_%s" % id) && TILT() == true:
		parent.newframe()
		return states.SMASH_ATTACK
		
		
	if state == states.RUN:
		if Input.is_action_just_pressed("attack_%s" % id):
			parent.newframe()
			return states.DASH_ATTACK
		elif Input.is_action_just_pressed("strong_%s" % id):
			parent.newframe()
			return states.STRONG_DASH_ATTACK
		
	if Input.is_action_just_pressed("shield_%s" % id) and can_roll() == true and parent.cooldown == 0: #and parent.shield_buffer == 2:
		if Input.is_action_pressed("right_%s" % id):
			parent.newframe()
			return states.ROLL_RIGHT
		if Input.is_action_pressed("left_%s" % id):
			parent.newframe()
			return states.ROLL_LEFT
		else:
			return states.SHIELD
	
		
	if (Input.is_action_just_pressed("attack_%s" % id) or Input.is_action_just_pressed("strong_%s" % id)) && state == states.AIR:
		parent.newframe()
		return states.AIR_ATTACK
	
	if Input.is_action_just_pressed("special_%s" % id) && SPECIAL() == true:
		parent.newframe()
		if Input.is_action_pressed("up_%s" % id)  and parent.special:
			return states.UP_SPECIAL
		else:
			return states.NEUTRAL_SPECIAL


	match state:
		states.LANDING:
			#print(parent.frame, " ", parent.landing_frames, " ", parent.lag_frames)
			parent.reset_jumps()
			if parent.frame <= parent.landing_frames + parent.lag_frames:
				if parent.frame == 1:
					pass
				if parent.velocity.x > 0:
					parent.velocity.x = parent.velocity.x - parent.TRACTION/2
					parent.velocity.x = clampf(parent.velocity.x, 0, parent.velocity.x)
				elif parent.velocity.x < 0:
					parent.velocity.x = parent.velocity.x + parent.TRACTION/2
					parent.velocity.x = clampf(parent.velocity.x, parent.velocity.x, 0)
				if Input.is_action_just_pressed("jump_%s" % id) :
					parent.newframe()
					return states.JUMP_SQUAT
			else:
				if Input.is_action_pressed("down_%s" % id):
					parent.lag_frames = 0
					parent.newframe()
					return states.CROUCH
				else:
					parent.newframe()
					parent.lag_frames = 0
					return states.STAND
				parent.lag_frames = 0
		states.STAND:
			if Input.is_action_just_pressed("down_%s" % id):
				parent.newframe()
				return states.CROUCH
			if Input.is_action_just_pressed("jump_%s" % id):
				parent.newframe()
				return states.JUMP_SQUAT
			if Input.get_action_strength("right_%s" % id ) == 1:
				parent.velocity.x = parent.RUNSPEED
				#print(parent.velocity.x)
				parent.newframe()
				parent.turn(false)
				return states.DASH
			if Input.get_action_strength("left_%s" % id) == 1:
				parent.velocity.x = -parent.RUNSPEED
				parent.newframe()
				parent.turn(true)
				return states.DASH
			if parent.velocity.x > 0 and state == states.STAND:
				parent.velocity.x -= parent.TRACTION*1
				parent.velocity.x = clampf(parent.velocity.x, 0, parent.velocity.x)
			elif parent.velocity.x < 0 and state == states.STAND:
				parent.velocity.x += parent.TRACTION*1
				parent.velocity.x = clampf(parent.velocity.x, parent.velocity.x, 0)
		states.JUMP_SQUAT:
			#print("Jump Squat")			
			if parent.frame == parent.jump_squat:
				if not Input.is_action_pressed("jump_%s" % id):
					parent.velocity.x = lerpf(parent.velocity.x,0,0.08)
					parent.newframe()
					return states.SHORT_HOP
				else:
					parent.velocity.x = lerpf(parent.velocity.x,0,0.08)
					parent.newframe()
					return states.FULL_HOP
		states.SHORT_HOP:
			#print("Short Hop")			
			parent.velocity.y = -parent.JUMPFORCE
			parent.newframe()
			return states.AIR
		states.FULL_HOP:
			#print("Full Hop")			
			parent.velocity.y = -parent.MAX_JUMPFORCE
			parent.newframe()
			return states.AIR
		states.DASH:
			if Input.is_action_just_pressed("jump_%s" % id) :
					parent.newframe()
					return states.JUMP_SQUAT
			if Input.is_action_just_pressed("down_%s" % id) :
					parent.newframe()
					return states.CROUCH
			if Input.is_action_pressed("left_%s" % id):
				if parent.velocity.x > 0:
					parent.newframe()
				parent.velocity.x = -parent.DASHSPEED
				if parent.frame <= parent.dash_duration-1:
					parent.turn(true)
					return states.DASH
				else:
					parent.turn(true)
					parent.newframe()
					return states.RUN
			elif Input.is_action_pressed("right_%s" % id):
				if parent.velocity.x < 0:
					parent.newframe()
				parent.velocity.x = parent.DASHSPEED
				if parent.frame <= parent.dash_duration-1:
					parent.turn(false)
					return states.DASH
				else:
					parent.turn(false)
					parent.newframe()
					return states.RUN
			else:
				if parent.frame >= parent.dash_duration-1:
					return states.STAND
		states.MOONWALK:
			pass
		states.RUN:
			if Input.is_action_just_pressed("jump_%s" % id):
				parent.newframe()
				return states.JUMP_SQUAT
			elif Input.is_action_just_pressed("down_%s" % id):
				parent.newframe()
				return states.CROUCH
			elif Input.get_action_strength("right_%s" % id):
				if(parent.velocity.x >= 0):
					parent.velocity.x = parent.RUNSPEED
					parent.turn(false)
					#return states.RUN
				else:
					parent.newframe()
					return states.TURN
			elif Input.get_action_strength("left_%s" % id):
				if(parent.velocity.x <= 0):
					parent.velocity.x = -parent.RUNSPEED
					parent.turn(true)
					#return states.RUN
				else:
					parent.newframe()
					return states.TURN
			else:
				parent.newframe()
				return states.STAND
		states.WALK:
			if Input.is_action_just_pressed("jump_%s" % id):
				parent.newframe()
				return states.JUMP
			if Input.is_action_pressed("down_%s" % id):
				return states.CROUCH
			if Input.get_action_strength("right_%s" % id):
				parent.velocity.x += parent.WALKSPEED * Input.get_action_strength("right_%s" % id)
				parent.turn(false)
			if Input.get_action_strength("right_%s" % id):
				parent.velocity.x -= parent.WALKSPEED * Input.get_action_strength("left_%s" % id)
				parent.turn(true)
			else:
				parent.newframe()
				return states.STAND
		states.CROUCH:
			if Input.is_action_just_released("down_%s" % id):
				parent.newframe()
				return states.STAND
			elif Input.is_action_just_pressed("jump_%s" % id):
				parent.newframe()
				return states.JUMP_SQUAT
			if parent.velocity.x > 0:
				parent.velocity.x -= parent.TRACTION*2
				parent.velocity.x = clampf(parent.velocity.x, 0, parent.velocity.x)
			elif parent.velocity.x < 0:
				parent.velocity.x += parent.TRACTION*2
				parent.velocity.x = clampf(parent.velocity.x, parent.velocity.x, 0)
		states.TURN:
			if Input.is_action_just_pressed("jump_%s" % id):
				parent.newframe()
				return states.JUMP_SQUAT
			if parent.velocity.x > 0:
				parent.turn(true)
				parent.velocity.x -= parent.TRACTION*2
				parent.velocity.x = clamp(parent.velocity.x, 0 , parent.velocity.x)
			elif parent.velocity.x < 0:
				parent.turn(false)
				parent.velocity.x += parent.TRACTION*2
				parent.velocity.x = clamp(parent.velocity.x, parent.velocity.x, 0)
			else:
				if not Input.is_action_just_pressed("left_%s" % id) and not Input.is_action_just_pressed("right_%s" % id):
					parent.newframe()
					return states.STAND
				else:
					parent.newframe()
					return states.RUN
		states.AIR:
			AIRMOVEMENT()
			if Input.is_action_just_pressed("jump_%s" % id) and parent.airJump > 0:
				parent.fastfall = false
				parent.velocity.x = 0
				parent.velocity.y = -parent.DOUBLEJUMPFORCE
				parent.airJump -= 1
				if Input.is_action_pressed("left_%s" % id):
					parent.velocity.x = -parent.MAXAIRSPEED
				elif Input.is_action_pressed("right_%s" % id):
					parent.velocity.x = parent.MAXAIRSPEED
			if Input.is_action_just_pressed("shield_%s" % id):
				parent.newframe()
				return states.AIRDODGE
		states.FREEFALL:
			if parent.velocity.y < parent.MAXFALLSPEED:
				parent.velocity.y += parent.FALLSPEED
			if Input.is_action_just_pressed("down_%s" % id) and parent.velocity.y > 0 and not parent.fastfall:
				parent.velocity.y = parent.MAXFALLSPEED
				parent.fastfall = true
			if abs(parent.velocity.x) >= abs(parent.MAXAIRSPEED): #max airspeed reached
				if parent.velocity.x > 0: #going right
					if Input.is_action_pressed("left_%s" % id):
						parent.velocity.x -= parent.AIR_ACCEL 
					if Input.is_action_pressed("right_%s" % id):
						parent.velocity.x = parent.velocity.x
				if parent.velocity.x < 0: #going left
					if Input.is_action_pressed("left_%s" % id):
						parent.velocity.x = parent.velocity.x
					if Input.is_action_pressed("right_%s" % id): 
						parent.velocity.x += parent.AIR_ACCEL 
			else: #max airspeed not reached
				if Input.is_action_pressed("left_%s" % id):
					parent.velocity.x -= parent.AIR_ACCEL
				if Input.is_action_pressed("right_%s" % id):
					parent.velocity.x += parent.AIR_ACCEL
					
			#No DI
			if not Input.is_action_pressed("left_%s" % id) and not Input.is_action_pressed("right_%s" % id):
				if parent.velocity.x < 0:
					parent.velocity.x += parent.AIR_ACCEL / 2
				elif parent.velocity.x > 0:
					parent.velocity.x -= parent.AIR_ACCEL / 2
				
		states.AIRDODGE:
			if parent.frame == 1:
				parent.velocity.x = 0
				parent.velocity.y = 0
				var deadzone = (Input.get_action_strength("right_%s" % id)-Input.get_action_strength("left_%s" % id) in range(-0.2,1.2) and Input.get_action_strength("up_%s" % id)-Input.get_action_strength("down_%s" % id) in range(-0.2,1.2))
				var direction = Vector2(Input.get_action_strength("right_%s" % id)-Input.get_action_strength("left_%s" % id),Input.get_action_strength("down_%s" % id)-Input.get_action_strength("up_%s" % id))
				if deadzone:
					direction = Vector2(0,0)
				parent.velocity = parent.air_dodge_speed*direction.normalized()
				if abs(parent.velocity.x)==abs(parent.velocity.y):
					parent.velocity.x = parent.velocity.x/1.15
					parent.velocity.y = parent.velocity.y/1.15
				parent.lag_frames = 3
			if parent.frame >= 4 and parent.frame <= 10:
				parent.hurtbox.disabled = true
				if parent.frame == 5: #?
					pass
				parent.velocity.x = parent.velocity.x/1.15
				parent.velocity.y = parent.velocity.y/1.15
			if parent.frame >= 10 and parent.frame < 20:
				parent.hurtbox.disabled = true
				parent.velocity.x = 0
				parent.velocity.y = 0
			if parent.frame > 20:
				parent.hurtbox.disabled = false
				parent.lag_frames = 8
				parent.newframe()
				return states.FREEFALL
			if parent.is_on_floor():
				parent.hurtbox.disabled = false				
				parent.newframe()
				if parent.velocity.y > 0:
					parent.velocity.y = 0
				parent.fastfall = false
				parent.newframe()
				return states.LANDING
		states.LEDGE_CATCH:
			if parent.frame > 7:
				parent.lag_frames = 0
				parent.newframe()
				parent.reset_jumps()
				return states.LEDGE_HOLD
		states.LEDGE_HOLD:
			if parent.frame >= 390: #3.5 seconds
				self.parent.position.y -= 25
				parent.newframe()
				#return states.TUMBLE
				return states.AIR
			if Input.is_action_just_pressed("down_%s" % id):
				parent.fastfall = true
				parent.regrab = 30
				parent.reset_ledge()
				self.parent.position.y -= 25
				parent.catch = false
				parent.newframe()
				return states.AIR
			elif parent.Ledge_Grab_F.get_target_position().x>0: #facing right
				if Input.is_action_just_pressed("left_%s" % id):
					parent.velocity.x = parent.AIR_ACCEL/2
					parent.regrab = 30
					parent.reset_ledge()
					self.parent.position.y -= 25
					parent.catch = false
					parent.newframe()
					return states.AIR
				elif Input.is_action_just_pressed("right_%s" % id):
					parent.newframe()
					return states.LEDGE_CLIMB
				elif Input.is_action_just_pressed("shield_%s" % id):
					parent.newframe()
					return states.LEDGE_ROLL
				elif Input.is_action_just_pressed("jump_%s" % id):
					parent.newframe()
					return states.LEDGE_JUMP
			elif parent.Ledge_Grab_F.get_target_position().x<0: #facing left
				if Input.is_action_just_pressed("right_%s" % id):
					parent.velocity.x = parent.AIR_ACCEL/2
					parent.regrab = 30
					parent.reset_ledge()
					self.parent.position.y -= 25
					parent.catch = false
					parent.newframe()
					return states.AIR
				elif Input.is_action_just_pressed("left_%s" % id):
					parent.newframe()
					return states.LEDGE_CLIMB
				elif Input.is_action_just_pressed("shield_%s" % id):
					parent.newframe()
					return states.LEDGE_ROLL
				elif Input.is_action_just_pressed("jump_%s" % id):
					parent.newframe()
					return states.LEDGE_JUMP
		states.LEDGE_CLIMB:
			if parent.frame == 1:
				pass
			if parent.frame == 5:
				parent.position.y -= 40
			if parent.frame == 10:
				parent.position.y -= 40
			if parent.frame == 22:
				parent.catch = false
				parent.position.y -= 40
				parent.position.x += 90*parent.direction()
			if parent.frame == 25:
				parent.velocity.y = 0
				parent.velocity.x = 0
				parent.move_and_collide(Vector2(parent.direction()*20,50))
			if parent.frame == 30:
				parent.reset_ledge()
				parent.newframe()
				return states.STAND
		states.LEDGE_JUMP:
			if parent.frame > 14: 
				if Input.is_action_just_pressed("attack_%s" % id):
					parent.newframe()
					return states.AIR_ATTACK
				if Input.is_action_just_pressed("special_%s" % id):
					parent.newframe()
					return states.SPECIAL
			if parent.frame == 5:
				parent.reset_ledge()
				parent.position.y -= 20
			if parent.frame == 10:
				parent.catch = false
				parent.position.y -= 20
				if Input.is_action_just_pressed("jump_%s" % id) and parent.airJump > 0: #?
					parent.fastfall = false
					parent.velocity.y = -parent.DOUBLEJUMPFORCE #?
					parent.velocity.x = 0
					parent.airJump -= 1
					parent.newframe()
					return states.AIR
			if parent.frame == 15:
				parent.position.y -= 20
				parent.velocity.y -= parent.DOUBLEJUMPFORCE
				parent.velocity.x += 220*parent.direction()
				if Input.is_action_just_pressed("jump_%s" % id ) and parent.airJump > 0:
					parent.fastfall = false
					parent.velocity.y = -parent.DOUBLEJUMPFORCE
					parent.velocity.x = 0
					parent.airJump -= 1
					parent.newframe()
					return states.AIR
			if parent.frame > 15 and parent.frame < 20:
				parent.velocity.y+=parent.FALLSPEED
				if Input.is_action_just_pressed("jump_%s" % id) and parent.airJump > 0: #?
					parent.fastfall = false
					parent.velocity.y = -parent.DOUBLEJUMPFORCE
					parent.velocity.x = 0
					parent.airJump -= 1
					parent.newframe()
					return states.AIR
				if Input.is_action_just_pressed("attack_%s" % id):
					parent.newframe()
					return states.AIR_ATTACK
			if parent.frame==20:
				parent.newframe()
				return states.AIR
		states.LEDGE_ROLL:
			if parent.frame == 1:
				pass
			if parent.frame == 5:
				parent.position.y -= 40
			if parent.frame == 10:
				parent.position.y -= 30
			if parent.frame == 22:
				parent.position.y -= 30
				parent.position.x += 50*parent.direction()
			if parent.frame > 22 and parent.frame <28:
				parent.position.x += 30*parent.direction()
			if parent.frame == 29:
				parent.move_and_collide(Vector2(parent.direction()*20,50))
			if parent.frame==30:
				parent.velocity.y = 0
				parent.velocity.x = 0
				parent.reset_ledge()
				parent.newframe()
				return states.STAND
		states.SHIELD:
			parent.hurtbox.disabled = true
			if parent.velocity.x > 0:
				parent.velocity.x += -parent.TRACTION * 3
				parent.velocity.x = clampf(parent.velocity.x, 0, parent.velocity.x)
			if parent.velocity.x < 0:
				parent.velocity.x += parent.TRACTION * 3
				parent.velocity.x = clampf(parent.velocity.x, parent.velocity.x, 0)
			if Input.is_action_pressed("right_%s" % id):
				parent.newframe()
				return states.ROLL_RIGHT
			if Input.is_action_pressed("left_%s" % id):
				parent.newframe()
				return states.ROLL_LEFT
				
			if Input.is_action_just_pressed("attack_%s" % id) or Input.is_action_just_pressed("strong_%s" % id):
				parent.hurtbox.disabled = false  # Re-enable hurtbox when grabbing
				parent.newframe()
				return states.GRAB
				
			if Input.is_action_pressed("shield_%s" % id):
				return states.SHIELD
			else:
				parent.hurtbox.disabled = false  # Ensure hurtbox is re-enabled
				return states.STAND
		states.ROLL_RIGHT:
			parent.turn(true)
			if parent.frame == 1:
				parent.velocity.x = 0
			if parent.frame == 4:
				parent.velocity.x = parent.ROLL_DISTANCE
				parent.hurtbox.disabled = true
			if parent.frame == 20:
				parent.hurtbox.disabled = false
			if parent.frame > 19:
				parent.velocity.x = parent.velocity.x - parent.TRACTION*5
				parent.velocity.x = clampi(parent.velocity.x,0,parent.velocity.x)
				if parent.velocity.x == 0:
					parent.cooldown = 20
					parent.lag_frames = 10
					parent.newframe()
					return states.LANDING
		states.ROLL_LEFT:
			parent.turn(false)
			if parent.frame == 1:
				parent.velocity.x = 0
			if parent.frame == 4:
				parent.velocity.x = -parent.ROLL_DISTANCE
				parent.hurtbox.disabled = true
			if parent.frame == 20:
				parent.hurtbox.disabled = false
			if parent.frame > 19:
				parent.velocity.x = parent.velocity.x + parent.TRACTION*5
				parent.velocity.x = clampi(parent.velocity.x,parent.velocity.x,0)
				if parent.velocity.x == 0:
					parent.cooldown = 20
					parent.lag_frames = 10
					parent.newframe()
					return states.LANDING
			
		states.AIR_ATTACK:
			AIRMOVEMENT()
			if Input.is_action_pressed("up_%s" % id):
				parent.newframe()
				return states.UAIR
			if Input.is_action_pressed("down_%s" % id):
				parent.newframe()
				return states.DAIR
			if parent.direction() == 1:
				if Input.is_action_pressed("left_%s" % id):
					parent.newframe()
					return states.BAIR
				if Input.is_action_pressed("right_%s" % id):
					parent.newframe()
					return states.FAIR
			else:
				if Input.is_action_pressed("left_%s" % id):
					parent.newframe()
					return states.FAIR
				if Input.is_action_pressed("right_%s" % id):
					parent.newframe()
					return states.BAIR
			parent.newframe()
			return states.NAIR
		states.TILT_ATTACK:
			if Input.is_action_pressed("up_%s" % id):
				parent.newframe()
				return states.UP_TILT
			if Input.is_action_pressed("down_%s" % id):
				parent.newframe()
				return states.DOWN_TILT
			if Input.is_action_pressed("left_%s" % id):
				parent.turn(true)
				parent.newframe()
				return states.FORWARD_TILT
			if Input.is_action_pressed("right_%s" % id):
				parent.turn(false)
				parent.newframe()
				return states.FORWARD_TILT
			parent.newframe
			return states.FORWARD_TILT
		states.SMASH_ATTACK:
			if Input.is_action_pressed("up_%s" % id):
				parent.newframe()
				return states.UP_SMASH
			if Input.is_action_pressed("down_%s" % id):
				parent.newframe()
				return states.DOWN_SMASH
			if Input.is_action_pressed("left_%s" % id):
				parent.turn(true)
				parent.newframe()
				return states.FORWARD_SMASH
			if Input.is_action_pressed("right_%s" % id):
				parent.turn(false)
				parent.newframe()
				return states.FORWARD_SMASH
			parent.newframe
			return states.FORWARD_SMASH
		states.GRAB:
			if parent.frame == 1:
				parent.GRAB()
			if parent.frame >= 1:
				if parent.velocity.x > 0:
					if parent.velocity.x > parent.DASHSPEED:
						parent.velocity.x = parent.DASHSPEED
					parent.velocity.x += -parent.TRACTION*20
					parent.velocity.x = clampf(parent.velocity.x,0,parent.velocity.x)
				elif parent.velocity.x < 0:
					if parent.velocity.x < -parent.DASHSPEED:
						parent.velocity.x = -parent.DASHSPEED
					parent.velocity.x += parent.TRACTION*20
					parent.velocity.x = clampf(parent.velocity.x,parent.velocity.x,0)
			if parent.frame > 180 or Input.is_action_just_pressed("attack_%s" % 1) or Input.is_action_just_pressed("strong_%s" % 1) or Input.is_action_just_pressed("up_%s" % 1):
				parent.grabbing = false
				parent.newframe()
				parent.throwDir = "u"
				return states.THROW
			elif Input.is_action_just_pressed("right_%s" % 1):
				parent.grabbing = false
				parent.newframe()
				if parent.direction() == 1:
					parent.throwDir = "f"
				else:
					parent.throwDir = "b"
				return states.THROW
			elif Input.is_action_just_pressed("left_%s" % 1):
				parent.grabbing = false
				parent.newframe()
				if parent.direction() == 1:
					parent.throwDir = "b"
				else:
					parent.throwDir = "f"
				return states.THROW
			elif Input.is_action_just_pressed("down_%s" % 1):
				parent.grabbing = false
				parent.newframe()
				parent.throwDir = "d"
				return states.THROW
			elif Input.is_action_just_pressed("forward_%s" % 1):
				parent.grabbing = false
				parent.newframe()
				parent.throwDir = "f"
				return states.THROW
			if parent.GRAB() and parent.grabbing == false:
				parent.newframe()
				return states.STAND
		states.THROW:
			parent.THROW()
			if parent.frame >= 1:
				if parent.velocity.x > 0:
					if parent.velocity.x > parent.DASHSPEED:
						parent.velocity.x = parent.DASHSPEED
					parent.velocity.x += -parent.TRACTION*20
					parent.velocity.x = clampf(parent.velocity.x,0,parent.velocity.x)
				elif parent.velocity.x < 0:
					if parent.velocity.x < -parent.DASHSPEED:
						parent.velocity.x = -parent.DASHSPEED
					parent.velocity.x += parent.TRACTION*20
					parent.velocity.x = clampf(parent.velocity.x,parent.velocity.x,0)
			if parent.THROW() == true:
				if Input.is_action_pressed("down_%s" % id):
					parent.newframe()
					return states.CROUCH
				else:
					parent.newframe()
					return states.STAND
		states.DOWN_TILT:
			if parent.frame == 0:
				parent.DOWN_TILT()
				pass
			if parent.frame >= 1:
					if parent.velocity.x > 0:
						parent.velocity.x += -parent.TRACTION*3
						parent.velocity.x = clampf(parent.velocity.x,0,parent.velocity.x)
					elif parent.velocity.x < 0:
						parent.velocity.x += parent.TRACTION*3
						parent.velocity.x = clampf(parent.velocity.x,parent.velocity.x,0)
			if parent.DOWN_TILT() == true:
				if Input.is_action_pressed("down_%s" % id):
					parent.newframe()
					return states.CROUCH
				else:
					parent.newframe()
					return states.STAND
		states.UP_TILT:
			if parent.frame == 0:
				parent.UP_TILT()
				pass
			if parent.frame >= 1:
					if parent.velocity.x > 0:
						parent.velocity.x += -parent.TRACTION*3
						parent.velocity.x = clampf(parent.velocity.x,0,parent.velocity.x)
					elif parent.velocity.x < 0:
						parent.velocity.x += parent.TRACTION*3
						parent.velocity.x = clampf(parent.velocity.x,parent.velocity.x,0)
			if parent.UP_TILT() == true:
				if Input.is_action_pressed("down_%s" % id):
					parent.newframe()
					return states.CROUCH
				else:
					parent.newframe()
					return states.STAND
		states.FORWARD_TILT:
			if parent.frame == 0:
				parent.FORWARD_TILT()
			if parent.frame >= 1:
					if parent.velocity.x > 0:
						parent.velocity.x += -parent.TRACTION*3
						parent.velocity.x = clampf(parent.velocity.x,0,parent.velocity.x)
					elif parent.velocity.x < 0:
						parent.velocity.x += parent.TRACTION*3
						parent.velocity.x = clampf(parent.velocity.x,parent.velocity.x,0)
			if parent.FORWARD_TILT() == true:
				if Input.is_action_pressed("down_%s" % id):
					parent.newframe()
					return states.CROUCH
				else:
					parent.newframe()
					return states.STAND
		states.UP_SMASH:
			if parent.frame == 0:
				parent.UP_SMASH()
			if parent.frame >= 1:
					if parent.velocity.x > 0:
						parent.velocity.x += -parent.TRACTION*3
						parent.velocity.x = clampf(parent.velocity.x,0,parent.velocity.x)
					elif parent.velocity.x < 0:
						parent.velocity.x += parent.TRACTION*3
						parent.velocity.x = clampf(parent.velocity.x,parent.velocity.x,0)
			if parent.UP_SMASH() == true:
				if Input.is_action_pressed("down_%s" % id):
					parent.newframe()
					return states.CROUCH
				else:
					parent.newframe()
					return states.STAND
		states.FORWARD_SMASH:
			if parent.FORWARD_SMASH() == true:
				parent.newframe()
				return states.STAND
		states.DOWN_SMASH:
			if parent.frame >= 1:
					if parent.velocity.x > 0:
						parent.velocity.x += -parent.TRACTION*3
						parent.velocity.x = clampf(parent.velocity.x,0,parent.velocity.x)
					elif parent.velocity.x < 0:
						parent.velocity.x += parent.TRACTION*3
						parent.velocity.x = clampf(parent.velocity.x,parent.velocity.x,0)
			if parent.DOWN_SMASH() == true:
				parent.newframe()
				return states.STAND
		states.DASH_ATTACK:
			if parent.DASH_ATTACK() == true:
				parent.newframe()
				return states.AIR
		states.STRONG_DASH_ATTACK:
			if parent.STRONG_DASH_ATTACK() == true:
				parent.newframe()
				return states.AIR
		states.NAIR:
			AIRMOVEMENT()
			if parent.frame == 0:
				parent.NAIR()
			if parent.NAIR() == true:
				parent.lag_frames = 0
				parent.newframe()
				return states.AIR
			elif parent.frame < 5 or parent.frame > 15:
				parent.lag_frames = 0
			else:
				parent.lag_frames = 7
		states.FAIR:
			AIRMOVEMENT()
			if parent.frame == 0:
				parent.FAIR()
			if parent.FAIR() == true:
				parent.lag_frames = 0
				parent.newframe()
				return states.AIR
			else:
				parent.lag_frames = 10
		states.DAIR:
			AIRMOVEMENT()
			if parent.frame == 0:
				parent.DAIR()
			#if parent.frame < 13 or parent.frame > 35:
			#if parent.frame >= 13 and parent.frame <= 18:
				#parent.velocity = Vector2(0,0)
			#if parent.frame == 19:
				#parent.velocity = Vector2(0,3000)
			#if parent.frame >= 30 and parent.frame < 38:
				#parent.velocity = Vector2(0,0)
			if parent.DAIR() == true:
				parent.lag_frames = 0
				parent.newframe()
				return states.AIR
			else:
				parent.lag_frames = 10
		states.BAIR:
			AIRMOVEMENT()
			if parent.frame == 0:
				parent.BAIR()
			if parent.BAIR() == true:
				parent.lag_frames = 0
				parent.newframe()
				return states.AIR
			else:
				parent.lag_frames = 12
		states.UAIR:
			AIRMOVEMENT()
			if parent.frame == 0:
				parent.UAIR()
			if parent.UAIR() == true:
				parent.lag_frames = 0
				parent.newframe()
				return states.AIR
			else:
				parent.lag_frames = 13
		states.UP_SPECIAL:
			if parent.UP_SPECIAL() == true:
				return states.AIR
		states.NEUTRAL_SPECIAL:
			if AERIAL() == false:
				if parent.velocity.x > 0:
					if parent.velocity. x > parent.DASHSPEED:
						parent.velocity.x = parent.DASHSPEED
					parent.velocity.x = parent.velocity.x - parent.TRACTION*10
					parent.velocity.x = clampi(parent.velocity.x,0,parent.velocity.x)
				elif parent.velocity.x < 0:
					if parent.velocity.x < -parent.DASHSPEED:
						parent.velocity.x = -parent.DASHSPEED
					parent.velocity.x = parent.velocity.x + parent.TRACTION*10
					parent.velocity.x = clampi(parent.velocity.x,parent.velocity.x,0)
			if AERIAL() == true:
				AIRMOVEMENT()
			if parent.frame <= 1:
				if parent.projectile_cooldown == 1:
					parent.projectile_cooldown = -1
				if parent.projectile_cooldown == 0:
					parent.projectile_cooldown += 1
					parent.newframe()
					parent.NEUTRAL_SPECIAL()
			#if parent.frame < 14:
				#if Input.is_action_just_pressed("special_%s" % id):
					#parent.newframe()
					#return states.NEUTRAL_SPECIAL
			if parent.NEUTRAL_SPECIAL() == true:
				if AERIAL() == true:
					return states.AIR
				else:
					parent.newframe()
					return states.STAND
		#states.HITFREEZE:
			#if parent.freezeframes == 0:
				#parent.newframe()
				#parent.velocity.x = kbx
				#parent.velocity.x = kby
				#parent.hdecay = hd
				#parent.vdecay = vd
				#return states.HITSTUN
			#parent.position = pos
		states.HITSTUN:
			if parent.knockback >= 3:
				var bounce = parent.move_and_collide(parent.velocity * delta)
				#if bounce:
					#parent.velocity = parent.velocity.bounce(bounce.get_normal()) * .8
					#parent.hitstun = round(parent.hitstun * .8)
				if parent.is_on_wall():
					#parent.velocity.x = kbx - parent.velocity.x
					#parent.velocity = parent.velocity.bounce(parent.get_wall_normal()) *.8
					#parent.hdecay *= -1
					#parent.hitstun = round(parent.hitstun * .8)
					pass
				if parent.is_on_floor():
					parent.velocity.y = kby - parent.velocity.y
					parent.velocity = parent.velocity.bounce(parent.get_floor_normal()) *.8
					parent.hitstun = round(parent.hitstun * .8)
					pass
			if parent.velocity.y < 0:
				parent.velocity.y +=parent.vdecay*0.5 * Engine.time_scale
				parent.velocity.y = clampf(parent.velocity.y,parent.velocity.y,0)
			if parent.velocity.x < 0:
				parent.velocity.x += (parent.hdecay)*0.4 *-1 * Engine.time_scale
				parent.velocity.x = clampf(parent.velocity.x,parent.velocity.x,0)
			elif parent.velocity.x > 0:
				parent.velocity.x -= parent.hdecay*0.4 * Engine.time_scale
				parent.velocity.x = clampf (parent.velocity.x,0,parent.velocity.x)

			if parent.frame >= parent.hitstun:
				if parent.knockback >= 24:
					parent.newframe()
					return states.AIR
				else:
					parent.newframe()
					return states.AIR
			elif parent.frame >60*5:
				return states.AIR
		states.GRABBED:
			parent.hurtbox.disabled = false
			for body in get_tree().get_nodes_in_group("Character"):
				if body.name == temp_body:
					if body.get_node('StateMachine').state != temp_state:
						return states.STAND

func state_includes(state_array):
	for each_state in state_array:
		if state == each_state:
			return true
	return false
	
func AIRMOVEMENT():
	if parent.velocity.y < parent.FALLINGSPEED:
		parent.velocity.y += parent.FALLSPEED
	if Input.is_action_pressed("down_%s" % id) and parent.velocity.y > -150 and not parent.fastfall and not Input.is_action_pressed("attack_%s" % id):
		parent.velocity.y = parent.MAXFALLSPEED
		parent.fastfall = true
	if parent.fastfall == true:
		parent.velocity.y = parent.MAXFALLSPEED
	
	if abs(parent.velocity.x) >= abs(parent.MAXAIRSPEED): #max airspeed reached
		if parent.velocity.x > 0: #going right
			if Input.is_action_pressed("left_%s" % id):
				parent.velocity.x -= parent.AIR_ACCEL 
			if Input.is_action_pressed("right_%s" % id):
				parent.velocity.x = parent.velocity.x
		if parent.velocity.x < 0: #going left
			if Input.is_action_pressed("left_%s" % id):
				parent.velocity.x = parent.velocity.x
			if Input.is_action_pressed("right_%s" % id): 
				parent.velocity.x += parent.AIR_ACCEL 
	else: #max airspeed not reached
		if Input.is_action_pressed("left_%s" % id):
			parent.velocity.x -= parent.AIR_ACCEL*2
		if Input.is_action_pressed("right_%s" % id):
			parent.velocity.x += parent.AIR_ACCEL*2
			
	#No DI
	if not Input.is_action_pressed("left_%s" % id) and not Input.is_action_pressed("right_%s" % id):
		if parent.velocity.x < 0:
			parent.velocity.x += parent.AIR_ACCEL / 5
		elif parent.velocity.x > 0:
			parent.velocity.x -= parent.AIR_ACCEL / 5
		
func Landing():
	if state_includes([states.AIR, states.NAIR, states.UAIR, states.BAIR, states.FAIR, states.DAIR, states.FREEFALL]):
		#print("colliding: ", parent.GroundL.is_colliding(), ", velocity: ", parent.velocity.y)
		if parent.GroundL.is_colliding() and parent.velocity.y >= 0:
			var collider = parent.GroundL.get_collider()
			parent.frame = 0
			#if parent.velocity.y > 0:
			parent.velocity.y = 0
			parent.fastfall = false
			return true
		elif parent.GroundR.is_colliding() and parent.velocity.y >= 0:
			var collider2 = parent.GroundR.get_collider()
			parent.frame = 0
			#if parent.velocity.y > 0:
			parent.velocity.y = 0
			parent.fastfall = false
			return true
			
func Falling():
	if state_includes([states.STAND, states.RUN, states.DASH, states.FORWARD_TILT, states.DOWN_TILT, states.UP_TILT]):
		if not parent.GroundL.is_colliding() and not parent.GroundR.is_colliding():
			return true
	return false
			
func Ledge():
	if not state_includes([states.DAIR]):
		if (parent.Ledge_Grab_F.is_colliding()): 
			var collider = parent.Ledge_Grab_F.get_collider()
			#print(collider.get_node('Label').text =='Ledge_L')
			#print(!Input.get_action_strength("down_%s" % id) > 0.6)
			#print(parent.regrab == 0)
			#print(!collider.is_grabbed)
			#print()
			if collider.get_node('Label').text =='Ledge_L' and !Input.get_action_strength("down_%s" % id) > 0.6 and parent.regrab == 0 && !collider.is_grabbed:
				#if state_includes([states.AIR]):
					#if parent.velocity.y < 0:
						#return false
				parent.frame = 0
				parent.velocity.x=0
				parent.velocity.y=0
				self.parent.position.x = collider.position.x - 50
				self.parent.position.y = collider.position.y - 5
				parent.turn(false)
				parent.reset_jumps()
				parent.fastfall = false
				#collider.is_grabbed = true
				parent.last_ledge = collider
				return true

			if collider.get_node('Label').text =='Ledge_R' and !Input.get_action_strength("down_%s" % id) > 0.6 and parent.regrab == 0 && !collider.is_grabbed:# and parent.Ledge_Grab_F.get_cast_to().x<0: and not collider.is_grabbed:
				#if state_includes([states.AIR]):
					#if parent.velocity.y < 0:
						#return false
				parent.frame = 0
				parent.velocity.x=0
				parent.velocity.y=0
				self.parent.position.x = collider.position.x + 40
				self.parent.position.y = collider.position.y -5
				parent.turn(true)
				parent.reset_jumps()
				parent.fastfall = false
				#collider.is_grabbed = true
				parent.last_ledge = collider
				return true

		if (parent.Ledge_Grab_B.is_colliding()): 
			var collider = parent.Ledge_Grab_B.get_collider()
			if collider.get_node('Label').text =='Ledge_L' and !Input.get_action_strength("down_%s" % id) > 0.6 and parent.regrab == 0 && !collider.is_grabbed:
				#if state_includes([states.AIR]):
					#if parent.velocity.y < 0:
						#return false
				parent.frame = 0
				parent.velocity.x=0
				parent.velocity.y=0
				self.parent.position.x = collider.position.x - 40
				self.parent.position.y = collider.position.y - 5
				parent.turn(false)
				parent.reset_jumps()
				parent.fastfall = false
				#collider.is_grabbed = true
				parent.last_ledge = collider
				return true

			if collider.get_node('Label').text =='Ledge_R' and !Input.get_action_strength("down_%s" % id) > 0.6 and parent.regrab == 0 && !collider.is_grabbed:
				#if state_includes([states.AIR]):
					#if parent.velocity.y < 0:
						#return false
				parent.frame = 0
				parent.velocity.x=0
				parent.velocity.y=0
				self.parent.position.x = collider.position.x + 40
				self.parent.position.y = collider.position.y - 5
				parent.turn(true)
				parent.reset_jumps()
				parent.fastfall = false
				#collider.is_grabbed = true
				parent.last_ledge = collider
				return true

func TILT():
	if state_includes([states.STAND,states.MOONWALK,states.DASH,states.WALK,states.CROUCH]):
		return true
		
func AERIAL():
	if state_includes([states.AIR,states.DAIR,states.NAIR,states.FAIR,states.UAIR,states.DAIR,states.NEUTRAL_SPECIAL]):
		if !(parent.GroundL.is_colliding() and parent.GroundR.is_colliding()):
			return true
		else:
			return false
			
func SPECIAL():
	if state_includes([states.AIR,states.STAND,states.WALK,states.DASH,states.RUN,states.MOONWALK,states.CROUCH]):
		return true

func exit_state(old_state, new_state):
	pass
	
var kbx
var kby
var hd
var vd
var pos

func can_roll():
	if state_includes([states.STAND,states.WALK,states.DASH,states.RUN,states.MOONWALK,states.CROUCH]):
		return true


func hitfreeze(duration,knockback):
	pos = parent.get_position()
	parent.freezeframes = duration
	kbx = knockback[0]
	kby = knockback[1]
	hd = knockback[2]
	vd = knockback[3]

var temp_body
var temp_state
func grabbed(body,state):
	temp_body = body
	temp_state = state
	
func enter_state(new_state, old_state):
	match new_state:
		states.STAND:
			parent.play_animation("fox_idle")
			parent.state.text = str("STAND")
		states.DASH:
			parent.play_animation("fox_dash")
			parent.state.text = str("DASH")
		states.RUN:
			parent.play_animation("fox_run")
			parent.state.text = str("RUN")
		states.TURN:
			parent.play_animation("fox_turn")
			parent.state.text = str("TURN")
		states.JUMP_SQUAT:
			parent.play_animation("fox_jump_squat")
			parent.state.text = str("JUMP_SQUAT")
		states.SHORT_HOP:
			parent.play_animation("fox_air")
			parent.state.text = str("SHORT_HOP")
		states.FULL_HOP:
			parent.play_animation("fox_air")
			parent.state.text = str("FULL_HOP")
		states.AIR:
			parent.play_animation("fox_air")
			parent.state.text = str("AIR")
		states.LANDING:
			parent.play_animation("fox_landing")
			parent.state.text = str("LANDING")
		states.CROUCH:
			parent.play_animation("fox_crouch")
			parent.state.text = str("CROUCH")
		states.FREEFALL:
			parent.play_animation("fox_free_fall")
			parent.play_animation("FREE_FALL")
		states.AIRDODGE:
			parent.play_animation("fox_air_dodge")
			parent.state.text = str("AIRDODGE")
		states.LEDGE_CATCH:
			parent.play_animation("fox_ledge")
			parent.state.text = str("LEDGE_CATCH")
		states.LEDGE_HOLD:
			parent.play_animation("fox_ledge")
			parent.state.text = str("LEDGE_HOLD")
		states.LEDGE_CLIMB:
			parent.play_animation("fox_roll")
			parent.state.text = str("LEDGE_CLIMB")
		states.LEDGE_JUMP:
			parent.play_animation("fox_air")
			parent.state.text = str("LEDGE_JUMP")
		states.LEDGE_ROLL:
			parent.play_animation("fox_roll")
			parent.state.text = str("LEDGE_ROLL")
		states.HITSTUN:
			parent.play_animation("fox_hitstun")
			parent.state.text = str("HITSTUN")
		states.HITFREEZE:
			parent.play_animation('fox_hitstun')
			parent.state.text = str('HITFREEZE')
		states.GRABBED:
			parent.play_animation('fox_hitstun')
			parent.state.text = str('GRABBED')
		states.GRAB:
			parent.play_animation('fox_grab')
			parent.state.text = str('GRAB')
		states.THROW:
			parent.play_animation('fox_throw')
			parent.state.text = str('THROW')
		states.DOWN_TILT:
			parent.play_animation('fox_down_tilt')
			parent.state.text = str('DOWN_TILT')
		states.UP_TILT:
			parent.play_animation('fox_up_tilt')
			parent.state.text = str('UP_TILT')
		states.FORWARD_TILT:
			parent.play_animation('fox_forward_tilt')
			parent.state.text = str('FORWARD_TILT')
		states.DOWN_SMASH:
			parent.play_animation('fox_down_smash')
			parent.state.text = str('DOWN_SMASH')
		states.FORWARD_SMASH:
			parent.play_animation('fox_forward_smash')
			parent.state.text = str('FORWARD_SMASH')
		states.UP_SMASH:
			parent.play_animation('fox_up_smash')
			parent.state.text = str('UP_SMASH')
		states.DASH_ATTACK:
			parent.play_animation('fox_dash_attack')
			parent.state.text = str('DASH_ATTACK')
		states.STRONG_DASH_ATTACK:
			parent.play_animation('fox_strong_dash_attack')
			parent.state.text = str('STRONG_DASH_ATTACK')
		states.BAIR:
			parent.play_animation('fox_back_air')
			parent.state.text = str('BAIR')
		states.FAIR:
			parent.play_animation('fox_forward_air')
			parent.state.text = str('FAIR')
		states.DAIR:
			parent.play_animation('fox_down_air')
			parent.state.text = str('DAIR')
		states.UAIR:
			parent.play_animation('fox_up_air')
			parent.state.text = str('UAIR')
		states.NAIR:
			parent.play_animation('fox_neutral_air')
			parent.state.text = str('NAIR')
		states.UP_SPECIAL:
			parent.play_animation('fox_up_special')
			parent.state.text = 'UP_SPECIAL'
		states.NEUTRAL_SPECIAL:
			parent.play_animation('fox_neutral_special')
			parent.state.text = str('NEUTRAL_SPECIAL')
		states.SHIELD:
			parent.play_animation('fox_shield')
			parent.state.text = str('SHIELD')
		states.ROLL_RIGHT:
			parent.play_animation('fox_roll')
			parent.state.text = str('ROLL_RIGHT')
		states.ROLL_LEFT:
			parent.play_animation('fox_roll')
			parent.state.text = str('ROLL_LEFT')
