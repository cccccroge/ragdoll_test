extends RigidBody2D


func _ready():
	pass # Replace with function body.


func _integrate_forces(state):
	if Input.is_action_just_pressed("character_move_right"):
		#add_force(Vector2(0, 0), Vector2(500, 0))
		#apply_impulse(Vector2(0, 0), Vector2(50, 0))
		pass


#func _physics_process(delta):
#	if Input.is_action_pressed("character_move_right"):
#		move_and_slide(Vector2(100, 0))
