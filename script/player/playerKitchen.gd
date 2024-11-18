extends CharacterBody3D

@onready var anim = $AnimationTree
@onready var particles = $GPUParticles3D

const max_speed = 3.2

var player_velocity = Vector3()

var facing_angle = Vector2()
var paused = false


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event):
	if Input.is_action_just_pressed("Pause"):
		paused = not paused
		if paused:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if paused:
		return


func _process(delta):
	# If paused, then stop all player physics processing.
	if paused:
		return


func _physics_process(delta):
	# If paused, then stop all player physics processing.
	if paused:
		return

	# Gets the input vector from the controller.
	var input_vector = Vector3.ZERO
	input_vector.x = Input.get_action_strength("Right") - Input.get_action_strength("Left")
	input_vector.z = Input.get_action_strength("Backward") - Input.get_action_strength("Forward")
	input_vector = input_vector.normalized()

	# Sets the velocity.
	player_velocity.x = input_vector.x * max_speed
	player_velocity.z = input_vector.z * max_speed

	# If the player is not moving...
	if input_vector.length() == 0:
		# ...Set the animation to idle.
		anim.set("parameters/Idle2Walk/blend_amount", 0)
		# ...Set the particles to not emit.
		particles.emitting = false
	# If the player IS moving...
	else:
		# ...Set the facing angle.
		facing_angle = Vector2(input_vector.x, -1 * input_vector.z)
		# ...Set the animation to walk.
		anim.set("parameters/Idle2Walk/blend_amount", 1)
		# ...Set the particles to emit.
		particles.emitting = true

	# Sets the animation direction to the players facing direction.
	anim.set("parameters/Idle/blend_position", facing_angle)
	anim.set("parameters/Walking/blend_position", facing_angle)

	# Set the actual velocity to the variable velocity, and set the up direction.
	set_velocity(Vector3(player_velocity.x, player_velocity.y, player_velocity.z))
	up_direction = Vector3.UP

	# Moves the player for the frame.
	move_and_slide()

	# This sets the variable velocity to the final velocity.
	player_velocity.x = get_real_velocity().x
	player_velocity.y = get_real_velocity().y
	player_velocity.z = get_real_velocity().z
