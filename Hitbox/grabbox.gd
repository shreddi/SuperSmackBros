extends Area2D

@onready var parent = get_parent()
@export var width = 300
@export var height = 400
@export var damage = 50
@export var duration = 1500
@onready var grabbox = get_node("grabbox_shape")
var frame = 0.0
var points = []
var point
var player_list = []

func set_parameters(aWidth, aHeight, aDamage, aDuration, aPos, parent=get_parent()):
	self.position = Vector2(0,0)
	player_list.append(parent)
	player_list.append(self)
	self.width = aWidth
	self.height = aHeight
	self.damage = aDamage
	self.duration = aDuration
	self.position = aPos
	grabbox.shape.size = Vector2(aWidth,aHeight)
	connect("body_entered",Callable(self,"Grabbox_Collide"))
	set_physics_process(true)
	
func Grabbox_Collide(body):
	print("yes")
	if !(body in player_list):
		body.percentage += damage
		var charstate
		charstate = body.get_node("StateMachine")
		body.newframe()
		charstate.grabbed(get_parent().name,get_parent().get_node("StateMachine").state)
		charstate.state = charstate.states.GRABBED
		body.global_position = grabbox.global_position
		body.velocity.x = 0
		body.velocity.y = 0
		player_list.append(body)
		parent.grabbing = true
		
func _ready():
	grabbox.shape = RectangleShape2D.new()
	set_physics_process(false)
	
func _physics_process(delta):
	if frame < duration:
		frame += floor(delta*60)
	else:
		#get_parent().grabbing = false
		queue_free()
		return
		
