extends Node2D

# Movement
var isMoving := false		# give hint to script of two rigid base

# Active ragdoll
export var anim_ratio = 0.15
var physics_ratio = 1 - anim_ratio
var isBlend := true

export(NodePath) var BONE_ROOT
export(NodePath) var RIGID_ROOT
export(NodePath) var RIGID_ROOT_LEFT
var bone_list := []
var rigid_list := []
var rigid_list_l := []
var rigid_list_target
var bone2rigid_rot_list := []	# offset to transform from bone-coord to rigid-coord
var bone2rigid_rot_list_l := []
var bone2rigid_rot_list_target

# Angle constraints
export(Array, Array, int) var rigid_angle_constraints := [
	[0, 0], [-26, 32], # Base & Head, Base's angles are meaningless, just for alignment
	[-70, 90], [-80, 25], [-80, 80], [-68, 45], # Arm left/right
	[-75, 80], [-80, 48], [-15, 130], [-130, 2]	# Leg left/right
]
export(Array, Array, int) var rigid_angle_constraints_l := [
	[0, 0], [-40, 16], # Base & Head, Base's angles are meaningless, just for alignment
	[-55, 90], [-40, 75], [-77, 75], [-50, 72], # Arm left/right
	[-90, 63], [-53, 70], [-70, 80], [-77, 50]	# Leg left/right
]
var rigid_angle_constraints_target

# Character flip
var isFlip := false		# default toward right

# Get nodes
onready var anim_player = get_node("AnimationPlayer")
onready var skeleton = get_node("Skeleton2D")


func _ready():
	# Get all bones
	var l = Array()
	
	l.push_back(get_node(BONE_ROOT))
	while not l.empty():
		var current = l.pop_front()
		bone_list.append(current)
		for node in current.get_children():
			if node is Bone2D:
				l.push_back(node)
		
	
	# Get all rigid bodies
	l.push_back(get_node(RIGID_ROOT))
	while not l.empty():
		var current = l.pop_front()
		rigid_list.append(current)
		for node in current.get_children():
			if node is RigidBody2D:
				l.push_back(node)
	
	l.push_back(get_node(RIGID_ROOT_LEFT))
	while not l.empty():
		var current = l.pop_front()
		rigid_list_l.append(current)
		for node in current.get_children():
			if node is RigidBody2D:
				l.push_back(node)
	
	# Get all rotation offset between them
	assert(bone_list.size() == rigid_list.size())
	for i in range(bone_list.size()):
		bone2rigid_rot_list.append(rigid_list[i].get_rotation()\
			 - bone_list[i].get_rotation())
	
	assert(bone_list.size() == rigid_list_l.size())
	for i in range(bone_list.size()):
		var bone_rot = PI - bone_list[i].get_rotation()	# flip the angle cuz 
														# scaling skeleton won't affect bone's angle
		bone2rigid_rot_list_l.append(rigid_list_l[i].get_rotation()\
			 - bone_rot)
	
	# Get all angle constraints in radians
	for list in rigid_angle_constraints:
		list[0] = deg2rad(list[0])
		list[1] = deg2rad(list[1])
	
	for list in rigid_angle_constraints_l:
		list[0] = deg2rad(list[0])
		list[1] = deg2rad(list[1])

	# Set default flip to right
	flip("right")


func _physics_process(delta):
	if isBlend:
		# blend rigid's rotation with animation
		for i in range(0, bone_list.size()-4):
			var physics = rigid_list_target[i].get_rotation()
			
			var bone_rot = bone_list[i].get_rotation()
			if isFlip:
				bone_rot = PI - bone_rot
			var animation = bone_rot + bone2rigid_rot_list_target[i]
			
			rigid_list_target[i].set_rotation(
				physics * physics_ratio + animation * anim_ratio)
	
	# blend feet anyway to look more realistic
	for i in range(bone_list.size()-4, bone_list.size()):
			var physics = rigid_list_target[i].get_rotation()
			
			var bone_rot = bone_list[i].get_rotation()
			if isFlip:
				bone_rot = PI - bone_rot
			var animation = bone_rot + bone2rigid_rot_list_target[i]
			
			rigid_list_target[i].set_rotation(
				physics * physics_ratio + animation * anim_ratio)
			
	# Restrict angles
	for i in range(1, rigid_list_target.size()):
		rigid_list_target[i].set_rotation(
			clamp(rigid_list_target[i].get_rotation(), 
				  rigid_angle_constraints_target[i][0], rigid_angle_constraints_target[i][1]))


func _process(delta):
	# Do animation
	isBlend = false
	isMoving = false
	
	if Input.is_action_pressed("character_move_right"):
		isBlend = true
		isMoving = true
		if isFlip:
			flip("right")
			isFlip = false
		anim_player.play("Crawl")
	elif Input.is_action_pressed("character_move_left"):
		isBlend = true
		isMoving = true
		if not isFlip:
			flip("left")
			isFlip = true
		anim_player.play("Crawl")
	elif Input.is_action_just_pressed("character_move_up"):
		isBlend = true
		isMoving = true
		anim_player.play("Idle")
		
	else:
		isBlend = false
		isMoving = false
		anim_player.play("Idle")


""" Swapping two tree of rigid bodies, achieving 
	fliping sprites & collision shapes """

func flip(direction):
	if direction == "left":
		# init position (must do it before set it back to rigid mode!)
		rigid_list_l[0].set_position(rigid_list[0].get_position())
		# swap physics simulation
		set_all_rigid(rigid_list, false)
		set_all_rigid(rigid_list_l, true)
		# swap visibilities
		rigid_list[0].set_visible(false)
		rigid_list_l[0].set_visible(true)
		# set blending target of active ragdoll
		rigid_list_target = rigid_list_l
		bone2rigid_rot_list_target = bone2rigid_rot_list_l
		rigid_angle_constraints_target = rigid_angle_constraints_l
		# flip animation
		skeleton.set_scale(Vector2(-1, 1))
		
	elif direction == "right":
		rigid_list[0].set_position(rigid_list_l[0].get_position())
		
		set_all_rigid(rigid_list_l, false)
		set_all_rigid(rigid_list, true)
		
		rigid_list_l[0].set_visible(false)
		rigid_list[0].set_visible(true)
		
		rigid_list_target = rigid_list
		bone2rigid_rot_list_target = bone2rigid_rot_list
		rigid_angle_constraints_target = rigid_angle_constraints
		
		skeleton.set_scale(Vector2(1, 1))


""" Set mode of all rigid bodies in the list to RIGID/disabled STATIC """

func set_all_rigid(list, boolean):
	var mode = RigidBody2D.MODE_RIGID if boolean else RigidBody2D.MODE_STATIC
	for rigid in list:
		rigid.set_mode(mode)
		rigid.set_collision_mask_bit(3, boolean)
