extends RigidBody2D


# -- Member variables --

export var player = 1
var players = {
	1 : "p1",
	2 : "p2",
	3 : "p3"
}

export var roomsize = Vector2(1440, 900)
export var acceleration = 50
export(Texture) var texture


# -- Methods --

func _ready():
	# Pass texture to our sprite
	if texture == null:
		print("Error: A player hasn't been given a texture")
	get_node("Sprite").set_texture(texture)
	
	set_fixed_process(true)
	
func _fixed_process(delta):
	var acceleration = self.acceleration * delta
	
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
	var pos = self.get_pos()
	var velocity = get_linear_velocity()
	
	if pos.x < 0:
		set_linear_velocity(Vector2(abs(velocity.x), velocity.y))
	elif pos.x > roomsize.x:
		set_linear_velocity(Vector2(-abs(velocity.x), velocity.y))
	if pos.y < 0:
		set_linear_velocity(Vector2(velocity.x, abs(velocity.y)))
	elif pos.y > roomsize.y:
		set_linear_velocity(Vector2(velocity.x, -abs(velocity.y)))
