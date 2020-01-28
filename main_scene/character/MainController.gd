extends RigidBody2D

export var velocity = 5

func _ready():
	pass


func _integrate_forces(state):
	#if Input.is_action_pressed("character_move_right"):
		var transform = state.get_transform()
		transform.origin.x += velocity
		state.set_transform(transform)