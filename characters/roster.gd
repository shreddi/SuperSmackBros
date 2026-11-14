extends RefCounted
## The list of playable fighters, in character-select order. The select screen
## and the stage both read this, so adding a character means adding one entry.
##
## `Globals.player1` / `Globals.player2` hold an index into FIGHTERS.
##
## Keys: id, name (shown on the select screen), scene (the Fighter scene),
## portrait (select screen / HUD art) and optionally select_sound (played when
## a player locks this fighter in).

const FIGHTERS := [
	{
		"id": "fux",
		"name": "FUX",
		"scene": "res://characters/fux/fux.tscn",
		"portrait": "res://characters/fux/charselect.png",
	},
	{
		"id": "martyo",
		"name": "MARTYO",
		"scene": "res://characters/martyo/martyo.tscn",
		"portrait": "res://characters/martyo/sprites/portrait.png",
	},
]

## Entry for a roster index. A missing or out-of-range index (nothing picked
## yet) falls back to `fallback`.
static func entry(index, fallback := 0) -> Dictionary:
	if index is int and index >= 0 and index < FIGHTERS.size():
		return FIGHTERS[index]
	return FIGHTERS[clampi(fallback, 0, FIGHTERS.size() - 1)]
