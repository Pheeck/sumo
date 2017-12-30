extends RigidBody2D


# -- Member variables --

export var player = 1
var players = {
	1 : "p1",
	2 : "p2",
	3 : "p3",
	4 : "p4",
	5 : "p5"
}

export var roomsize = Vector2(1440, 900)
export(Texture) var texture

onready var canvas = get_parent()
onready var particles = get_node("Particles2D")
onready var sound = get_node("SamplePlayer")

# Movement
export var default_acceleration = 10
export var damp_acceleration = false

# Sparks
var sparks_on = true
var default_spark_amount = 16
var default_spark_speed = 160
var scale_sparks = true
var spark_amount_multiplier = 0.1
var spark_speed_multiplier = 1

# Sound effects
onready var effect_count = sound.get_sample_library().get_sample_list().size()


# -- Methods --

func _ready():
	# Pass texture to our sprite
	if texture == null:
		print("Error: A player hasn't been given a texture")
	get_node("Sprite").set_texture(texture)
	
	# Add itself to the score tracking system of canvas
	canvas.add_ball(self)
	
	# Connect collisions
	connect("body_enter", self, "_on_body_enter")
	
	# Start process
	set_fixed_process(true)
	
func _fixed_process(delta):
	var acceleration = default_acceleration * delta
	var speed = get_linear_velocity().length()
	
	if damp_acceleration:
		# Damp the acceleration in relation to ball speed
		acceleration /= log(speed + 8) * 1.1076
	
	# Handle input
	if Input.is_action_pressed(self.players[self.player] + "_up"):
		apply_impulse(Vector2(0, 0), Vector2(0, -acceleration))
	if Input.is_action_pressed(self.players[self.player] + "_down"):
		apply_impulse(Vector2(0, 0), Vector2(0, acceleration))
	if Input.is_action_pressed(self.players[self.player] + "_left"):
		apply_impulse(Vector2(0, 0), Vector2(-acceleration, 0))
	if Input.is_action_pressed(self.players[self.player] + "_right"):
		apply_impulse(Vector2(0, 0), Vector2(acceleration, 0))
	
	# Wall bounce
	# var pos = self.get_pos()
	# var velocity = get_linear_velocity()
	# if pos.x < 0:
	# 	set_linear_velocity(Vector2(abs(velocity.x), velocity.y))
	# elif pos.x > roomsize.x:
	# 	set_linear_velocity(Vector2(-abs(velocity.x), velocity.y))
	# if pos.y < 0:
	# 	set_linear_velocity(Vector2(velocity.x, abs(velocity.y)))
	# elif pos.y > roomsize.y:
	# 	set_linear_velocity(Vector2(velocity.x, -abs(velocity.y)))

func _on_body_enter(object):
	# Compute properties of the collision
	var coll_magnitude = get_linear_velocity().length()
	var coll_direction = object.get_pos() - get_pos()
	
	# Emmit sparks
	if sparks_on:
		# Set direction
		particles.set_emissor_offset(coll_direction / 4)
		var direction = coll_direction.angle() - PI / 2
		particles.set_param(particles.PARAM_DIRECTION, rad2deg(direction))
		
		# Set amount and speed
		var amount = default_spark_amount
		var speed = default_spark_speed
		if scale_sparks:
			amount += coll_magnitude * spark_amount_multiplier
			speed += coll_magnitude * spark_speed_multiplier
		particles.set_amount(amount)
		particles.set_param(particles.PARAM_LINEAR_VELOCITY, speed)
		
		# Start
		particles.set_emitting(true)
	
	# Play soundeffect
	var effect = str((randi() % effect_count) + 1)
	sound.play(effect)
	
	# Start visual canvas visual effects
	canvas.handle_collision(coll_magnitude)

func config_sparks(on, default_amount, default_speed, scale, amount_multiplier, speed_multiplier):
	sparks_on = on
	default_spark_amount = default_amount
	default_spark_speed = default_speed
	scale_sparks = scale
	spark_amount_multiplier = amount_multiplier
	spark_speed_multiplier = speed_multiplier

func kill():
	""" Destroy this object """
	canvas.balls.erase(self)
	canvas.scores.erase(self)
	canvas.speeds.erase(self)
	
	queue_free()

