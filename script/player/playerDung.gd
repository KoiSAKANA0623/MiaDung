extends CharacterBody3D

@onready var head = $Head
#@onready var camera = $Head/CamRot/SpringArm3D/Camera3D
@onready var camera = $Head/CamRot/Camera3D
@onready var camera_rotate = $Head/CamRot
@onready var footstepPlayer = $FootStepSound
@onready var lookingRay = $Head/CamRot/RayLook
@onready var model = $Dungeon_Mia
@onready var model_anim = $AnimationTree
@onready var mat_anim = $MaterialAnimations
@onready var floorNormal = $FloorNormal
@onready var floorCheck = $FloorCheck
@onready var shadow = $Shadow

var on_floor = true

var camera_x_rotation = 0
var last_mod_angle = 0.0

const mouse_sensitivity = 0.5
const r_joy_sensitivity = 4.0
const floor_acceleration = 32.0
const floor_friction = 38.0
const air_acceleration = 18.0
const air_friction = 6.0
const gravity = 28.0
const terminal_velocity = 40.0
const jump_velocity = 12.0
const max_speed = 10.0
const top_speed = 32.0

var acceleration = 0.1
var deacceleration = 0.1

var is_landed = false
var is_jumped = false
var floor_direction

var player_velocity = Vector3()
var maxspeedMult

var paused = false

var time: float
var land_timer = 8

var playback: AudioStreamPlaybackPolyphonic
var stream
var footstep_sounds = [
	load("res://sound/Player/footstep0.ogg"),
	load("res://sound/Player/footstep1.ogg"),
	load("res://sound/Player/footstep2.ogg")
]


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	apply_floor_snap()
	stream = AudioStreamPolyphonic.new()
	stream.polyphony = 3
	footstepPlayer.stream = stream
	footstepPlayer.play()
	playback = footstepPlayer.get_stream_playback()
	mat_anim.play("Idle")


func _input(event):
	if Input.is_action_just_pressed("Pause"):
		paused = not paused
		if paused:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if paused:
		return

	if event is InputEventMouseMotion:
		head.rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		camera_rotate.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))


func _process(delta):
	# If paused, then stop all player physics processing.
	if paused:
		return

	# Adds to the time variable.
	time += delta

	# Sets the run and tail animation speeds.
	model_anim.set("parameters/Run_Speed/scale", player_velocity.length()/3 + 0.8)
	model_anim.set("parameters/Tail_Speed/scale", player_velocity.length()/3 + 0.8)

	# If the player's velocity is less than 0.1...
	if player_velocity.length() < 0.1:
		# ...Set the player animation to idle.
		model_anim.set("parameters/Idle2Run/blend_amount", 0.0)
	# If the player's velocity is greater than or equal to 0.1...
	else:
		# ...Set the player animation to move.
		model_anim.set("parameters/Idle2Run/blend_amount", 1.0)
		# ...Reset the idle animation.
		model_anim.set("parameters/IdleReset/seek_request", 0.0)

	# If the player's velocity is less than 7...
	if player_velocity.length() < 7.0:
		# ...Set the player moving animation to walk.
		model_anim.set("parameters/Walk2Run/blend_position", -1.0)
	# If the player's velocity is less than 14...
	elif player_velocity.length() < 14.0:
		# ...Set the player moving animation to jog.
		model_anim.set("parameters/Walk2Run/blend_position", 0.0)
	# If the player's velocity is greater than or equal to 14...
	else:
		# ...Set the player moving animation to run.
		model_anim.set("parameters/Walk2Run/blend_position", 1.0)

	# Sets the shadows position and angle along the ground.
	shadow.global_transform = align_y(shadow.global_transform, floorNormal.get_collision_normal())
	shadow.global_position.y = floorNormal.get_collision_point().y + 0.01
	shadow.global_position.x = self.global_position.x
	shadow.global_position.z = self.global_position.z

	# If the floor is too far...
	if not floorNormal.is_colliding():
		# ...Set the shadow invisible.
		shadow.visible = false
	# If the floor is close enough...
	else:
		# ...Set the shadow visible.
		shadow.visible = true

	# Sets the shadows scale based on how far the player is from the floor.
	shadow.scale.x = clamp(-1 * clamp(self.global_position.y - floorNormal.get_collision_point().y, 0, 10)/ 6 + 1, 0.4, 1)
	shadow.scale.z = clamp(-1 * clamp(self.global_position.y - floorNormal.get_collision_point().y, 0, 10)/ 6 + 1, 0.4, 1)


func _physics_process(delta):
	# If paused, then stop all player physics processing.
	if paused:
		return

	if floorCheck.is_colliding():
		on_floor = true
	else:
		on_floor = false

	if floorNormal.is_colliding():
		if on_floor:
			floor_direction = floorNormal.get_collision_normal()
		else:
			floor_direction = lerp(floor_direction, Vector3.UP, delta * 10)

	# Gets the input vector from the controller.
	var input_vector = Vector3.ZERO
	input_vector.x = Input.get_action_strength("Right") - Input.get_action_strength("Left")
	input_vector.z = Input.get_action_strength("Backward") - Input.get_action_strength("Forward")

	# Gets the input strength of the controller.
	var input_strength = clamp(input_vector.length(), 0, 1)

	# Get the direction of the controller.
	input_vector = input_vector.normalized()
	var direction = get_direction(input_vector)

	maxspeedMult = (max_speed * input_strength)
	# If the player is moving...
	if direction != Vector3.ZERO:
		# ...Accelerate them in the set direction.
		player_velocity.x = player_velocity.move_toward(direction * maxspeedMult, acceleration * delta).x
		#player_velocity.y = player_velocity.move_toward(direction * maxspeedMult, acceleration * delta).y
		player_velocity.z = player_velocity.move_toward(direction * maxspeedMult, acceleration * delta).z

		# If the player is on the floor...
		if on_floor:
			# ...Set the players rotation (faster rotation on ground).
			model.rotation.y = \
			lerp_angle(model.rotation.y, -Vector2(direction.x, direction.z).angle() + deg_to_rad(90), delta *10)
		# If the player is NOT on the floor...
		else:
			# ...Set the players rotation (slower rotation in air).
			model.rotation.y = \
			lerp_angle(model.rotation.y, -Vector2(direction.x, direction.z).angle() + deg_to_rad(90), delta *4)
	# If the player is NOT moving...
	else:
		# ...Deaccelerate them to zero.
		player_velocity.x = player_velocity.move_toward(Vector3.ZERO, deacceleration * delta).x
		#player_velocity.y = player_velocity.move_toward(Vector3.ZERO, deacceleration * delta).y
		player_velocity.z = player_velocity.move_toward(Vector3.ZERO, deacceleration * delta).z

	# If the player is falling slower than terminal velocity...
	if player_velocity.y > -terminal_velocity:
		# ...Apply gravity.
		player_velocity.y -= (gravity * delta)
	# If the player is falling greater than terminal velocity...
	else:
		# ...Set the speed to terminal velocity.
		player_velocity.y = -terminal_velocity

	# If the player is on the floor...
	if on_floor:
		# If the player has just landed...
		if is_landed == true:
			# ...Play the land animation and sounds.
			playback.play_stream(footstep_sounds.pick_random())
			model_anim.set("parameters/OnLand/request", 1)
			# If the player is not inputing any direction...
			if !Input.is_action_pressed("Forward") and !Input.is_action_pressed("Backward") and \
			!Input.is_action_pressed("Left") and !Input.is_action_pressed("Right"):
				# ...Set the velocity to zero.
				player_velocity.x = 0
				player_velocity.y = 0
				player_velocity.z = 0
		# If the jump button is pressed...
		if Input.is_action_just_pressed("Jump"):
			# ...Set the y to the jump velocity, and play jump sounds.
			#player_velocity.y = jump_velocity
			player_velocity.y = jump_velocity
			playback.play_stream(footstep_sounds.pick_random())
			# ...Play the jump animation.
			model_anim.set("parameters/OnJump/request", 1)
		# If the players velocity is less than 0.5...
		if player_velocity.length() > 0.5:
			# If the land timer is less than or equal to 0...
			if land_timer <= 0:
				# ...Cancel the landing animation.
				model_anim.set("parameters/OnLand/request", 2)
			# If the land timer is greater than 0...
			else:
				# ...Add one to the land timer.
				land_timer -= 1
		# ...Set the accelerations to be floor.
		acceleration = floor_acceleration
		deacceleration = floor_friction
		# ...Set the player landing to false.
		is_landed = false
		# ...Set the players animations to be ground anims.
		model_anim.set("parameters/InAir/blend_amount", 0.0)

		# Set the player y velocity (Do it here so we don't mess with air velocity).
		if direction != Vector3.ZERO:
			# ...When accelerating.
			player_velocity.y = player_velocity.move_toward(direction * maxspeedMult, acceleration * delta).y
		else:
			# ...When deaccelerating.
			player_velocity.y = player_velocity.move_toward(Vector3.ZERO, deacceleration * delta).y

		# If the player is airborn but the Raycast detects floor, snap them to the floor.
		if !is_on_floor() && on_floor:
			apply_floor_snap()
	# If the player is NOT on the floor...
	else:
		# ...Set the accelerations to be air.
		acceleration = air_acceleration
		deacceleration = air_friction
		# ...Set the player landing to true.
		is_landed = true
		# ...Reset the idle animation.
		model_anim.set("parameters/IdleReset/seek_request", 0.0)
		# ...Set the players animations to be air anims.
		model_anim.set("parameters/InAir/blend_amount", 1.0)
		# ...Cancel the landing animation.
		model_anim.set("parameters/OnLand/request", 2)
		# ...Set the land timer to 8.
		land_timer = 8

	# Unused for now
	#if lookingRay.is_colliding():
	#	if lookingRay.get_collider().is_in_group("Chest"):
	#		if lookingRay.get_collider().get_parent().is_open == false:
	#			if not Input.is_action_pressed("LClick"):
	#				Global.is_looking = false
	#				Global.looking_at = "Chest"
	#				Global.is_looking = true
	#			else:
	#				Global.is_looking = false
	#				lookingRay.get_collider().get_parent().open_chest()
	#	else:
	#		Global.is_looking = false
	#else:
	#	Global.is_looking = false

	up_direction = Vector3.UP

	# Set the actual velocity to the variable velocity, and set the up direction.
	set_velocity(Vector3(player_velocity.x, player_velocity.y, player_velocity.z))

	# Moves the player for the frame.
	move_and_slide()

	# This sets the variable velocity to the final velocity.
	player_velocity.x = get_real_velocity().x
	player_velocity.y = get_real_velocity().y
	player_velocity.z = get_real_velocity().z

	# The left stick vector, for the camera.
	var axis_vector: Vector2
	# Sets the vector to the left stick input.
	axis_vector.x = Input.get_action_strength("joyLookRight") - Input.get_action_strength("joyLookLeft")
	axis_vector.y = Input.get_action_strength("joyLookDown") - Input.get_action_strength("joyLookUp")
	# When the left stick is moved...
	if InputEventJoypadMotion:
		# ... Rotate the head node and the camera node.
		head.rotate_y(deg_to_rad(-axis_vector.x) * r_joy_sensitivity)
		camera_rotate.rotate_x(deg_to_rad(-axis_vector.y) * r_joy_sensitivity)

	# Limits the camera vertical movement.
	camera_rotate.rotation.x = clamp(camera_rotate.rotation.x, deg_to_rad(-70), deg_to_rad(60))


# Gets the global direction of a vector.
func get_direction(input_vector):
	var direction = (input_vector.x * head.transform.basis.x) + (input_vector.z * head.transform.basis.z)
	return direction


# Aligns the shadow to the floor normal.
func align_y(xform, newy):
	xform.basis.y = newy
	xform.basis.x = -xform.basis.z.cross(newy)
	xform.basis = xform.basis.orthonormalized()
	return xform
