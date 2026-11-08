extends FighterStateMachine
## Fux's state machine. Shared logic lives in FighterStateMachine; this only
## holds what is Fux-specific.

func _init():
	animations = {
		"STAND": "fux_idle",
		"DASH": "fux_dash",
		"RUN": "fux_run",
		"TURN": "fux_turn",
		"JUMP_SQUAT": "",
		"SHORT_HOP": "fux_air",
		"FULL_HOP": "fux_air",
		"AIR": "fux_air",
		"LANDING": "fux_landing",
		"CROUCH": "fux_crouch",
		"FREEFALL": "fux_free_fall",
		"AIRDODGE": "fux_air_dodge",
		"LEDGE_CATCH": "fux_ledge",
		"LEDGE_HOLD": "fux_ledge",
		"LEDGE_CLIMB": "fux_roll",
		"LEDGE_JUMP": "fux_air",
		"LEDGE_ROLL": "fux_roll",
		"HITSTUN": "fux_hitstun",
		"HITFREEZE": "fux_hitstun",
		"GRABBED": "fux_hitstun",
		"GRAB": "fux_grab",
		"THROW": "fux_throw",
		"DOWN_TILT": "fux_down_tilt",
		"UP_TILT": "fux_up_tilt",
		"FORWARD_TILT": "fux_forward_tilt",
		"DOWN_SMASH": "fux_down_smash",
		"FORWARD_SMASH": "fux_forward_smash",
		"UP_SMASH": "fux_up_smash",
		"DASH_ATTACK": "fux_dash_attack",
		"STRONG_DASH_ATTACK": "fux_strong_dash_attack",
		"BAIR": "fux_back_air",
		"FAIR": "fux_forward_air",
		"DAIR": "fux_down_air",
		"UAIR": "fux_up_air",
		"NAIR": "fux_neutral_air",
		"UP_SPECIAL": "fux_up_special",
		"NEUTRAL_SPECIAL": "fux_neutral_special",
		"SHIELD": "fux_shield",
		"ROLL_RIGHT": "fux_roll",
		"ROLL_LEFT": "fux_roll",
	}

## Fux's up special rotates the sprite; reset it whenever he is not in it.
func _before_actions():
	if state != states.UP_SPECIAL:
		parent.sprite.rotation_degrees = 0
