extends PanelContainer
## In-game HUD card for one player: framed portrait, damage percent that
## shifts yellow -> orange -> red as it climbs, and a row of stock pips.

const FONT: Font = preload("res://ui/title_screen/fonts/LilitaOne-Regular.ttf")
const OUTLINE := Color("#1a0505")

@export var player_label := "P1"
@export var accent := Color("#ff4a3a")

var _portrait: TextureRect
var _percent: Label
var _pips: Control
var _shown_percent := -1
var _stocks := 0
var _max_stocks := 0
var _punch: Tween

func _ready() -> void:
	for c in get_children():
		c.queue_free()
	var card := StyleBoxFlat.new()
	card.bg_color = Color(0.1, 0.02, 0.02, 0.9)
	card.set_border_width_all(5)
	card.border_width_bottom = 10
	card.border_color = accent
	card.set_corner_radius_all(16)
	card.set_content_margin_all(12)
	card.shadow_color = Color(0, 0, 0, 0.6)
	card.shadow_size = 10
	card.shadow_offset = Vector2(0, 6)
	add_theme_stylebox_override("panel", card)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 18)
	add_child(row)

	# Portrait in its own accent-bordered frame.
	var frame := PanelContainer.new()
	var fs := StyleBoxFlat.new()
	fs.bg_color = Color(0.2, 0.05, 0.04)
	fs.border_color = accent
	fs.set_border_width_all(4)
	fs.set_corner_radius_all(10)
	fs.set_content_margin_all(0)
	fs.set_expand_margin_all(0)
	frame.add_theme_stylebox_override("panel", fs)
	frame.custom_minimum_size = Vector2(130, 130)
	frame.clip_contents = true
	row.add_child(frame)
	_portrait = TextureRect.new()
	_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	frame.add_child(_portrait)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 0)
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(col)

	var tag := Label.new()
	tag.text = player_label
	tag.add_theme_font_override("font", FONT)
	tag.add_theme_font_size_override("font_size", 30)
	tag.add_theme_color_override("font_color", accent.lightened(0.35))
	tag.add_theme_color_override("font_outline_color", OUTLINE)
	tag.add_theme_constant_override("outline_size", 8)
	col.add_child(tag)

	_percent = Label.new()
	_percent.add_theme_font_override("font", FONT)
	_percent.add_theme_font_size_override("font_size", 84)
	_percent.add_theme_color_override("font_outline_color", OUTLINE)
	_percent.add_theme_color_override("font_shadow_color", Color(0.35, 0.05, 0.02))
	_percent.add_theme_constant_override("outline_size", 16)
	_percent.add_theme_constant_override("shadow_offset_y", 5)
	_percent.pivot_offset = Vector2(60, 50)
	col.add_child(_percent)

	_pips = Control.new()
	_pips.custom_minimum_size = Vector2(0, 28)
	_pips.draw.connect(_draw_pips)
	col.add_child(_pips)
	set_percent(0)

func set_portrait(tex: Texture2D) -> void:
	_portrait.texture = tex

func set_stocks(n: int) -> void:
	if n == _stocks and _max_stocks > 0:
		return
	_stocks = n
	_max_stocks = maxi(_max_stocks, n)
	_pips.queue_redraw()

func set_percent(p: int) -> void:
	if p == _shown_percent:
		return
	var went_up := p > _shown_percent and _shown_percent >= 0
	_shown_percent = p
	_percent.text = "%d%%" % p
	_percent.add_theme_color_override("font_color", percent_color(p))
	if went_up:
		if _punch:
			_punch.kill()
		_percent.scale = Vector2(1.25, 1.25)
		_punch = create_tween()
		_punch.tween_property(_percent, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

## Pale yellow at 0, orange by ~100, red by ~200, dark red beyond.
static func percent_color(p: float) -> Color:
	var stops := [
		[0.0, Color("#ffe97a")],
		[50.0, Color("#ffc21a")],
		[100.0, Color("#ff8a1a")],
		[150.0, Color("#ff4a14")],
		[200.0, Color("#e0140a")],
		[300.0, Color("#a80808")],
	]
	if p <= stops[0][0]:
		return stops[0][1]
	for i in range(1, stops.size()):
		if p <= stops[i][0]:
			var t: float = (p - stops[i - 1][0]) / (stops[i][0] - stops[i - 1][0])
			return stops[i - 1][1].lerp(stops[i][1], t)
	return stops[-1][1]

func _draw_pips() -> void:
	var r := 11.0
	var gap := 8.0
	for i in _max_stocks:
		var c := Vector2(r + 2 + i * (r * 2 + gap), _pips.size.y / 2.0)
		var alive := i < _stocks
		_pips.draw_circle(c, r + 3, OUTLINE)
		_pips.draw_circle(c, r, Color("#ffb000") if alive else Color(0.25, 0.1, 0.08))
		if alive:
			_pips.draw_circle(c + Vector2(0, -2), r * 0.55, Color("#ffe97a"))
