extends Node2D

@onready var path_follow_2d: PathFollow2D = $breathline/PathFollow2D
@onready var line_road_marking: Line2D = $line_road_marking
@onready var breathline: Path2D = $breathline
@onready var wheel_1: Sprite2D = $breathline/PathFollow2D/car/wheel_1
@onready var wheel_2: Sprite2D = $breathline/PathFollow2D/car/wheel_2

func _ready() -> void:
	line_road_marking.draw_breathline()
	draw_ground()

func _process(delta: float) -> void:
	path_follow_2d.progress_ratio += delta / 10
	var wheel_speed : float = 5
	wheel_1.rotate( delta * wheel_speed )
	wheel_2.rotate( delta * wheel_speed )

func draw_ground() -> void:
	var camera_rect : Rect2 = get_viewport_rect()
	const LINE_COUNT = 30
	const GROUND_COLOR : Color = Color( 0.5, 0.0, 0.0 )
	var y_offset = line_road_marking.width * 3
	
	# Draw the ground before the breathline starts.
	for i in range(0, LINE_COUNT ):
		var line : Line2D = Line2D.new()
		line.z_index = -1
		line.width = line_road_marking.width
		line.default_color = GROUND_COLOR
		
		var breathline_starting_point : Vector2 = breathline.curve.get_baked_points()[0]
		breathline_starting_point.x += 5 # padding to avoid a gap showing.
		breathline_starting_point.y = breathline_starting_point.y + (i * line.width) + y_offset
		var starting_point : Vector2 = Vector2( breathline_starting_point.x - camera_rect.size.x, breathline_starting_point.y )
		line.add_point( starting_point )
		line.add_point( breathline_starting_point )
			#line.add_point( Vector2( k.x, k.y + 500 ) )
		#all_ground_lines.append(line)
		add_child( line )


	# Draw the ground for the main breathline
	#var all_ground_lines : Array[ Line2D ] = []
	for i in range(0, LINE_COUNT ):
		var line : Line2D = Line2D.new()
		line.z_index = -1
		line.width = line_road_marking.width
		line.default_color = GROUND_COLOR
		for k in breathline.curve.get_baked_points():
			line.add_point( Vector2( k.x, k.y + (i * (line.width) + y_offset) ) )
		add_child( line )
		
		
	# Draw the ground after the breathline has finished.
	for i in range( 0, LINE_COUNT ):
		var line : Line2D = Line2D.new()
		line.z_index = -1
		line.width = line_road_marking.width
		line.default_color = Color.AQUA
		
		var breathline_ending_point : Vector2 = breathline.curve.get_baked_points()[ len(breathline.curve.get_baked_points()) -1 ]
		breathline_ending_point.y = breathline_ending_point.y + (i * line.width) + y_offset
		var ending_point : Vector2 = Vector2( breathline_ending_point.x + camera_rect.size.x, breathline_ending_point.y )
		line.add_point( ending_point )
		line.add_point( breathline_ending_point )
		add_child( line )
