extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var left_rigid = $left_wing
onready var right_rigid = $right_wing
export(Array, Array, float) var box_rigid_angle_constraints := [
	[-72.5, -34.8], 	#left_paper_wing
	[-113.6, -103.7]	#right_paper_wing
]
# Called when the node enters the scene tree for the first time.
func _ready():
	for list in box_rigid_angle_constraints:
		list[0] = deg2rad(list[0])
		list[1] = deg2rad(list[1])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Restrict angles
	left_rigid.set_rotation(
		clamp(left_rigid.get_rotation(), 
			  box_rigid_angle_constraints[0][0], box_rigid_angle_constraints[0][1]))
			
	right_rigid.set_rotation(
		clamp(right_rigid.get_rotation(), 
			  box_rigid_angle_constraints[1][0], box_rigid_angle_constraints[1][1]))
			
