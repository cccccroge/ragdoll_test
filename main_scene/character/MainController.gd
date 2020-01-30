extends KinematicBody2D


export var velocity = 100
export var gravity = 98
export var jump = 100

onready var arm_upper_r = get_node("../Torso/Arm_upper_R")
onready var arm_lower_r = get_node("../Torso/Arm_upper_R/Arm_lower_R")
onready var arm_hand_r = get_node("../Torso/Arm_upper_R/Arm_lower_R/Arm_hand_R")

onready var a = $Skeleton2D/Hip/Torso/Arm_upper_R
onready var b = $Skeleton2D/Hip/Torso/Arm_upper_R/Arm_lower_R
onready var c = $Skeleton2D/Hip/Torso/Arm_upper_R/Arm_lower_R/Arm_hand_R

onready var A = $Skeleton2D/Hip/Torso/Arm_upper_R/ColorRect
onready var B = $Skeleton2D/Hip/Torso/Arm_upper_R/Arm_lower_R/ColorRect
onready var C = $Skeleton2D/Hip/Torso/Arm_upper_R/Arm_lower_R/Arm_hand_R/Polygon2D


func _physics_process(delta):
	# move controller
	var v := Vector2()
	
	v.y += gravity
	if Input.is_action_pressed("character_move_right"):
		v.x += velocity
	elif Input.is_action_pressed("character_move_left"):
		v.x -= velocity
	
	move_and_slide(v, Vector2.UP)
	
	# blend with animation
	var physics
	var animation
	
	physics = arm_upper_r.get_rotation()
	animation = a.get_rotation()
	A.set_rotation(physics * 0.5 + animation * 0.5)
	
	physics = arm_lower_r.get_rotation()
	animation = b.get_rotation()
	B.set_rotation(physics * 0.5 + animation * 0.5)
	
	physics = arm_hand_r.get_rotation()
	animation = c.get_rotation()
	C.set_rotation(physics * 0.5 + animation * 0.5)

