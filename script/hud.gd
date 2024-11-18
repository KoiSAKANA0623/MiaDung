extends Node2D


@onready var Pointer = $Pointer

var is_important = false

# Called when the node enters the scene tree for the first time.
func _ready():
#	Pointer.position = get_viewport_rect().size/2.0
	if Global.retro_mode == true:
		Engine.max_fps = 30
		get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
		return
	else:
		Engine.max_fps = 60
		get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
		return


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	is_important = Global.is_looking

#	if not is_important:
#		Pointer.set_region_rect(Rect2(16, 0, 16, 16))
#	else:
#		Pointer.set_region_rect(Rect2(0, 0, 16, 16))

	if Input.is_action_just_pressed("ui_text_indent"):
		if Global.retro_mode == false:
			Engine.max_fps = 30
			get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
			Global.retro_mode = true
			return
		else:
			Engine.max_fps = 60
			get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
			Global.retro_mode = false
			return
