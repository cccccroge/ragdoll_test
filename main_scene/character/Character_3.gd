extends RigidBody2D


export var velocity = 5
export var anim_ratio = 0.05
var physics_ratio = 1 - anim_ratio

onready var bone_base = $Skeleton2D/Base
onready var bone_arm_upper = $Skeleton2D/Base/Seg1
onready var bone_arm_lower = $Skeleton2D/Base/Seg1/Seg2
onready var bone_head = $Skeleton2D/Base/Head

onready var rigid_base = $Base
onready var rigid_arm_upper = $Base/Seg1
onready var rigid_arm_lower = $Base/Seg1/Seg2
onready var rigid_head = $Base/Head


func _physics_process(delta):
	# blend with animation
	var physics
	var animation

	physics = rigid_base.get_rotation()
	animation = bone_base.get_rotation() + deg2rad(0 - (-90))
	rigid_base.set_rotation(physics * physics_ratio + animation * anim_ratio)
	
	physics = rigid_head.get_rotation()
	animation = bone_head.get_rotation() + deg2rad(0 - 0)
	rigid_head.set_rotation(physics * physics_ratio + animation * anim_ratio)
	
	physics = rigid_arm_upper.get_rotation()
	animation = bone_arm_upper.get_rotation() + deg2rad(-25.2 - 154.9)
	rigid_arm_upper.set_rotation(physics * physics_ratio + animation * anim_ratio)
	
	physics = rigid_arm_lower.get_rotation()
	animation = bone_arm_lower.get_rotation() + deg2rad(0 - 0)
	rigid_arm_lower.set_rotation(physics * physics_ratio + animation * anim_ratio)


func _integrate_forces(state):
	var xform = state.get_transform()
	if Input.is_action_pressed("character_move_right"):
		xform.origin.x += velocity
	elif Input.is_action_pressed("character_move_left"):
		xform.origin.x -= velocity
	
	state.set_transform(xform)

