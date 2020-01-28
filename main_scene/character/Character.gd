extends Node2D

onready var skeleton = $Skeleton2D
var segments = []

func _ready():
	# obtain all IK segments	
	for child in skeleton.get_children():
		segments.push_front(child)


func _process(delta):
	move_right_procedural()
	
#	if Input.is_action_just_pressed("character_move_right"):
#		move_right_procedural()
#	elif Input.is_action_pressed("character_stall"):
#		idle_procedural()


func move_right_procedural():
	# record previous info
	var root_loc = segments[-1].get_global_position()
	
	# follow target for each segment
	var target := get_global_mouse_position()
	for seg in segments:
		seg.look_at(target)
		
		var offset := Vector2(cos(seg.get_global_rotation()), 
			sin(seg.get_global_rotation()))
		offset.x *= seg.get_default_length() * seg.get_global_scale().x
		offset.y *= seg.get_default_length() * seg.get_global_scale().y
		var target_start = target - offset
		seg.set_global_position(target_start)

		target = seg.get_global_position()
	
	# move back to fix location
	var offset = root_loc - segments[-1].get_global_position()
	for seg in segments:
		seg.global_translate(offset)


func idle_procedural():
	pass
	