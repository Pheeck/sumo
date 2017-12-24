# TODO: mass

extends Sprite


# -- Member variables --

export var impact_energy_loss_factor = 0.8

export var player = 1
var players = {
	1 : "p1",
	2 : "p2",
	3 : "p3"
}

var speed = Vector2(0, 0)     # How will the object move every tick
export var acceleration = 10  # How much can player accelerate the object


# -- Methods --

func _ready():
	""" On entering tree """
	# Connect collision handling
	get_node("Area2D").connect("area_enter", self, "_on_area_enter")
	# Start cycle
	set_process(true)
	
func _process(delta):
	""" On each tick """
	var acceleration = self.acceleration * delta
	
	# Handle input
	if Input.is_action_pressed(self.players[self.player] + "_up"):
		accelerate(Vector2(0, -acceleration))
	if Input.is_action_pressed(self.players[self.player] + "_down"):
		accelerate(Vector2(0, acceleration))
	if Input.is_action_pressed(self.players[self.player] + "_left"):
		accelerate(Vector2(-acceleration, 0))
	if Input.is_action_pressed(self.players[self.player] + "_right"):
		accelerate(Vector2(acceleration, 0))
	
	# Wall bounce
	var pos = self.get_pos()
	var roomsize = self.get_viewport().get_rect().size
	
	if pos.x < 0:
		self.speed.x = abs(self.speed.x)
	elif pos.x > roomsize.x:
		self.speed.x = -abs(self.speed.x)
	if pos.y < 0:
		self.speed.y = abs(self.speed.y)
	elif pos.y > roomsize.y:
		self.speed.y = -abs(self.speed.y)
	
	# Movement handling
	self.move(speed)

func _on_area_enter(area):
	""" Push the other object (according to the plan.png and plan2.png) """
	var object = area.get_parent()
	var coll_vector = object.get_pos() - self.get_pos()
	var coll_angle = coll_vector.angle()
	var coll_length = coll_vector.length()
	
	# Push outside of the ball
	var r1 = self.get_texture().get_width() / 2
	var r2 = object.get_texture().get_width() / 2
	var desired_distance = r1 + r2 - coll_length
	var ratio = desired_distance / coll_length
	var desired_vector = Vector2()
	desired_vector.x = coll_vector.x * ratio
	desired_vector.y = coll_vector.y * ratio
	
	# Impact force
	var alpha = self.speed.angle()
	var beta = coll_angle
	var angle_diff = alpha - beta
	
	var a = self.speed.length()
	var b = cos(angle_diff) * a
	
	var y = b * cos(beta) * impact_energy_loss_factor
	var x = b * sin(beta) * impact_energy_loss_factor
	
	call_deferred("push", object, desired_vector, Vector2(x, y))

func push(object, displacement, speed):
	""" Push an object and set its speed; Used in collisions """
	#object.move(displacement)
	object.set_speed(speed)

func move(vector):
	""" Move the object by a vector """
	self.set_pos(self.get_pos() + vector)

func accelerate(vector):
	""" Accelerate the object by a vector """
	speed += vector

func set_speed(speed):
	""" Set the object's speed """
	self.speed = speed
