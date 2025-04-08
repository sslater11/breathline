extends Sprite2D
class_name SelfDestroyingSprite

var x_cut_off        : float = 0.0
var y_cut_off_top    : float = 0.0
var y_cut_off_bottom : float = 0.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	x_cut_off        = get_viewport().get_camera_2d().global_position.x - (get_viewport().get_camera_2d().get_viewport_rect().size.x * 1.5)
	y_cut_off_top    = get_viewport().get_camera_2d().global_position.y - (get_viewport().get_camera_2d().get_viewport_rect().size.y * 1.75)
	y_cut_off_bottom = get_viewport().get_camera_2d().global_position.y + (get_viewport().get_camera_2d().get_viewport_rect().size.y * 1.75)

	pass
	#var texture_width : int = texture.get_width() * scale.x
	#var visible_on_screen_notifier = VisibleOnScreenNotifier2D.new()
	#visible_on_screen_notifier.position = Vector2( visible_on_screen_notifier.position.x-texture_width, visible_on_screen_notifier.position.y )
	#visible_on_screen_notifier.has_signal("hidden")
	#
	#visible_on_screen_notifier.connect( "hidden", gone_off_screen)
	#
	#self.add_child( visible_on_screen_notifier )


	# Check if the node's bounding box is off the screen
	#if global_rect.position.x + global_rect.size.x < 0 or global_rect.position.x > viewport_size.x or global_rect.position.y + global_rect.size.y < 0 or global_rect.position.y > viewport_size.y:
		#print("nnnnnnnnnnnNode is off the screen")
		#queue_free()
	#else:
		#print("nnnnnnnnnnnnnnnnNode is on the screen")



func gone_off_screen() -> void:
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print("xxxxxxxxxxxxxxxxxxx yeah " + str(x_cut_off))

	if global_position.x < x_cut_off:
		self.queue_free()
	elif global_position.y < y_cut_off_top:
		queue_free()
	elif global_position.y > y_cut_off_bottom:
		queue_free()
