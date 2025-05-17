extends Line2D
@onready var breathline: Path2D = $"../breathline"

func draw_breathline() -> void:
	clear_points()
	
	for i in range( len( breathline.curve.get_baked_points() ) ):
		var y_offset : float = 50
		var position : Vector2 = Vector2( breathline.curve.get_baked_points()[i].x, breathline.curve.get_baked_points()[i].y + y_offset )
		add_point( position )
