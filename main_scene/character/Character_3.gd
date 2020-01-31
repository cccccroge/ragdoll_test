extends RigidBody2D

export var SPEED = 5
export var JUMP_SPEED = 15

export var anim_ratio = 0.1
var physics_ratio = 1 - anim_ratio
var isBlend := true

onready var bone_base = $Skeleton2D/Base
onready var bone_head = $Skeleton2D/Base/Head
onready var bone_seg1 = $Skeleton2D/Base/Seg1
onready var bone_seg2 = $Skeleton2D/Base/Seg1/Seg2
onready var bone_seg3 = $Skeleton2D/Base/Seg3
onready var bone_seg4 = $Skeleton2D/Base/Seg3/Seg4
onready var bone_seg5 = $Skeleton2D/Base/Seg5
onready var bone_seg6 = $Skeleton2D/Base/Seg5/Seg6
onready var bone_seg7 = $Skeleton2D/Base/Seg7
onready var bone_seg8 = $Skeleton2D/Base/Seg7/Seg8

onready var rigid_base = $Base
onready var rigid_head = $Base/Head
onready var rigid_seg1 = $Base/Seg1
onready var rigid_seg2 = $Base/Seg1/Seg2
onready var rigid_seg3 = $Base/Seg3
onready var rigid_seg4 = $Base/Seg3/Seg4
onready var rigid_seg5 = $Base/Seg5
onready var rigid_seg6 = $Base/Seg5/Seg6
onready var rigid_seg7 = $Base/Seg7
onready var rigid_seg8 = $Base/Seg7/Seg8

var bone_list := []
var rigid_list := []
var rot_offset_list := []	# offset to transform from bone-coord to rigid-coord
							# TODO: it's tedious, need refactoring

onready var anim_player = $AnimationPlayer


func _ready():
	# initialize three lists
	bone_list.append(bone_base)
	bone_list.append(bone_head)
	bone_list.append(bone_seg1)
	bone_list.append(bone_seg2)
	bone_list.append(bone_seg3)
	bone_list.append(bone_seg4)
	bone_list.append(bone_seg5)
	bone_list.append(bone_seg6)
	bone_list.append(bone_seg7)
	bone_list.append(bone_seg8)
	
	rigid_list.append(rigid_base)
	rigid_list.append(rigid_head)
	rigid_list.append(rigid_seg1)
	rigid_list.append(rigid_seg2)
	rigid_list.append(rigid_seg3)
	rigid_list.append(rigid_seg4)
	rigid_list.append(rigid_seg5)
	rigid_list.append(rigid_seg6)
	rigid_list.append(rigid_seg7)
	rigid_list.append(rigid_seg8)
	
	assert(bone_list.size() == rigid_list.size())
	
	for i in range(bone_list.size()):
		rot_offset_list.append(rigid_list[i].get_rotation()\
			 - bone_list[i].get_rotation())


func _physics_process(delta):
	if isBlend:
		# blend rigid's rotation with animation
		for i in range(bone_list.size()-4):
			var physics = rigid_list[i].get_rotation()
			var animation = bone_list[i].get_rotation() + rot_offset_list[i]
			rigid_list[i].set_rotation(physics * physics_ratio + animation * anim_ratio)
	
	# blend feet anyway to look more realistic
	for i in range(bone_list.size()-1, bone_list.size()-5, -1):
			var physics = rigid_list[i].get_rotation()
			var animation = bone_list[i].get_rotation() + rot_offset_list[i]
			rigid_list[i].set_rotation(physics * physics_ratio + animation * anim_ratio)


func _integrate_forces(state):
	var f := Vector2()
	isBlend = false
	
	if Input.is_action_pressed("character_move_right"):
		f.x += SPEED
		isBlend = true
		anim_player.play("Run")
	elif Input.is_action_pressed("character_move_left"):
		f.x -= SPEED
		isBlend = true
		anim_player.play("Run")
		
	elif Input.is_action_just_pressed("character_move_up"):
		f.y -= JUMP_SPEED
		isBlend = true
		anim_player.play("Idle")
	else:
		#anim_player.play("Run")
		anim_player.play("Idle")
		#anim_player.stop()
		pass
	
	apply_impulse(Vector2(), f)

