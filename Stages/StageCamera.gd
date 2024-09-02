extends Camera2D

var p1 = null
var p2 = null
@export_range(0.1, 0.5)
var zoom_offset: float = 0.1
@export var min_zoom: float = 0.5
@export var zoom_factor: float = 650

var camera_rect = Rect2()
var viewport_rect = Rect2()

# Called when the node enters the scene tree for the first time.
func _ready():
	print("camera")
	viewport_rect = get_viewport_rect()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not p1 or not p2:
		# Try to set p1 and p2 if they are not set yet
		setplayers()
	else:
		camera_rect = Rect2(p1.global_position, Vector2(0,0))
		camera_rect = camera_rect.expand(p2.global_position)
		self.position = calculate_center(camera_rect)
		#self.zoom = calculate_zoom(camera_rect, viewport_rect.size)
		zooming()
		
func calculate_center(rect: Rect2) -> Vector2:
	return Vector2(
		rect.position.x + rect.size.x / 2,
		rect.position.y + rect.size.y / 2
	)
#
#func calculate_zoom(rect: Rect2, viewport_size: Vector2) -> Vector2:
	#var max_zoom = max(
		#(viewport_size.x / rect.size.x)-zoom_offset,
		#(viewport_size.y / rect.size.y)-zoom_offset
	#)
	#print(max_zoom)
	#max_zoom = clampf(max_zoom, 0.3,1.3)
	#return Vector2(max_zoom, max_zoom)
	
func zooming():
	var longest_dist:float = 100
	var dist: float = (p1.global_position-p2.global_position).length_squared()
	longest_dist = max(longest_dist, dist)
	var z = clamp(1,1/max(min_zoom, sqrt(longest_dist)/zoom_factor),1.5)
	self.zoom = Vector2(z,z)

func setplayers():
	# Find player nodes using their groups
	if not p1:
		var player1_nodes = get_tree().get_nodes_in_group("player1")
		if player1_nodes.size() > 0:
			p1 = player1_nodes[0]

	if not p2:
		var player2_nodes = get_tree().get_nodes_in_group("player2")
		if player2_nodes.size() > 0:
			p2 = player2_nodes[0]
		

#func _draw():
	#print(camera_rect)
	#draw_rect(camera_rect, Color("#000000"), true)

