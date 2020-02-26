extends RigidBody2D

# Movement
export var SPEED = 10
export var JUMP_SPEED = 15


func _integrate_forces(state):
	if get_parent().isMoving == false:
		return
	
	if self.get_name() == "Base" and get_parent().isFlip:
		return
	elif self.get_name() == "BaseLeft" and not(get_parent().isFlip):
		return
	
	var f := Vector2(0, 0)
	if Input.is_action_pressed("character_move_right"):
		f.x += SPEED
	elif Input.is_action_pressed("character_move_left"):
		f.x -= SPEED
	elif Input.is_action_just_pressed("character_move_up"):
		f.y -= SPEED
	
	apply_impulse(Vector2(0, 0), f)
