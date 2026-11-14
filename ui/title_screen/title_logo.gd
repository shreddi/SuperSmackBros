extends Control
## Animated "SUPER SMACK BROS" logo drawn in code so it stays crisp at any size.
## Intro: each word slams in with screen shake and a burst of sparks. After that
## the logo floats gently and a shine sweeps across the lettering.

const FONT: Font = preload("res://ui/title_screen/fonts/LilitaOne-Regular.ttf")
const FILL_SHADER: Shader = preload("res://ui/title_screen/title_fill.gdshader")

const OUTLINE := Color("#1a0505")
const SHADOW := Color("#5a0d04")
const SLAM_TIME := 0.3
const IDLE_START := 1.6
const SHINE_PERIOD := 3.4

# y = vertical centre of the word inside this control.
const WORDS := [
	{"text": "SUPER", "size": 150, "y": 120.0, "delay": 0.15, "top": "#fff6b8", "bottom": "#ffb000"},
	{"text": "SMACK", "size": 290, "y": 330.0, "delay": 0.55, "top": "#ffe650", "bottom": "#ff3a10"},
	{"text": "BROS", "size": 200, "y": 560.0, "delay": 0.95, "top": "#fff6b8", "bottom": "#ffb000"},
]
const TILT := -0.045

var t := 0.0
var shake := 0.0
var sparks: Array = []
var _words: Array = [] # {root, fill, mat, hit}

func _ready() -> void:
	custom_minimum_size = Vector2(1000, 700)
	clip_contents = false
	for i in WORDS.size():
		_words.append(_make_word(WORDS[i]))

func _make_word(w: Dictionary) -> Dictionary:
	var fs: int = w.size
	var tw := FONT.get_string_size(w.text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var asc := FONT.get_ascent(fs)
	var desc := FONT.get_descent(fs)
	var h := asc + desc
	var root := Control.new()
	root.size = Vector2(tw, h)
	root.pivot_offset = root.size / 2.0
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	var back := Control.new()
	back.size = root.size
	back.mouse_filter = Control.MOUSE_FILTER_IGNORE
	back.draw.connect(func():
		var base := Vector2(0, asc)
		var depth := int(fs * 0.05)
		for d in range(depth, 0, -1):
			FONT.draw_string(back.get_canvas_item(), base + Vector2(0, d), w.text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, SHADOW)
		FONT.draw_string_outline(back.get_canvas_item(), base + Vector2(0, depth * 0.5), w.text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, int(fs * 0.08), OUTLINE)
		FONT.draw_string(back.get_canvas_item(), base + Vector2(0, depth * 0.5), w.text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, OUTLINE))
	root.add_child(back)

	var fill := Control.new()
	fill.size = root.size
	fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var mat := ShaderMaterial.new()
	mat.shader = FILL_SHADER
	mat.set_shader_parameter("top_color", Color(w.top))
	mat.set_shader_parameter("bottom_color", Color(w.bottom))
	mat.set_shader_parameter("y_top", asc * 0.25)
	mat.set_shader_parameter("y_bottom", asc)
	mat.set_shader_parameter("width", tw)
	fill.material = mat
	fill.draw.connect(func():
		FONT.draw_string(fill.get_canvas_item(), Vector2(0, asc), w.text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color.WHITE))
	root.add_child(fill)
	root.visible = false
	return {"root": root, "mat": mat, "hit": false, "size": root.size}

func _process(delta: float) -> void:
	t += delta
	shake = maxf(0.0, shake - delta * 30.0)
	var jitter := Vector2(randf_range(-1, 1), randf_range(-1, 1)) * shake
	for i in WORDS.size():
		_animate_word(i, jitter)
	for s in sparks:
		s.pos += s.vel * delta
		s.vel.y += 1000.0 * delta
		s.life -= delta
	sparks = sparks.filter(func(s): return s.life > 0.0)
	queue_redraw()

func _animate_word(i: int, jitter: Vector2) -> void:
	var w: Dictionary = WORDS[i]
	var d: Dictionary = _words[i]
	var root: Control = d.root
	var p := clampf((t - w.delay) / SLAM_TIME, 0.0, 1.0)
	root.visible = p > 0.0
	if not root.visible:
		return
	if p >= 1.0 and not d.hit:
		d.hit = true
		shake = 16.0 if i == 1 else 9.0
		_burst(i)
	# Slam: starts huge and transparent, snaps down with a slight overshoot.
	var e := _ease_out_back(p)
	var s := lerpf(2.8, 1.0, e)
	root.scale = Vector2(s, s)
	root.modulate.a = clampf(p * 3.0, 0.0, 1.0)
	var bob := sin(t * 1.8 + i * 0.9) * 5.0 if t > IDLE_START else 0.0
	root.rotation = TILT
	root.position = Vector2(size.x / 2.0, w.y + bob) - d.size / 2.0 + jitter
	# Staggered shine sweep, repeating.
	var cyc := fmod(t - IDLE_START - i * 0.12, SHINE_PERIOD)
	var sweep := -1.0
	if t > IDLE_START and cyc >= 0.0 and cyc < 0.7:
		sweep = cyc / 0.7 * 1.3 - 0.15
	d.mat.set_shader_parameter("shine_pos", sweep)

func _burst(i: int) -> void:
	var w: Dictionary = WORDS[i]
	var half: float = _words[i].size.x / 2.0
	for k in 40:
		var ang := randf_range(PI * 1.05, PI * 1.95)
		var spd := randf_range(250.0, 950.0)
		sparks.append({
			"pos": Vector2(size.x / 2.0 + randf_range(-half, half), w.y + w.size * 0.25),
			"vel": Vector2(cos(ang), sin(ang)) * spd,
			"life": randf_range(0.4, 0.9),
			"col": [Color("#ffe14a"), Color("#ff9a1a"), Color("#fff6c8")][randi() % 3],
		})

func _ease_out_back(x: float) -> float:
	var c1 := 1.70158
	var c3 := c1 + 1.0
	return 1.0 + c3 * pow(x - 1.0, 3.0) + c1 * pow(x - 1.0, 2.0)

func _draw() -> void:
	for s in sparks:
		var c: Color = s.col
		c.a = clampf(s.life * 2.0, 0.0, 1.0)
		draw_rect(Rect2(s.pos - Vector2(3, 3), Vector2(6, 6)), c)
