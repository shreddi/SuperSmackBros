extends Node2D
## Gentle "flying through space" backdrop for the Monolith stage.
##
## Each layer (Nebula, Galaxies, Stars+Twinkle) sways, rotates and breathes at a
## slightly different rate, which gives a soft parallax feel. The layers are
## larger than the camera limits, so the motion never reveals an edge. Keep
## amplitudes small if you shrink the art.

@export var drift_amplitude := 40.0          ## px of positional sway (far layers move less)
@export var drift_speed := 0.07              ## overall speed of the drift
@export var rotation_amplitude_deg := 0.9    ## max rotation of the nearest layer
@export var zoom_amplitude := 0.012          ## +/- fraction of scale "breathing"
@export var twinkle_count := 110
@export var twinkle_area := Vector2(3600, 2800)

const FLARE: Texture2D = preload("res://stages/monolith/backdrop/star_flare.png")
const TINTS := [
	Color(1.0, 0.96, 0.9), Color(0.8, 0.88, 1.0),
	Color(1.0, 0.86, 0.72), Color(0.85, 0.8, 1.0),
]

# name, depth (how strongly it moves), phase offset. Stars and Twinkle share a
# depth/phase so the twinkling stars stay locked to the static star field.
const LAYERS := [
	["Nebula", 0.4, 0.0],
	["Galaxies", 0.65, 1.7],
	["Stars", 1.0, 3.1],
	["Twinkle", 1.0, 3.1],
]

var _layers: Array[Dictionary] = []
var _twinkles: Array[Dictionary] = []
var _t := 0.0


func _ready() -> void:
	for l in LAYERS:
		var n := get_node_or_null(String(l[0])) as Node2D
		if n == null:
			continue
		_layers.append({"node": n, "depth": l[1], "phase": l[2],
			"pos": n.position, "scale": n.scale})
	_build_twinkle()


func _build_twinkle() -> void:
	var holder := get_node_or_null("Twinkle") as Node2D
	if holder == null:
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = 4242
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	for i in twinkle_count:
		var s := Sprite2D.new()
		s.texture = FLARE
		s.material = mat
		s.position = Vector2(rng.randf_range(-0.5, 0.5) * twinkle_area.x,
				rng.randf_range(-0.5, 0.5) * twinkle_area.y)
		s.modulate = TINTS[rng.randi() % TINTS.size()]
		var big := i < twinkle_count / 5
		var sc := rng.randf_range(0.5, 1.0) if big else rng.randf_range(0.12, 0.3)
		holder.add_child(s)
		_twinkles.append({"node": s, "base": sc,
			"phase": rng.randf() * TAU,
			"speed": rng.randf_range(0.6, 2.2),
			"floor": rng.randf_range(0.08, 0.35)})


func _process(delta: float) -> void:
	_t += delta
	var s := _t * drift_speed
	for l in _layers:
		var n: Node2D = l["node"]
		var d: float = l["depth"]
		var ph: float = l["phase"]
		var base_pos: Vector2 = l["pos"]
		var base_scale: Vector2 = l["scale"]
		var sway := Vector2(
			sin(s + ph) + 0.5 * sin(s * 2.3 + ph * 1.7),
			cos(s * 0.8 + ph * 1.3) + 0.5 * cos(s * 1.9 + ph))
		n.position = base_pos + sway * drift_amplitude * d * 0.67
		n.rotation = sin(s * 0.6 + ph) * deg_to_rad(rotation_amplitude_deg) * d
		n.scale = base_scale * (1.0 + sin(s * 0.5 + ph * 0.7) * zoom_amplitude * d)

	for tw in _twinkles:
		var spr: Sprite2D = tw["node"]
		var k := 0.5 + 0.5 * sin(_t * float(tw["speed"]) + float(tw["phase"]))
		k = lerpf(float(tw["floor"]), 1.0, k * k)
		spr.modulate.a = k
		spr.scale = Vector2.ONE * float(tw["base"]) * (0.85 + 0.3 * k)
