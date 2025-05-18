extends Sprite2D
class_name SelfDestroyingSprite

var x_cut_off        : float = 0.0
var y_cut_off_top    : float = 0.0
var y_cut_off_bottom : float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Delete sprite once it's off the left side of the screen
	x_cut_off = get_viewport().get_camera_2d().global_position.x
	x_cut_off -= (get_viewport_rect().size.x)
	x_cut_off -= texture.get_width()

	# Delete sprite that's above the screen.
	y_cut_off_top = get_viewport().get_camera_2d().global_position.y
	y_cut_off_top -= get_viewport_rect().size.y
	y_cut_off_top -= texture.get_height()
	
	
	# Delete sprite that's below the screen.
	y_cut_off_bottom = get_viewport().get_camera_2d().global_position.y
	y_cut_off_bottom += get_viewport_rect().size.y
	y_cut_off_bottom += texture.get_height()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if x_cut_off > global_position.x:
		self.queue_free()
	elif y_cut_off_top > global_position.y:
		queue_free()
	elif y_cut_off_bottom < global_position.y:
		queue_free()
