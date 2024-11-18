extends Node3D


@onready var anim = $AnimationPlayer
@onready var shadow = $Shadow
@onready var floorNormal = $FloorNormal


# Called when the node enters the scene tree for the first time.
func _ready():
	anim.play("spin")


func _process(delta):
	shadow.global_transform = align_y(shadow.global_transform, floorNormal.get_collision_normal())
	shadow.global_position.y = floorNormal.get_collision_point().y + 0.02
	shadow.global_position.x = self.global_position.x
	shadow.global_position.z = self.global_position.z
	if not floorNormal.is_colliding():
		shadow.visible = false
	else:
		shadow.visible = true


func align_y(xform, newy):
	xform.basis.y = newy
	xform.basis.x = -xform.basis.z.cross(newy)
	xform.basis = xform.basis.orthonormalized()
	return xform
