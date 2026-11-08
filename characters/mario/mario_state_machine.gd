extends FighterStateMachine
## Mario's state machine. Shared logic lives in FighterStateMachine; this only
## holds what is Mario-specific.

func _init():
	animations = {
		"STAND": "mario_idle",
		"DASH": "mario_run",
		"RUN": "mario_run",
		"TURN": "mario_turn",
		"JUMP_SQUAT": "mario_jump_squat",
		"SHORT_HOP": "",
		"FULL_HOP": "",
		"AIR": "mario_air",
		"LANDING": "mario_landing",
		"CROUCH": "mario_crouch",
		"FREEFALL": "",
		"AIRDODGE": "mario_airdodge_right",
		"LEDGE_CATCH": "mario_ledge",
		"LEDGE_HOLD": "mario_ledge",
		"LEDGE_CLIMB": "mario_roll",
		"LEDGE_JUMP": "",
		"LEDGE_ROLL": "mario_roll",
		"HITSTUN": "mario_hurt",
		"HITFREEZE": "mario_hurt",
		"GRABBED": "mario_hurt",
		"GRAB": "mario_grab",
		"THROW": "mario_throw",
		"DOWN_TILT": "mario_dtilt",
		"UP_TILT": "mario_utilt",
		"FORWARD_TILT": "mario_ftilt",
		"UP_SMASH": "mario_up_smash",
		"FORWARD_SMASH": "mario_fsmash",
		"DOWN_SMASH": "mario_down_smash",
		"DASH_ATTACK": "mario_dash_attack",
		"STRONG_DASH_ATTACK": "mario_strong_dash_attack",
		"BAIR": "mario_bair",
		"FAIR": "mario_fair",
		"DAIR": "mario_dair",
		"UAIR": "mario_uair",
		"NAIR": "mario_nair",
		"NEUTRAL_SPECIAL": "mario_grab",
		"UP_SPECIAL": "mario_upspecial",
		"SHIELD": "mario_sheild",
		"ROLL_RIGHT": "mario_roll",
		"ROLL_LEFT": "mario_roll",
	}

func _ledge_blocked_states() -> Array:
	return [states.DAIR, states.HITSTUN]

func _state_forward_smash():
	if parent.frame == 0:
		parent.FORWARD_SMASH()
	if parent.frame >= 1:
			apply_traction(3)
	if parent.FORWARD_SMASH() == true:
		if Input.is_action_pressed("down_%s" % id):
			parent.newframe()
			return states.CROUCH
		else:
			parent.newframe()
			return states.STAND
	return null

func _state_down_smash():
	if parent.frame == 0:
		parent.DOWN_SMASH()
	if parent.frame >= 1:
			apply_traction(3)
	if parent.DOWN_SMASH() == true:
		if Input.is_action_pressed("down_%s" % id):
			parent.newframe()
			return states.CROUCH
		else:
			parent.newframe()
			return states.STAND
	return null

func _state_dash_attack():
	if parent.frame == 0:
		parent.DASH_ATTACK()
	if parent.frame == 1:
			parent.velocity.y -= 500
			if parent.velocity.x > 0:
				parent.velocity.x += 500
			elif parent.velocity.x < 0:
				parent.velocity.x -= 500
	if parent.frame >= 1:
		parent.velocity.y += 20
		if parent.velocity.x > 0:
			parent.velocity.x -= 15
		elif parent.velocity.x < 0:
			parent.velocity.x += 15
	if parent.DASH_ATTACK() == true:
		parent.newframe()
		return states.AIR
	return null

func _state_strong_dash_attack():
	if parent.frame == 0:
		parent.STRONG_DASH_ATTACK()
	if parent.frame == 1:
			parent.velocity.y -= 400
			if parent.velocity.x > 0:
				parent.velocity.x += 450
			elif parent.velocity.x < 0:
				parent.velocity.x -= 450
	if parent.frame >= 1:
		parent.velocity.y += 40
		if parent.velocity.x > 0:
			parent.velocity.x -= 15
		elif parent.velocity.x < 0:
			parent.velocity.x += 15
	if parent.STRONG_DASH_ATTACK() == true:
		parent.newframe()
		return states.AIR
	return null

func _state_dair():
	if parent.frame == 0:
		parent.DAIR()
	if parent.frame < 13 or parent.frame > 35:
		AIRMOVEMENT()
	if parent.frame >= 13 and parent.frame <= 18:
		parent.velocity = Vector2(0,0)
	if parent.frame == 19:
		parent.velocity = Vector2(0,3000)
	if parent.frame >= 30 and parent.frame < 38:
		parent.velocity = Vector2(0,0)
	if parent.DAIR() == true:
		parent.lag_frames = 0
		parent.newframe()
		return states.AIR
	else:
		parent.lag_frames = 15
	return null

func _state_up_special():
	parent.special = false
	AIRMOVEMENT()
	if parent.frame == 3:
		parent.velocity.y = -2500
		parent.UP_SPECIAL()
	if parent.UP_SPECIAL() == true:
		return states.AIR
	return null
