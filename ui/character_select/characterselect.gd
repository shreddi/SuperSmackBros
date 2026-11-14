extends Control
## Two-player character select. Each player moves a coloured cursor around a
## wrapping roster grid with their direction keys, locks in with attack and
## backs out with special. When both are locked in a short countdown starts
## the match (and cancels if either player backs out).
##
## Roster contents come from characters/roster.gd; a Random tile is appended.

const Roster = preload("res://characters/roster.gd")
const FONT: Font = preload("res://ui/title_screen/fonts/LilitaOne-Regular.ttf")
const OUTLINE := Color("#1a0505")
const TILE_SIZE := Vector2(160, 120)
const COUNTDOWN_SECONDS := 3.0
const RANDOM_KEY := "random"
## Cursor colours match the accent on each player's preview and controls card.
const PLAYER_COLORS := {1: Color("#ff4a3a"), 2: Color("#4d8cff")}

@export_file("*.tscn") var stage_path := "res://stages/test_stage.tscn"

@onready var _grid: GridContainer = $Columns/Center/Grid
@onready var _status: Label = $Columns/Center/Status
@onready var _previews := {1: $Columns/P1Column/P1Preview, 2: $Columns/P2Column/P2Preview}

var _tile_count := 0
var _cursor := {1: 0, 2: 0}
## Roster index each player locked in (Random already resolved), or -1.
var _locked := {1: -1, 2: -1}
var _borders := {1: [], 2: []}
var _tags := {1: [], 2: []}
var _countdown := -1.0
var _starting := false
var _sound: AudioStreamPlayer

func _ready() -> void:
	_sound = AudioStreamPlayer.new()
	add_child(_sound)
	for entry in Roster.FIGHTERS:
		_add_tile(entry)
	_add_tile({})  # Random
	_tile_count = _grid.get_child_count()
	_cursor[2] = mini(1, _tile_count - 1)
	_refresh()

func _process(delta: float) -> void:
	if _countdown < 0.0 or _starting:
		return
	_countdown -= delta
	if _countdown <= 0.0:
		_start_match()
	else:
		_status.text = "FIGHT IN %d" % ceili(_countdown)

func _unhandled_input(event: InputEvent) -> void:
	if _starting:
		return
	for p in [1, 2]:
		if event.is_action_pressed("left_%d" % p):
			_move(p, -1)
		elif event.is_action_pressed("right_%d" % p):
			_move(p, 1)
		elif event.is_action_pressed("up_%d" % p):
			_move_vertical(p, -1)
		elif event.is_action_pressed("down_%d" % p):
			_move_vertical(p, 1)
		elif event.is_action_pressed("attack_%d" % p):
			_lock_in(p)
		elif event.is_action_pressed("special_%d" % p):
			_back_out(p)

# --- Cursor movement -------------------------------------------------------

func _move(p: int, step: int) -> void:
	if _locked[p] >= 0:
		return
	_cursor[p] = posmod(_cursor[p] + step, _tile_count)
	_refresh()

func _move_vertical(p: int, dir: int) -> void:
	if _locked[p] >= 0:
		return
	var cols := _grid.columns
	var idx: int = _cursor[p]
	if dir > 0:
		idx += cols
		if idx >= _tile_count:
			idx %= cols  # wrap to the top of the same column
	else:
		idx -= cols
		if idx < 0:
			idx = _cursor[p]  # wrap to the bottom of the same column
			while idx + cols < _tile_count:
				idx += cols
	_cursor[p] = idx
	_refresh()

# --- Lock in / back out ----------------------------------------------------

func _lock_in(p: int) -> void:
	if _locked[p] >= 0:
		return
	var pick: int = _cursor[p]
	if pick >= Roster.FIGHTERS.size():  # Random tile
		pick = randi() % Roster.FIGHTERS.size()
	_locked[p] = pick
	var sound_path: String = Roster.FIGHTERS[pick].get("select_sound", "")
	if sound_path != "":
		_sound.stream = load(sound_path)
		_sound.play()
	_after_lock_change()

func _back_out(p: int) -> void:
	if _locked[p] < 0:
		return
	_locked[p] = -1
	_after_lock_change()

func _after_lock_change() -> void:
	_countdown = COUNTDOWN_SECONDS if _locked[1] >= 0 and _locked[2] >= 0 else -1.0
	_refresh()

func _start_match() -> void:
	_starting = true
	Globals.player1 = _locked[1]
	Globals.player2 = _locked[2]
	get_tree().change_scene_to_file(stage_path)

# --- Display ---------------------------------------------------------------

func _refresh() -> void:
	for p in [1, 2]:
		var locked: bool = _locked[p] >= 0
		for i in _tile_count:
			var here: bool = i == _cursor[p]
			_borders[p][i].visible = here
			_tags[p][i].visible = here
			var box: StyleBoxFlat = _borders[p][i].get_theme_stylebox("panel")
			box.draw_center = locked
		var preview = _previews[p]
		preview.set_locked(locked)
		if locked:
			var e: Dictionary = Roster.FIGHTERS[_locked[p]]
			preview.show_fighter(e.id, e.name, load(e.portrait))
		elif _cursor[p] >= Roster.FIGHTERS.size():
			preview.show_fighter(RANDOM_KEY, "RANDOM", null)
		else:
			var e: Dictionary = Roster.FIGHTERS[_cursor[p]]
			preview.show_fighter(e.id, e.name, load(e.portrait))
	if _countdown >= 0.0:
		_status.text = "FIGHT IN %d" % ceili(_countdown)
	elif _locked[1] >= 0 or _locked[2] >= 0:
		_status.text = "WAITING FOR P%d..." % (2 if _locked[1] >= 0 else 1)
	else:
		_status.text = "LOCK IN WITH ATTACK"

func _add_tile(entry: Dictionary) -> void:
	var tile := Control.new()
	tile.custom_minimum_size = TILE_SIZE
	_grid.add_child(tile)

	var frame := Panel.new()
	_fill(frame, 0)
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.1, 0.02, 0.02, 0.88)
	bg.set_border_width_all(3)
	bg.border_color = Color("#5a2a1a")
	bg.set_corner_radius_all(8)
	frame.add_theme_stylebox_override("panel", bg)
	tile.add_child(frame)

	if entry.is_empty():
		var q := Label.new()
		q.text = "?"
		q.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		q.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		q.add_theme_font_override("font", FONT)
		q.add_theme_font_size_override("font_size", 80)
		q.add_theme_color_override("font_color", Color("#ffe14a"))
		q.add_theme_color_override("font_outline_color", OUTLINE)
		q.add_theme_constant_override("outline_size", 10)
		_fill(q, 0)
		tile.add_child(q)
	else:
		var art := TextureRect.new()
		art.texture = load(entry.portrait)
		art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_fill(art, 6)
		tile.add_child(art)

	for p in [1, 2]:
		var color: Color = PLAYER_COLORS[p]
		var ring := Panel.new()
		_fill(ring, 0 if p == 1 else 7)
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(color, 0.3)
		sb.draw_center = false
		sb.set_border_width_all(6)
		sb.border_color = color
		sb.set_corner_radius_all(8)
		ring.add_theme_stylebox_override("panel", sb)
		ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tile.add_child(ring)
		_borders[p].append(ring)

		var tag := Label.new()
		tag.text = "P%d" % p
		tag.add_theme_font_override("font", FONT)
		tag.add_theme_font_size_override("font_size", 26)
		tag.add_theme_color_override("font_color", Color.WHITE)
		tag.add_theme_color_override("font_outline_color", color.darkened(0.5))
		tag.add_theme_constant_override("outline_size", 8)
		tag.position = Vector2(10, 6) if p == 1 else Vector2(TILE_SIZE.x - 46, 6)
		tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tile.add_child(tag)
		_tags[p].append(tag)

func _fill(c: Control, inset: float) -> void:
	c.anchor_right = 1.0
	c.anchor_bottom = 1.0
	c.offset_left = inset
	c.offset_top = inset
	c.offset_right = -inset
	c.offset_bottom = -inset
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
