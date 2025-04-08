extends Node2D
@onready var headlights: PointLight2D = $breathline/PathFollow2D/car/headlights
@onready var brakelights: PointLight2D = $breathline/PathFollow2D/car/brakelights
@onready var world_lighting2: DirectionalLight2D = $world_lighting2

@onready var breathline: Path2D = $breathline

@onready var car: Sprite2D = $breathline/PathFollow2D/car
@onready var toilet: Sprite2D = $breathline/PathFollow2D/toilet
@onready var camera_2d: Camera2D = $breathline/camera_path_follow/Camera2D
@onready var headlight_beam: PointLight2D = $breathline/PathFollow2D/car/headlight_beam

@onready var car_trail_particles: CPUParticles2D = $breathline/PathFollow2D/car/car_trail_particles
@onready var toilet_trail_particles: CPUParticles2D = $breathline/PathFollow2D/toilet/toilet_trail_particles
@onready var rain_particles: CPUParticles2D = $breathline/camera_path_follow/rain_particles
@onready var shit_everywhere_particles: GPUParticles2D = $breathline/camera_path_follow/shit_everywhere_particles
@onready var snow_particles: CPUParticles2D = $breathline/camera_path_follow/snow_particles
@onready var wind_particles: GPUParticles2D = $breathline/camera_path_follow/wind_particles

@onready var path_follow_2d: PathFollow2D = $breathline/PathFollow2D
@onready var path_follow_for_trees: PathFollow2D = $breathline/path_follow_for_trees
@onready var camera_path_follow: PathFollow2D = $breathline/camera_path_follow
@onready var icon: Sprite2D = $Icon
@onready var animation_change_color: AnimationPlayer = $animation_change_color
@onready var line_particles: CPUParticles2D = $breathline/line_particles
@onready var background_sprite : Sprite2D = $breathline/camera_path_follow/background
@onready var animation_breathe: AnimationPlayer = $animation_breathe
@onready var sun: Sprite2D = $breathline/camera_path_follow/sun
@onready var moon_glow: Sprite2D = $breathline/camera_path_follow/moon_glow
@onready var text_breath: RichTextLabel = $breathline/camera_path_follow/cloud_for_text/text_breath
@onready var deleteme_testing: Path2D = $breathline/camera_path_follow/Camera2D/deleteme_testing
@onready var bunny: Node = $bunny
@onready var shit_spray_particles: CPUParticles2D = $bunny/shit_spray_particles
@onready var celebration: Node2D = $breathline/camera_path_follow/Celebration
@onready var headlight_sprite: Sprite2D = $breathline/PathFollow2D/car/headlight_sprite

const all_tree_textures : Array[Texture2D] = [
	preload( "res://assets/tree0.png" ),
	preload( "res://assets/tree1.png" ),
	preload( "res://assets/tree2.png" ),
	preload( "res://assets/tree3.png" ),
]

const all_cloud_textures : Array[Texture2D] = [
	preload( "res://assets/cloud0.png" ),
	preload( "res://assets/cloud1.png" ),
	preload( "res://assets/cloud2.png" ),
	preload( "res://assets/cloud3.png" ),
	preload( "res://assets/cloud4.png" ),
]


const LINE_HEIGHT  = 400
const LINE_LENGTH_FOR_ONE_SECOND = 200
const START_X : float = 400.0
const START_Y : float = 800.0
const BEND_MULTIPLIER : float = 1.0


const DARK_SKY  : Color = Color(0.011, 0.244, 0.264) # Really Dark
#const DARK_SKY  : Color = Color(0.055, 0.564, 0.604) # Little bit dark
const LIGHT_SKY : Color = Color(0.592, 0.958, 0.994)

#var breath_length : Array[float] = [2.0, 2.0, 2.0, 2.0]
#var breath_length : Array[float] = [2.0, 2.0, 3.0, 2.0]
#var breath_length : Array[float] = [0.0, 0.0, 4.0, 5.0]# fibonacci 1 3 6 10 
#var breath_length : Array[float] = [4.0, 5.0, 6.0, 7.0]# fibonacci 1 3 6 10 
#var breath_length : Array[float] = [1.0, 2.0, 3.0, 4.0]# fibonacci 1 3 6 10 
													 # should be - 0 1 3 6 10
												  # program says - 0 2 4 7 when if statement <=
												  # program says - 0 1 3 6 when if statement <
var breath_length : Array[float] = [4.0, 7.0, 6.0, 2.0] # Deep Calm from Breathly App
#var breath_length : Array[int] = [2, 2, 2, 2]

var straight_path : Curve2D = Curve2D.new()

var all_trees : Array[Sprite2D] = []
var all_clouds : Array[Sprite2D] = []
var clouds_to_remove : Array[int] = []

var is_blue : bool = false

var has_shit_spray_played : bool = false

var last_breath : int = 0

func set_color() -> void:
	if is_blue:
		animation_change_color.play("color_red")
	else:
		animation_change_color.play("color_blue")
	is_blue = not is_blue

# ChatGPT figured this confusing one out!
# Function to get the percentage of the distance along the path for a given x
func get_percentage_at_x(x: float) -> float:
	var curve : Curve2D = breathline.curve
	var total_length : float = breathline.curve.get_baked_length()

	# Get the number of points in the curve
	var point_count : int = curve.get_point_count()

	# Initialize distance from the start
	var distance_from_start : float = 0.0

	for i in range(point_count - 1):
		var p0 : Vector2 = curve.get_point_position(i)
		var p1 : Vector2 = curve.get_point_position(i + 1)
		
		# Check if x is between the x-coordinates of the current segment
		if ( (p0.x <= x) and ( x <= p1.x) ) or ( (p1.x <= x) and (x <= p0.x) ):
			pass
			#print("vvvvvvvvvvvvvvvvvvvvv")
			# Perform linear interpolation to find the corresponding y
			var t : float = (x - p0.x) / (p1.x - p0.x)
			var y : float = p0.y + (p1.y - p0.y) * t
			
			# Calculate the distance from the start to the point (x, y)
			distance_from_start += p0.distance_to(Vector2(x, y))
			break
		else:
			#print("vvvvvvnnnnnnnnnnnnnnnnnnnnnn")
			# Add the distance of the current segment to the total distance
			distance_from_start += p0.distance_to(p1)
			
	# Calculate the percentage of the distance from the start
	var percentage : float = (distance_from_start / total_length)
	#print("fffffffffffffffffff: percentage: " + str( percentage ) )
	return percentage

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	SoundsScene.start_background_music()
	
	Globals.total_time_in_millis = 0
	for i in breath_length:
		Globals.total_time_in_millis += i * 1000 * Globals.total_breath_rounds

	car.visible = false
	car_trail_particles.emitting = false

	toilet.visible = false
	toilet_trail_particles.emitting = false
	
	rain_particles.emitting = false
	snow_particles.emitting = true
	wind_particles.emitting = true
	shit_everywhere_particles.emitting = false

	Globals.start_time_in_millis = Time.get_ticks_msec()
	#Globals.start_time_in_millis -= 4.75 * 60 * 1000 # make it start a bit later
	
	#breathline.curve.clear_points()
	#breathline.curve.add_point( Vector2( 300, 500 ), Vector2(0,0), Vector2(0,0), 0 )
	#breathline.curve.add_point( Vector2( 0, 400 ), Vector2(0,0), Vector2(0,0), 0 )
	#breathline.curve.add_point( Vector2( 0, 500 ), Vector2(0,0), Vector2(0,0), 0 )
	#breathline.curve.add_point( Vector2( 0, 400 ), Vector2(0,0), Vector2(0,0), 0 )
	
	# Make sure both the sprite and path have the same position in
	# the properties setting as this makes the sprite follow the line properly.
	breathline.curve.clear_points()

	var bend_size : float = float( LINE_LENGTH_FOR_ONE_SECOND ) * BEND_MULTIPLIER
	var bend_up_in    : Vector2 = Vector2(  bend_size, 0.0 )
	var bend_up_out   : Vector2 = Vector2( -bend_size, 0.0 )
	
	var bend_down_in  : Vector2 = Vector2( -bend_size, 0.0 )
	var bend_down_out : Vector2 = Vector2(  bend_size, 0.0 )
	
	var bend_in       : Vector2 = Vector2(    0.0, 0.0 )
	var bend_out      : Vector2 = Vector2(    0.0, 0.0 )

	# Starting point
	if breathline.curve.point_count == 0:
		breathline.curve.add_point( Vector2( START_X, START_Y ) )
		#print( "start_x: " + str(START_X) + "\tstart_y: " + str(START_Y) )
	
	for k in range( Globals.total_breath_rounds ):
		print(Globals.total_breath_rounds)
		for i in range( breath_length.size() ):
			var last_x : float = breathline.curve.get_point_position( breathline.curve.point_count - 1 ).x
			var last_y : float = breathline.curve.get_point_position( breathline.curve.point_count - 1 ).y

			#var new_x : float = 0.0
			#var new_y : float = 0.0

			var new_x : float = last_x + ( breath_length[ i ] * LINE_LENGTH_FOR_ONE_SECOND )
			var new_y : float = last_y
			
			#print( "l_x: " + str(last_x) + "\tl_y: " + str(last_y) )
			#print( breathline.curve.get_point_position( i ) )

			
			if i % 2 == 1:
				new_y = last_y
				#bend = bend_up
				bend_in  = bend_down_in
				bend_out = bend_down_out
				
			else:
				
				bend_in  = bend_down_in
				bend_out = bend_down_out
				
				if last_y < START_Y:
					new_y += LINE_HEIGHT

				else:
					new_y -= LINE_HEIGHT
					#bend = bend_down

			breathline.curve.add_point( Vector2( new_x, new_y ), bend_in, bend_out )
			print("ffffaaaaa: " + str( Vector2( new_x, new_y) ) )
			#breathline.curve.add_point( Vector2( new_x, new_y ), Vector2(0.0,0.0), Vector2(0.0,0.0) )
			
			#print( "new_x: " + str(new_x) + "\tnew_y: " + str(new_y) )
			
			#print( breathline.curve.get_baked_points() )
	
	# add an extra point at the end of the line in hopes it'll move the car further.
	#var last_point = breathline.curve.get_baked_points()[ breathline.curve.get_baked_points().size() -1 ]
	#var last_vector = Vector2( last_point.x +1000, last_point.y )
	#breathline.curve.add_point( last_vector, bend_in, bend_out )
	
	line_particles.emission_points = breathline.curve.get_baked_points()
	draw_ground()
	
	# Move bunny to the end of the line.
	#var last_point : Vector2 = breathline.curve.get_baked_points()[ breathline.curve.get_baked_points().size() - 1 ]
	#bunny.position = Vector2( last_point.x-140, last_point.y -200)
	
func _process(delta : float) -> void:
	if Globals.is_first_breath and Globals.is_playing:
		Globals.is_first_breath = false
		animation_breathe_in()
	if Input.is_key_pressed(KEY_F):
		if Globals.are_fireworks_on == false:
			print("fffffffffffffff ye")
			celebration.visible = true
			#animation_breathe.play("fireworks")
		Globals.are_fireworks_on = true
		
	if Input.is_action_just_pressed("ui_accept"):
		camera_2d.zoom = Vector2( camera_2d.zoom.x*0.5, camera_2d.zoom.y*0.5 )
		if car.visible == true:
			car.visible = false
			car_trail_particles.emitting = false
			
			toilet.visible = true
			toilet_trail_particles.emitting = true
		else:
			car.visible = true
			car_trail_particles.emitting = true
			
			toilet.visible = false
			toilet_trail_particles.emitting = false


	if car.global_position.x > breathline.curve.get_baked_points()[ breathline.curve.get_baked_points().size() -1 ].x - 500:
		if has_shit_spray_played == false:
			has_shit_spray_played = true
			animation_breathe.play("shit_spray")
			car_trail_particles.emitting = false
			#shit_everywhere_particles.emitting = true
			
			animation_breathe.play("fireworks")
			Globals.are_fireworks_on = true
			#Globals.is_playing = false
	if Globals.is_playing:
		if (car.visible == false) and (toilet.visible == false):
			car.visible = true
			car_trail_particles.emitting = true

		car.z_index = car.global_position.y - 150
		var current_time_in_millis : int = Time.get_ticks_msec() - Globals.start_time_in_millis
		var current_breath : int = 0

		# Use pure maths to figure out the current breath that we are on.
		var total_breath_length : int = 0
		for i in breath_length:
			total_breath_length += i
		
		
		
		# Trying different maths to calculate location on the line.
		
		# Formula to calculate the location of the car by the current time.
		#a = total_time_in_millis
		#b = line_length
		#t = current_time_in_millis
		#     ~
		#    / \
		#   / a \
		#  /-----\
		# / b * t \
		#/_________\
		# Get our position along the line in pixels.
		# (a / b) * t
		# TODO BUG:
		# Not sure why, but the car stops moving just before it gets to the end of the line.
		# The distance_to() method seems to only count the distance by the x, meaning it forgets the y coordinates
		# get_baked_length() seems to get the length with the x and y accounted for.
		# yet, doing division of these 2 different numbers seems to put the car perfectly in time with the breaths.
		# It just refuses to go up to 100% of the line's length.
		# Tried a few different things, but nothing works!!!!!!!!!!q
		
		var delta_b : float = (breathline.curve.get_baked_length() / Globals.total_time_in_millis) * current_time_in_millis
		delta_b += breathline.curve.get_baked_points()[0].x

		# Find the point that is closest to the current x location on the line.
		var baked_points : PackedVector2Array = breathline.curve.get_baked_points()
		var current_point : Vector2 = Vector2( 0.0, 0.0 )
		
		var all_closest_points : Array[Vector2] = binary_search_to_get_closest_point_to_x( baked_points, delta_b, 0, baked_points.size()-1)
		current_point = all_closest_points[0]
		
		var dddistance : float = baked_points[0].distance_to( current_point )
		var other_offset : float = dddistance / breathline.curve.get_baked_length()

		# Set the car and camera positions.
		path_follow_2d.progress_ratio     = other_offset
		camera_path_follow.progress_ratio = other_offset
		



		# Split the line into breaths
		# Get the current breath in time as a float
		# Convert the float to a number from 0.0 - 1.0
		var current_breath_as_float : float = (current_time_in_millis / 1000) / float(total_breath_length)
		
		# Working code to time the animations
		var breath : float = (current_time_in_millis / 1000) % total_breath_length
		#print( "b: " + str( breath ) )
		if breath < breath_length[0]:
			current_breath = 0
		elif breath < breath_length[0] + breath_length[1]:
			current_breath = 1
		elif breath < breath_length[0] + breath_length[1] + breath_length[2]:
			current_breath = 2
		elif breath < breath_length[0] + breath_length[1] + breath_length[2] + breath_length[3]:
			current_breath = 3
		
		
		
		if current_breath != last_breath:
			#print()
			#print( "breath: " + str( breath ) )
			#print( "current_breath: " + str( current_breath ) )
			#print()

			#print("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
			last_breath = current_breath
			if current_breath % 4 == 0:
				animation_breathe_in()

			if current_breath % 4 == 1:
				set_text_breath("HOLD")
				print("hold after breath in")
				SoundsScene.play_breathe_hold()


			if current_breath % 4 == 2:
				animation_breathe_out()

			if current_breath % 4 == 3:
				set_text_breath("HOLD")
				SoundsScene.play_breathe_hold()
				print("hold after breath out")
		
		spawn_texture_randomly( all_tree_textures, true, 5 )
		spawn_texture_randomly( all_cloud_textures, false, 25 )
		#remove_old_trees()
		update_cloud_locations( delta )
		#remove_old_clouds()

# Calculate the distance to a point along the x axis,
# whilst taking into account the distance traveled along the y axis.
# This can only calculate the distance for lines in one direction, not loops or steps backwards.
# If the exact x co-ordinate is not found, it will look to find the closes point and calculate the distance from that point to the end point passed.
func euclidean_distance_to_x( path_2d : Path2D, end_point : Vector2 ) -> float:
	var length : float = 0.0
	var baked_points : PackedVector2Array = path_2d.curve.get_baked_points()
	if len( baked_points ) == 0:
		return 0.0
		
	var previous_point : Vector2 = baked_points[0]
	for i in range( len( baked_points ) ):
		var point_1 : Vector2 = previous_point
		var point_2 : Vector2 = baked_points[ i ]
		
		if baked_points[i].x >= end_point.x:
			point_2 = end_point
			# Calculate the distance between the two points using the Euclidean distance formula
			var distance : float = ( abs(point_2.x - point_1.x) ** 2 + abs(point_2.y - point_1.y) ** 2 ) ** 0.5
			length += distance
			break
		else:
			# Calculate the distance between the two points using the Euclidean distance formula
			var distance : float = ( abs(point_2.x - point_1.x) ** 2 + abs(point_2.y - point_1.y) ** 2 ) ** 0.5
			length += distance
		previous_point = point_2

	return length


func animation_breathe_in() -> void:
	set_text_breath("IN")
	SoundsScene.play_breathe_in()
	print("breathe in")
	#animation_breathe.play("breath_in_complete")
	var tween : Tween = get_tree().create_tween()
	var tween_length : float = breath_length[0] - 0.2
	tween.set_parallel( true )

	tween.tween_property( world_lighting2, "energy", 0.45, tween_length )
	
	tween.tween_property( sun, "modulate", Color(3.0, 3.0, 3.0, 1.0 ), tween_length )
	tween.tween_property( moon_glow, "modulate", Color(1, 1, 1, 0.0 ), tween_length * 1.85 )
	
	tween.tween_property( background_sprite, "modulate", LIGHT_SKY, tween_length )
	#tween.tween_property( headlights, "energy", 0, tween_length / 2.0 )
	tween.tween_property( brakelights, "energy", 0, tween_length / 2.0 )
	
	tween.tween_property( headlight_beam, "energy", 0.0, tween_length / 2.0 )


func animation_breathe_out() -> void:
	set_text_breath("OUT")
	SoundsScene.play_breathe_out()
	#animation_breathe.play("breathe_out")
	#background.modulate.r = 0.5
	#background.modulate.g = 0.5
	print("breathe out")
	var tween : Tween = get_tree().create_tween()
	var tween_length : float = breath_length[2] - 0.2
	#tween.tween_property( sun, "modulate", Color(10, 10, 10, 0.100 ), tween_length )
	tween.set_parallel( true )

	tween.tween_property( world_lighting2, "energy", 0.5, tween_length )
	tween.tween_property( sun, "modulate", Color(1.0, 1.0, 1.0, 0.0 ), tween_length )

	# The glow has a different tween_length, because it takes a while to kick in and looks different.
	# The glow won't show up when the screen size is too small, probably because the light pixels are behind the image.
	#tween.tween_property( moon_glow, "modulate", Color(15, 10, 5, 0.100 ), (tween_length * 0.72) ) # perfect moon glow when no scene light change
	tween.tween_property( moon_glow, "modulate", Color(20, 15, 8, 0.100 ), (tween_length * 0.6) ) # perfect moon glow when scene light darkens
	tween.tween_property( background_sprite, "modulate", DARK_SKY, tween_length )
	
	# working headlight brightness on pc.
	tween.tween_property( headlights, "energy", 75, tween_length / 2.0 )
	tween.tween_property( brakelights, "energy", 75, tween_length / 2.0 )

	tween.tween_property( headlight_beam, "energy", 2.5, tween_length )


# tartget_x is the x offset we are trying to find the closest point for.
func binary_search_to_get_closest_point_to_x( all_points : PackedVector2Array, target_x : float, index_low : int, index_high : int ) -> Array[Vector2]:
	var index_middle : int = index_low + (( index_high - index_low ) / 2)

	if all_points[index_middle].x == target_x:
		return [ all_points[index_middle] ]
	
	if index_low == index_high:
		return[ all_points[index_low] ]
	
	if index_low == (index_high - 1):
		return[ all_points[ index_low ], all_points[ index_low ] ]
	
	if all_points[ index_middle ].x <= target_x:
		return binary_search_to_get_closest_point_to_x( all_points, target_x, index_middle, index_high   )
	elif all_points[ index_middle].x >= target_x:
		return binary_search_to_get_closest_point_to_x( all_points, target_x, index_low   , index_middle )
	else:
		return []

func set_text_breath( text : String ) -> void:
	text_breath.text = "[center][font_size=30][color=black][b]" + text + "[/b][/color][/font_size][/center]"

func update_cloud_locations( delta : float) -> void:
	for i in range(0, len(all_clouds) ):
		if all_clouds[i] == null:
			continue
			
		var cloud_position : Vector2 = Vector2( all_clouds[i].global_position.x, all_clouds[i].global_position.y )
		cloud_position.x -= delta * 14 * ( abs(all_clouds[i].global_position.y) / 100.0) # 1#car.global_position.x
		all_clouds[i].position = cloud_position
		
		var x_cut_off : float = camera_path_follow.position.x
		x_cut_off -= camera_2d.get_viewport_rect().end.x * 1.25

		if( all_clouds[i].global_position.x < x_cut_off ):
			clouds_to_remove.append( i )


func draw_ground() -> void:
	var camera_rect : Rect2 = camera_2d.get_viewport_rect()
	const LINE_WIDTH_MULTIPLIER = 10
	const LINE_COUNT = 20
	const GROUND_COLOR : Color = Color( 0.5, 0.0, 0.0 )
	
	# draw the ground before the breathline
	for i in range(0, LINE_COUNT ):
		var line : Line2D = Line2D.new()
		line.z_index = -1
		line.width = line.width * LINE_WIDTH_MULTIPLIER
		line.default_color = GROUND_COLOR
		
		var breathline_starting_point : Vector2 = breathline.curve.get_baked_points()[0]
		breathline_starting_point.y = breathline_starting_point.y + (i * (line.width/2) + line.width)
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
		line.width = line.width * LINE_WIDTH_MULTIPLIER
		line.default_color = GROUND_COLOR
		for k in breathline.curve.get_baked_points():
			line.add_point( Vector2( k.x, k.y + (i * (line.width/2) ) + (line.width) ) )
			#line.add_point( Vector2( k.x, k.y + 500 ) )
		#all_ground_lines.append(line)
		add_child( line )
		
		
	# draw the after before the breathline
	for i in range(0, LINE_COUNT ):
		var line : Line2D = Line2D.new()
		line.z_index = -1
		line.width = line.width * LINE_WIDTH_MULTIPLIER
		line.default_color = GROUND_COLOR
		
		var breathline_ending_point : Vector2 = breathline.curve.get_baked_points()[ len(breathline.curve.get_baked_points()) -1 ]
		breathline_ending_point.y = breathline_ending_point.y + (i * (line.width/2) + line.width)
		var ending_point : Vector2 = Vector2( breathline_ending_point.x + camera_rect.size.x, breathline_ending_point.y )
		line.add_point( ending_point )
		line.add_point( breathline_ending_point )
			#line.add_point( Vector2( k.x, k.y + 500 ) )
		#all_ground_lines.append(line)
		add_child( line )

	

	
func spawn_texture_randomly( all_sprite_textures : Array[Texture2D], is_below_road : bool, spawn_amount : int ) -> void:
	var should_spawn : int = randi_range( 0, spawn_amount )
	if should_spawn == 1:
		# get the position to spawn the tree.
		var current_time_in_millis : int = Time.get_ticks_msec() - Globals.start_time_in_millis
		current_time_in_millis += 10000 # add a few seconds to spawn trees ahead of time.
		var position_as_percent : float = float(current_time_in_millis) / float( Globals.total_time_in_millis )
		var y_offset : float = 0
		var x_offset : float = 0
		
		if position_as_percent < 1.0:
			path_follow_for_trees.progress_ratio = position_as_percent
			x_offset = path_follow_for_trees.position.x
			y_offset = path_follow_for_trees.position.y
			
			var camera_rect : Rect2 = camera_2d.get_viewport_rect()
			if is_below_road:
				y_offset += randi_range( 0, get_viewport().get_camera_2d().global_position.y )

			else:
				# Working, this draws clouds above the path.
				#var max_y_offset = y_offset - camera_rect.size.y
				#y_offset -= abs( randi_range( y_offset, max_y_offset ) )
				
				# Instead though, it's better to have clouds appear anywhere, as that stops gaps from showing up.
				var min_y_offset : float = camera_2d.get_screen_center_position().y - (camera_rect.size.y)
				var max_y_offset : float = camera_2d.get_screen_center_position().y + (camera_rect.size.y / 2)
				
				y_offset = randi_range( min_y_offset, max_y_offset )
		else:
			y_offset = breathline.curve.get_baked_points()[ len( breathline.curve.get_baked_points() ) -1 ].y
			if is_below_road:
				y_offset += randi_range( 0, 200 )
			else:
				y_offset -= randi_range( 0, 200 )

		
		#var sprite : Sprite2D = Sprite2D.new()
		var sprite : SelfDestroyingSprite = SelfDestroyingSprite.new()
		sprite.centered = false
		sprite.texture = all_sprite_textures[ randi_range(0, len(all_sprite_textures)-1 ) ]
		sprite.position = Vector2( x_offset + randi_range( 0,50 ), y_offset )
		var sprite_scale : float = randf_range( 0.5, 1.0 )
		sprite.scale = Vector2( sprite_scale, sprite_scale )
		
		
		
		var visible_on_screen_notifier : VisibleOnScreenNotifier2D = VisibleOnScreenNotifier2D.new()
		visible_on_screen_notifier.position = Vector2( visible_on_screen_notifier.position.x, visible_on_screen_notifier.position.y )
		visible_on_screen_notifier.has_signal("screen_exited")
		sprite.add_child( visible_on_screen_notifier )

		
		
		
		
		add_child( sprite )
		if is_below_road:
			sprite.z_index = y_offset

			all_trees.append( sprite )
		else:
			sprite.z_index = -1000 + y_offset # make it less, so the car and ground can appear in front of the clouds.

			all_clouds.append( sprite )
	

	# Find the current position
	# add 10 seconds to the position.
	# If the position doesn't exit(out of bounds)
	#		then just use the last y coordinates
