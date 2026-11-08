extends FighterStateMachine
## Martyo's state machine. Shared logic lives in FighterStateMachine; this only
## holds what is Martyo-specific.

func _init():
	animations = {
		"STAND": "martyo_idle",
		"DASH": "martyo_run",
		"RUN": "martyo_run",
		"TURN": "martyo_turn",
		"JUMP_SQUAT": "martyo_jump_squat",
		"SHORT_HOP": "",
		"FULL_HOP": "",
		"AIR": "martyo_air",
		"LANDING": "martyo_landing",
		"CROUCH": "martyo_crouch",
		"FREEFALL": "",
		"AIRDODGE": "martyo_airdodge_right",
		"LEDGE_CATCH": "martyo_ledge",
		"LEDGE_HOLD": "martyo_ledge",
		"LEDGE_CLIMB": "martyo_roll",
		"LEDGE_JUMP": "",
		"LEDGE_ROLL": "martyo_roll",
		"HITSTUN": "martyo_hurt",
		"HITFREEZE": "martyo_hurt",
		"GRABBED": "martyo_hurt",
		"GRAB": "martyo_grab",
		"THROW": "martyo_throw",
		"DOWN_TILT": "martyo_dtilt",
		"UP_TILT": "martyo_utilt",
		"FORWARD_TILT": "martyo_ftilt",
		"UP_SMASH": "martyo_up_smash",
		"FORWARD_SMASH": "martyo_fsmash",
		"DOWN_SMASH": "martyo_down_smash",
		"DASH_ATTACK": "martyo_dash_attack",
		"STRONG_DASH_ATTACK": "martyo_strong_dash_attack",
		"BAIR": "martyo_bair",
		"FAIR": "martyo_fair",
		"DAIR": "martyo_dair",
		"UAIR": "martyo_uair",
		"NAIR": "martyo_nair",
		"NEUTRAL_SPECIAL": "martyo_grab",
		"UP_SPECIAL": "martyo_upspecial",
		"SHIELD": "martyo_sheild",
		"ROLL_RIGHT": "martyo_roll",
		"ROLL_LEFT": "martyo_roll",
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
