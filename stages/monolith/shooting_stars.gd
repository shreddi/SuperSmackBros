extends Node2D
## Spawns the occasional shooting star that streaks across whatever part of
## the world the camera is currently looking at.

@export var min_interval := 2.5
@export var max_interval := 7.0
@export var min_speed := 1100.0
@export var max_speed := 2000.0
@export var trail_length := 320.0

const FLARE: Texture2D = preload("res://stages/monolith/backdrop/star_flare.png")

var _rng := RandomNumberGenerator.new()
var _mat := CanvasItemMaterial.new()
var _timer := 2.0


func _ready() -> void:
	_rng.randomize()
	_mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_timer = _rng.randf_range(1.5, 4.0)


func _process(delta: float) -> void:
	_timer -= delta
	if _timer > 0.0:
		return
	_spawn()
	# occasionally fire a quick second one
	if _rng.randf() < 0.2:
		_timer = _rng.randf_range(0.15, 0.5)
	else:
		_timer = _rng.randf_range(min_interval, max_interval)


func _view_rect() -> Rect2:
	var vp := get_viewport()
	var size := vp.get_visible_rect().size
	var cam := vp.get_camera_2d()
	if cam == null:
		return Rect2(-size / 2.0, size)
	var vs := Vector2(size.x / cam.zoom.x, size.y / cam.zoom.y)
	return Rect2(cam.get_screen_center_position() - vs / 2.0, vs)


func _spawn() -> void:
	var view := _view_rect()
	var angle := deg_to_rad(_rng.randf_range(18.0, 48.0))
	var dir := Vector2(cos(angle), sin(angle))
	if _rng.randf() < 0.5:
		dir.x = -dir.x
	# aim through a point in the middle of the view, from outside it to outside it
	var target := view.position + view.size * Vector2(_rng.randf_range(0.1, 0.9), _rng.randf_range(0.05, 0.6))
	var reach := view.size.length() * 0.6
	var start := target - dir * reach
	var finish := target + dir * reach
	var speed := _rng.randf_range(min_speed, max_speed)
	var dur := (reach * 2.0) / speed

	var tint := Color(0.85, 0.93, 1.0) if _rng.randf() < 0.7 else Color(1.0, 0.88, 0.7)
	var streak := Node2D.new()
	streak.rotation = dir.angle()
	streak.modulate = Color(tint, 0.0)

	var line := Line2D.new()
	line.points = PackedVector2Array([Vector2.ZERO, Vector2(-trail_length, 0.0)])
	line.width = 4.0
	line.material = _mat
	var grad := Gradient.new()
	grad.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 0)])
	grad.offsets = PackedFloat32Array([0.0, 1.0])
	line.gradient = grad
	var curve := Curve.new()
	curve.add_point(Vector2(0.0, 1.0))
	curve.add_point(Vector2(1.0, 0.05))
	line.width_curve = curve
	streak.add_child(line)

	var head := Sprite2D.new()
	head.texture = FLARE
	head.material = _mat
	head.scale = Vector2.ONE * 0.45
	streak.add_child(head)

	add_child(streak)
	streak.global_position = start

	var move := streak.create_tween()
	move.tween_property(streak, "global_position", finish, dur)
	move.tween_callback(streak.queue_free)
	var fade := streak.create_tween()
	fade.tween_property(streak, "modulate:a", 1.0, dur * 0.15)
	fade.tween_interval(dur * 0.5)
	fade.tween_property(streak, "modulate:a", 0.0, dur * 0.35)
