extends Area2D

@export var FIREBALL_SPEED = 1000
@onready var parent = get_parent()
@export var duration = 80
@export var damage = 7

#Knockback attributes
@export var angle = 60
@export var base_kb = 3860
@export var kb_scaling  = 1
@export var type = "energy"
@export var percentage = 0
@export var weight =  100
@export var ratio =1 
@export var hitlag_modifier = 3
@onready var animation = $AnimatedSprite2D
var velx = 0
var vely = 0
var knockbackVal

var frame = 0
var dir_x = 1
var dir_y = 0
var player_list = []

#Converting Angles from Deg to Rad
const angleConversion = PI / 180

#Depending on direction, knockback angle is mirrored 
func dir (directionx,directiony):
	dir_x = directionx
	if dir_x < 0:
		angle = -angle+180
	else:
		angle = angle
	dir_y = directiony



func _ready():
	animation.play("fire", 1.0, false)
	self.velx = 8
	self.vely = -1# -2
	player_list.append(parent)
	set_process(true)


func _physics_process(delta):
	frame += floor(delta *60)
	if frame == duration:
		queue_free()
	var motion = (Vector2(dir_x,dir_y)).normalized() #* FIREBALL_SPEED
	#set_position(get_position() + motion * delta )
	self.position.x += dir_x*velx
	self.position.y += vely
	vely += 0.02
	velx *= .99
	position.direction_to(motion)
	
	set_rotation_degrees(rad_to_deg(Vector2(dir_x,dir_y).angle()))

func _on_WOLF_LASER_body_entered(body):
	if not (body in player_list):
		##print('hit')
		animation.play("burst", 1.0, false)	
		var charstate 
		charstate = body.get_node("StateMachine")
		if charstate.state != charstate.states.SHIELD:
			knockbackVal = knockback(body.percentage,damage,body.weight,kb_scaling,base_kb,1)
			body.percentage += damage
			body.knockback = knockbackVal
			body.velocity.x = (getHorizontalVelocity (knockbackVal, -angle))
			body.velocity.y = (getVerticalVelocity (knockbackVal, -angle))
			body.hdecay = (getHorizontalDecay(-angle))
			body.vdecay = (getVerticalDecay(angle))
			charstate.kbx = (getHorizontalVelocity (knockbackVal, -angle))
			charstate.kby = (getVerticalVelocity (knockbackVal, -angle))
			charstate.hd = (getHorizontalDecay(-angle))
			charstate.vd = (getVerticalDecay(angle))
			
			body.hitstun = getHitstun(knockbackVal/0.3)
			body.newframe()
			charstate.state = charstate.states.HITSTUN
		
#
		##charstate.state = charstate.states.HITFREEZE
		##charstate.hitfreeze(hitlag(damage,hitlag_modifier),[getHorizontalVelocity (knockbackVal, -angle), getVerticalVelocity (knockbackVal, -angle),getHorizontalDecay(angle),getVerticalDecay (angle)])
		queue_free()
		#body = body.get_parent()
		#player_list.append(body)
		#var charstate
		#charstate = body.get_node("StateMachine")
		#weight = body.weight
		#body.percentage += damage
		#knockbackVal = knockback(body.percentage,damage,weight,kb_scaling,base_kb,1)
		##s_angle(body)
		#_angle_flipper(body)
		#body.knockback = knockbackVal
		#body.hitstun = getHitstun(knockbackVal/0.3)
		#get_parent().connected = true
		#body.newframe()
		#charstate.state = charstate.states.HITSTUN


func knockback(p,d,w,ks,bk,r):
	percentage = p 
	damage = d
	weight = w
	kb_scaling = ks
	base_kb = bk
	ratio = r
	return ((((((((percentage/10) + (percentage*damage/20))*(200/ (weight+100)) *1.4) +18)*(kb_scaling))+base_kb)*1))*.004 #Smash Ultimate Version

func getHorizontalVelocity (knockback, angle):
	var initialVelocity = knockback * 30;
	var horizontalAngle = cos(angle * angleConversion);
	var horizontalVelocity = initialVelocity * horizontalAngle;
	horizontalVelocity = round(horizontalVelocity * 100000) / 100000;
	return horizontalVelocity;

func getVerticalVelocity (knockback, angle):
	var initialVelocity = knockback * 30;
	var verticalAngle = sin(angle * angleConversion);
	var verticalVelocity = initialVelocity * verticalAngle;
	verticalVelocity = round(verticalVelocity * 100000) / 100000;
	return verticalVelocity

func getHorizontalDecay (angle): #The rate at which the opponant will slow down after knockback
	var decay = 0.051 * cos(angle * angleConversion) #Rate of decay is 0.051, to get horizontal rate; multiply by horizontal(cos) angle in radians
	decay = round(decay * 100000) / 100000 #Round to a whole number
	decay = decay * 1000 #Enlarge the rate of decay
	return decay

func getVerticalDecay (angle):
	var decay = 0.051 * sin(angle * angleConversion)
	decay = round(decay * 100000) / 100000
	decay = decay * 1000
	return abs(decay)

func getHitstun (knockback):
	return floor(knockback * 0.4);

func hitlag(d,hit):
	damage = d
	hitlag_modifier = hit
	#return ((floor(d/3)+4)) 
	return floor((((floor(d) * 0.65) + 6) * hit))
	
func _angle_flipper(body):
	var xangle
	if get_parent().direction() == -1:
		xangle = (-(((body.global_position.angle_to_point(get_parent().global_position))*180)/PI))
	else:
		xangle = (((body.global_position.angle_to_point(get_parent().global_position))*180)/PI)
	body.velocity.x = (getHorizontalVelocity (knockbackVal, -angle))
	body.velocity.y = (getVerticalVelocity (knockbackVal, -angle))
	body.hdecay = (getHorizontalDecay(-angle))
	body.vdecay = (getVerticalDecay(angle))
	return ([body.velocity.x,body.velocity.y,body.hdecay,body.vdecay])
