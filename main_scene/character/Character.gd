extends Position2D

onready var animatePlayer = $AnimationPlayer
onready var physicPolygons = $physicPolygons
onready var torsoRigidBody = $physicPolygons/torso

func _ready():
	animatePlayer.playback_active = true
	animatePlayer.play("Idle")


func _process(delta):
	if Input.is_action_just_pressed("character_move_right"):
		#turn_rigid(false, null)
		animatePlayer.play("Walk_forward")
		pass
	elif Input.is_action_just_pressed("character_stall"):
		#turn_rigid(true, null)
		animatePlayer.play("Idle")


func turn_rigid(on, root):
	# neglect root for now, get all rigidBody
	var rigidBodies = get_all_rigidBody(Array(), physicPolygons)

	if on:
		for rigidBody in rigidBodies:
			rigidBody.set("Mode", "Rigid")
	else:
		for rigidBody in rigidBodies:
			rigidBody.set("Mode", "Kinematic")


func get_all_rigidBody(bodies, target):
	for child in target.get_children():
		if child is RigidBody2D:
			bodies.append(child)
		get_all_rigidBody(bodies, child)

	return bodies

