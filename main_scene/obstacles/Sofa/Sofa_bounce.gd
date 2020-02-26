extends Node2D

# Bounce setting
export(int) var bounciness = 2

# Get nodes
onready var area = $Area2D


func _ready():
	area.connect("body_entered", self, "_bounce_character_upward")


func _bounce_character_upward(body):
	# Only bounce when his belly touch
	if body.get_name() != "Base" and body.get_name() != "BaseLeft":
		return
	
	# Apply impulse
	var vel = abs(body.get_linear_velocity().y)
	var impulse = bounciness * pow(vel, 1.5)
	body.apply_central_impulse(Vector2(0, -impulse))


