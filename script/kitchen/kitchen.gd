extends Node3D

@onready var Camera = $Camera3D
@onready var Player = $Player


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _physics_process(delta):
	# Sets the camera position
	Camera.position.x = lerp(Camera.position.x, Player.position.x/3, delta*10)
	Camera.position.z = lerp(Camera.position.z, Player.position.z/3 + 5, delta*10)
	# Sets the rotation
	Camera.rotation.y = lerp_angle(Camera.rotation.y, -Player.position.x/28, delta*8)
