extends RigidBody2D

var isFlip = true

func _integrate_forces(state):
	self.set_scale(Vector2((-1 if isFlip else 1), 1))
