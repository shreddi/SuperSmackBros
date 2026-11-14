@tool
extends PanelContainer
## Control-scheme card for one player: coloured header plus action / keycap rows.

const FONT: Font = preload("res://ui/title_screen/fonts/LilitaOne-Regular.ttf")

@export var player_label := "P1"
@export var accent := Color("#ff4a3a")
## Each entry is [action, keys].
@export var rows: Array = []

func _ready() -> void:
	for c in get_children():
		c.queue_free()
	var card := StyleBoxFlat.new()
	card.bg_color = Color(0.1, 0.02, 0.02, 0.88)
	card.set_border_width_all(4)
	card.border_width_bottom = 8
	card.border_color = accent
	card.set_corner_radius_all(14)
	card.set_content_margin_all(16)
	card.shadow_color = Color(0, 0, 0, 0.55)
	card.shadow_size = 8
	card.shadow_offset = Vector2(0, 5)
	add_theme_stylebox_override("panel", card)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	add_child(box)

	var head := Label.new()
	head.text = player_label + " CONTROLS"
	head.add_theme_font_override("font", FONT)
	head.add_theme_font_size_override("font_size", 38)
	head.add_theme_color_override("font_color", accent.lightened(0.35))
	head.add_theme_color_override("font_outline_color", Color("#1a0505"))
	head.add_theme_constant_override("outline_size", 8)
	box.add_child(head)

	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 18)
	grid.add_theme_constant_override("v_separation", 6)
	box.add_child(grid)

	for r in rows:
		var action := Label.new()
		action.text = r[0]
		action.add_theme_font_size_override("font_size", 22)
		action.add_theme_color_override("font_color", Color("#ffe9c4"))
		action.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		grid.add_child(action)
		grid.add_child(_keycap(r[1]))

func _keycap(text: String) -> Control:
	var chip := PanelContainer.new()
	chip.size_flags_horizontal = Control.SIZE_SHRINK_END
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("#2a0d08")
	sb.border_color = Color("#ffb000")
	sb.set_border_width_all(2)
	sb.border_width_bottom = 5
	sb.set_corner_radius_all(6)
	sb.content_margin_left = 10
	sb.content_margin_right = 10
	sb.content_margin_top = 1
	sb.content_margin_bottom = 1
	chip.add_theme_stylebox_override("panel", sb)
	var l := Label.new()
	l.text = text
	l.add_theme_font_override("font", FONT)
	l.add_theme_font_size_override("font_size", 22)
	l.add_theme_color_override("font_color", Color("#ffe14a"))
	chip.add_child(l)
	return chip
