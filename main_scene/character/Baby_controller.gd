extends RigidBody2D

# Movement
export var SPEED = 10
export var JUMP_SPEED = 15

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
export(int) var head_min = -26
export(int) var head_max = 32

export(int) var armUpperLeft_min = -70
export(int) var armUpperLeft_max = 90
export(int) var armLowerLeft_min = -80
export(int) var armLowerLeft_max = 25
export(int) var armUpperRight_min = -80
export(int) var armUpperRight_max = 80
export(int) var armLowerRight_min = -68
export(int) var armLowerRight_max = 45

export(int) var legUpperLeft_min = -75
export(int) var legUpperLeft_max = 80
export(int) var legLowerLeft_min = -80
export(int) var legLowerLeft_max = 48
export(int) var legUpperRight_min = -15
export(int) var legUpperRight_max = 130
export(int) var legLowerRight_min = -130
export(int) var legLowerRight_max = 2

var rigid_angle_constraints := []

# Character flip
var isFlip := false		# default toward right

# Get nodes
onready var anim_player = get_node("../AnimationPlayer")
onready var skeleton = get_node("../Skeleton2D")


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
		bone2rigid_rot_list_l.append(rigid_list_l[i].get_rotation()\
			 - bone_list[i].get_rotation())
	
	# Get angle constraints (should be same order as the other lists)
	rigid_angle_constraints.append([0, 0])	# for Base, meaningless, just for alignment
	rigid_angle_constraints.append([deg2rad(head_min), deg2rad(head_max)])
	rigid_angle_constraints.append([deg2rad(armUpperLeft_min), deg2rad(armUpperLeft_max)])
	rigid_angle_constraints.append([deg2rad(armUpperRight_min), deg2rad(armUpperRight_max)])
	rigid_angle_constraints.append([deg2rad(legUpperLeft_min), deg2rad(legUpperLeft_max)])
	rigid_angle_constraints.append([deg2rad(legUpperRight_min), deg2rad(legUpperRight_max)])
	rigid_angle_constraints.append([deg2rad(armLowerLeft_min), deg2rad(armLowerLeft_max)])
	rigid_angle_constraints.append([deg2rad(armLowerRight_min), deg2rad(armLowerRight_max)])
	rigid_angle_constraints.append([deg2rad(legLowerLeft_min), deg2rad(legLowerLeft_max)])
	rigid_angle_constraints.append([deg2rad(legLowerRight_min), deg2rad(legLowerRight_max)])

	# Set default flip to right
	rigid_list_target = rigid_list
	bone2rigid_rot_list_target = bone2rigid_rot_list
	rigid_list_l[0].set_visible(false)

func _physics_process(delta):
	if isBlend:
		# blend rigid's rotation with animation
		for i in range(0, bone_list.size()-4):
			var physics = rigid_list_target[i].get_rotation()
			var animation = bone_list[i].get_rotation() + bone2rigid_rot_list_target[i]
			rigid_list_target[i].set_rotation(
				physics * physics_ratio + animation * anim_ratio)
	
	# blend feet anyway to look more realistic
	for i in range(bone_list.size()-4, bone_list.size()):
			var physics = rigid_list_target[i].get_rotation()
			var animation = bone_list[i].get_rotation() + bone2rigid_rot_list_target[i]
			rigid_list_target[i].set_rotation(
				physics * physics_ratio + animation * anim_ratio)
			
	# Restrict angles
	for i in range(1, rigid_list_target.size()):
		rigid_list_target[i].set_rotation(
			clamp(rigid_list_target[i].get_rotation(), 
				  rigid_angle_constraints[i][0], rigid_angle_constraints[i][1]))

func _integrate_forces(state):
	# Movement and animation
	var f := Vector2()
	isBlend = false
	
	if Input.is_action_pressed("character_move_right"):
		f.x += SPEED
		isBlend = true
		if isFlip:
			flip("right", state)
			isFlip = false
		anim_player.play("Crawl")
	elif Input.is_action_pressed("character_move_left"):
		f.x -= SPEED
		isBlend = true
		if not isFlip:
			flip("left", state)
			isFlip = true
		anim_player.play("Crawl")
	elif Input.is_action_just_pressed("character_move_up"):
		f.y -= JUMP_SPEED
		isBlend = true
		anim_player.play("Idle")
	
	else:
		isBlend = false
		anim_player.play("Idle")
	
	apply_impulse(Vector2(0, 0), f)

func flip(direction, state):
	if direction == "left" and self.get_name() == "Base":
		# swap visibility
		rigid_list[0].set_visible(false)
		rigid_list_l[0].set_visible(true)
		# change position
		var prev_pos = rigid_list[0].get_position()
		var state_l = Physics2DServer.body_get_direct_state(
			rigid_list_l[0].get_rid())
		state_l.set_transform(Transform2D(0.0, prev_pos))
		# update target lists
		rigid_list_target = rigid_list_l
		bone2rigid_rot_list_target = bone2rigid_rot_list_l
		
	elif direction == "right" and self.get_name() == "BaseLeft":
		rigid_list_l[0].set_visible(false)
		rigid_list[0].set_visible(true)
		
		var prev_pos = rigid_list_l[0].get_position()
		var state_r = Physics2DServer.body_get_direct_state(
			rigid_list[0].get_rid())
		state_r.set_transform(Transform2D(0.0, prev_pos))
		
		rigid_list_target = rigid_list
		bone2rigid_rot_list_target = bone2rigid_rot_list
