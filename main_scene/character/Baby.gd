extends RigidBody2D

export var SPEED = 10
export var JUMP_SPEED = 15

export var anim_ratio = 0.1

var physics_ratio = 1 - anim_ratio
var isBlend := true

export(NodePath) var BONE_ROOT
export(NodePath) var RIGID_ROOT
var bone_list := []
var rigid_list := []
var bone2rigid_rot_list := []	# offset to transform from bone-coord to rigid-coord
								# TODO: it's tedious, need refactoring

onready var anim_player = get_node("../AnimationPlayer")


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
	
	# Get all rotation offset between them
	assert(bone_list.size() == rigid_list.size())
	for i in range(bone_list.size()):
		bone2rigid_rot_list.append(rigid_list[i].get_rotation()\
			 - bone_list[i].get_rotation())


func _physics_process(delta):
#	if isBlend:
#		# blend rigid's rotation with animation
#		for i in range(bone_list.size()):
#			var physics = rigid_list[i].get_rotation()
#			var animation = bone_list[i].get_rotation() + bone2rigid_rot_list[i]
#			rigid_list[i].set_rotation(physics * physics_ratio + animation * anim_ratio)
	
#	# blend feet anyway to look more realistic
#	for i in range(bone_list.size()-1, bone_list.size()-5, -1):
#			var physics = rigid_list[i].get_rotation()
#			var animation = bone_list[i].get_rotation() + bone2rigid_rot_list[i]
#			rigid_list[i].set_rotation(physics * physics_ratio + animation * anim_ratio)
	pass


func _integrate_forces(state):
	var f := Vector2()
	#isBlend = false
	
	if Input.is_action_pressed("character_move_right"):
		f.x += SPEED
		isBlend = true
		#anim_player.play("Crawl")
	elif Input.is_action_pressed("character_move_left"):
		f.x -= SPEED
		isBlend = true
		#anim_player.play("Crawl")
		
	elif Input.is_action_just_pressed("character_move_up"):
		f.y -= JUMP_SPEED
		isBlend = true
		#anim_player.play("Idle")
	else:
		#anim_player.play("Run")
		#anim_player.play("Idle")
		#anim_player.stop()
		#isBlend = false
		pass
	
	apply_impulse(Vector2(), f)

