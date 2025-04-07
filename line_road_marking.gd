extends Line2D
@onready var breathline: Path2D = $"../breathline"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	clear_points()
	
	for i in range( len( breathline.curve.get_baked_points() ) ):
		var y_offset = 50
		var position : Vector2 = Vector2( breathline.curve.get_baked_points()[i].x, breathline.curve.get_baked_points()[i].y + y_offset )
		add_point( position )
	
