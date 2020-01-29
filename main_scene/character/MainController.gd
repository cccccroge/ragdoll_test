extends KinematicBody2D

export var velocity = 100
export var gravity = 98
export var jump = 100


func _physics_process(delta):
	var v := Vector2()
	
	v.y += gravity
	if Input.is_action_pressed("character_move_right"):
		v.x += velocity
	elif Input.is_action_pressed("character_move_left"):
		v.x -= velocity
	elif Input.is_action_just_pressed("character_move_up"):
		v.y -= jump
	
	move_and_slide(v, Vector2.UP)

