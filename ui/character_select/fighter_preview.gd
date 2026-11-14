extends PanelContainer
## Big preview card for one player on the character select screen: portrait,
## fighter name and a CHOOSING / READY status. Border and tint follow `accent`.

const FONT: Font = preload("res://ui/title_screen/fonts/LilitaOne-Regular.ttf")
const OUTLINE := Color("#1a0505")

@export var player_label := "P1"
@export var accent := Color("#ff4a3a")

var _card: StyleBoxFlat
var _portrait: TextureRect
var _question: Label
var _name: Label
var _status: Label
var _key := ""
var _pop: Tween

func _ready() -> void:
	for c in get_children():
		c.queue_free()
	_card = StyleBoxFlat.new()
	_card.set_corner_radius_all(14)
	_card.set_content_margin_all(16)
	_card.shadow_color = Color(0, 0, 0, 0.55)
	_card.shadow_size = 8
	_card.shadow_offset = Vector2(0, 5)
	add_theme_stylebox_override("panel", _card)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	add_child(box)

	box.add_child(_label(player_label, 38, accent.lightened(0.35), HORIZONTAL_ALIGNMENT_CENTER))

	_portrait = TextureRect.new()
	_portrait.custom_minimum_size = Vector2(320, 226)
	_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_portrait.pivot_offset = _portrait.custom_minimum_size / 2.0
	box.add_child(_portrait)

	_question = _label("?", 150, Color("#ffe14a"), HORIZONTAL_ALIGNMENT_CENTER)
	_question.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_question.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_portrait.add_child(_question)

	_name = _label("", 56, Color("#ffe9c4"), HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(_name)
	_status = _label("", 34, accent.lightened(0.35), HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(_status)
	set_locked(false)

## Show a fighter (or the Random tile, with a null texture). `key` identifies
## what is shown, so the portrait only pops when it actually changes.
func show_fighter(key: String, display_name: String, tex: Texture2D) -> void:
	_name.text = display_name
	_portrait.texture = tex
	_question.visible = tex == null
	if key == _key:
		return
	_key = key
	if _pop:
		_pop.kill()
	_portrait.scale = Vector2(1.12, 1.12)
	_pop = create_tween()
	_pop.tween_property(_portrait, "scale", Vector2.ONE, 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func set_locked(locked: bool) -> void:
	_status.text = "READY!" if locked else "CHOOSING..."
	_status.add_theme_color_override("font_color", Color("#ffe14a") if locked else accent.lightened(0.35))
	_card.bg_color = accent.darkened(0.55) if locked else Color(0.1, 0.02, 0.02, 0.88)
	_card.set_border_width_all(10 if locked else 4)
	_card.border_width_bottom = 12 if locked else 8
	_card.border_color = accent.lightened(0.2) if locked else accent

func _label(text: String, size: int, color: Color, align: HorizontalAlignment) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = align
	l.add_theme_font_override("font", FONT)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", OUTLINE)
	l.add_theme_constant_override("outline_size", 8)
	return l
