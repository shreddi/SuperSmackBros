extends FighterStateMachine
## Fox's state machine. Shared logic lives in FighterStateMachine; this only
## holds what is Fox-specific.

func _init():
	animations = {
		"STAND": "fox_idle",
		"DASH": "fox_dash",
		"RUN": "fox_run",
		"TURN": "fox_turn",
		"JUMP_SQUAT": "",
		"SHORT_HOP": "fox_air",
		"FULL_HOP": "fox_air",
		"AIR": "fox_air",
		"LANDING": "fox_landing",
		"CROUCH": "fox_crouch",
		"FREEFALL": "fox_free_fall",
		"AIRDODGE": "fox_air_dodge",
		"LEDGE_CATCH": "fox_ledge",
		"LEDGE_HOLD": "fox_ledge",
		"LEDGE_CLIMB": "fox_roll",
		"LEDGE_JUMP": "fox_air",
		"LEDGE_ROLL": "fox_roll",
		"HITSTUN": "fox_hitstun",
		"HITFREEZE": "fox_hitstun",
		"GRABBED": "fox_hitstun",
		"GRAB": "fox_grab",
		"THROW": "fox_throw",
		"DOWN_TILT": "fox_down_tilt",
		"UP_TILT": "fox_up_tilt",
		"FORWARD_TILT": "fox_forward_tilt",
		"DOWN_SMASH": "fox_down_smash",
		"FORWARD_SMASH": "fox_forward_smash",
		"UP_SMASH": "fox_up_smash",
		"DASH_ATTACK": "fox_dash_attack",
		"STRONG_DASH_ATTACK": "fox_strong_dash_attack",
		"BAIR": "fox_back_air",
		"FAIR": "fox_forward_air",
		"DAIR": "fox_down_air",
		"UAIR": "fox_up_air",
		"NAIR": "fox_neutral_air",
		"UP_SPECIAL": "fox_up_special",
		"NEUTRAL_SPECIAL": "fox_neutral_special",
		"SHIELD": "fox_shield",
		"ROLL_RIGHT": "fox_roll",
		"ROLL_LEFT": "fox_roll",
	}

## Fox's up special rotates the sprite; reset it whenever he is not in it.
func _before_actions():
	if state != states.UP_SPECIAL:
		parent.sprite.rotation_degrees = 0
