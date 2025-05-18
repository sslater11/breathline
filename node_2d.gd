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
@onready var line_particles: CPUParticles2D = $breathline/line_particles
@onready var background_sprite : Sprite2D = $breathline/camera_path_follow/background
@onready var animation_breathe: AnimationPlayer = $animation_breathe
@onready var sun: Sprite2D = $breathline/camera_path_follow/sun
@onready var moon_glow: Sprite2D = $breathline/camera_path_follow/moon_glow
@onready var text_breath: RichTextLabel = $breathline/camera_path_follow/cloud_for_text/text_breath
@onready var bunny: Node = $bunny
@onready var shit_spray_particles: CPUParticles2D = $bunny/shit_spray_particles
@onready var celebration: Node2D = $breathline/camera_path_follow/Celebration
@onready var headlight_sprite: Sprite2D = $breathline/PathFollow2D/car/headlight_sprite
@onready var line_road_marking: Line2D = $line_road_marking

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
const BEND_MULTIPLIER : float = 1.75
const SPAWN_TIME_OFFSET_IN_MILLIS : int = 10000 #  Add a few seconds to spawn trees/clouds ahead of time.

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
	#Globals.start_time_in_millis -= 4.85 * 60 * 1000 # make it start a bit later
	
	# Make sure both the sprite and path have the same position in
	# the properties setting as this makes the sprite follow the line properly.
	breathline.curve.clear_points()
	
	var bend_size : float = float( LINE_LENGTH_FOR_ONE_SECOND ) * BEND_MULTIPLIER
	var bend_in  : Vector2 = Vector2( 0, 0 )
	var bend_out : Vector2 = Vector2( 0, 0 )

	# Starting point
	if breathline.curve.point_count == 0:
		breathline.curve.add_point( Vector2( START_X, START_Y ) )
	
	for k in range( Globals.total_breath_rounds ):
		print(Globals.total_breath_rounds)
		for i in range( breath_length.size() ):
			var last_x : float = breathline.curve.get_point_position( breathline.curve.point_count - 1 ).x
			var last_y : float = breathline.curve.get_point_position( breathline.curve.point_count - 1 ).y

			var new_x : float = last_x + ( breath_length[ i ] * LINE_LENGTH_FOR_ONE_SECOND )
			var new_y : float = last_y
			
			if i % 2 == 1:
				new_y = last_y
			else:
				if last_y < START_Y:
					new_y += LINE_HEIGHT
				else:
					new_y -= LINE_HEIGHT

			if i % 4 == 0:
				bend_in  = Vector2( -bend_size, 0 )
				bend_out = Vector2( bend_size, -0 )
			elif i % 4 == 1:
				bend_in  = Vector2( -bend_size, 0 )
				bend_out = Vector2( bend_size, 0 )
			elif i % 4 == 2:
				bend_in  = Vector2( -bend_size, 0 )
				bend_out = Vector2( bend_size, 0 )
			elif i % 4 == 1:
				bend_in  = Vector2( -bend_size, 0 )
				bend_out = Vector2( bend_size, 0 )

			breathline.curve.add_point( Vector2( new_x, new_y ), bend_in, bend_out )

	line_road_marking.draw_breathline()
	line_particles.emission_points = breathline.curve.get_baked_points()
	draw_ground()
	
	for i in range( SPAWN_TIME_OFFSET_IN_MILLIS / 20 ):
		var position_on_line : float = float(i) / float( SPAWN_TIME_OFFSET_IN_MILLIS )
		spawn_texture_randomly( all_tree_textures, true, position_on_line, 5 )
		spawn_texture_randomly( all_cloud_textures, false, position_on_line, 25 )

	# Move bunny to the end of the line.
	#var last_point : Vector2 = breathline.curve.get_baked_points()[ breathline.curve.get_baked_points().size() - 1 ]
	#bunny.position = Vector2( last_point.x-140, last_point.y -200)
	
func _process(delta : float) -> void:
	if Globals.is_first_breath and Globals.is_playing:
		Globals.is_first_breath = false
		animation_breathe_in()
	if Input.is_key_pressed(KEY_F):
		if Globals.are_fireworks_on == false:
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

		car.z_index = car.global_position.y - 150
		var current_time_in_millis : int = Time.get_ticks_msec() - Globals.start_time_in_millis
		var current_breath : int = 0

		# Use pure maths to figure out the current breath that we are on.
		var total_breath_length : int = 0
		for i in breath_length:
			total_breath_length += i

		var car_progress = float(current_time_in_millis) / float(Globals.total_time_in_millis)

		if car_progress > 1.0:
			car_progress = 1.0
		# Set the car and camera positions.
		path_follow_2d.progress_ratio     = car_progress
		camera_path_follow.progress_ratio = car_progress
		

		# Animation for each breath.
		# Calculate the current breath.
		# Get the current breath in time as a float
		# Convert the float to a number from 0.0 - 1.0
		var current_breath_as_float : float = (current_time_in_millis / 1000) / float(total_breath_length)
		
		# Working code to time the animations
		var breath : float = (current_time_in_millis / 1000) % total_breath_length

		if breath < breath_length[0]:
			current_breath = 0
		elif breath < breath_length[0] + breath_length[1]:
			current_breath = 1
		elif breath < breath_length[0] + breath_length[1] + breath_length[2]:
			current_breath = 2
		elif breath < breath_length[0] + breath_length[1] + breath_length[2] + breath_length[3]:
			current_breath = 3
		
		
		if current_breath != last_breath:
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

		var spawn_position_as_percent : float = float(current_time_in_millis + SPAWN_TIME_OFFSET_IN_MILLIS) / float( Globals.total_time_in_millis )

		spawn_texture_randomly( all_tree_textures, true, spawn_position_as_percent, 5 )
		spawn_texture_randomly( all_cloud_textures, false, spawn_position_as_percent, 25 )
		update_cloud_locations( delta )

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


func spawn_texture_randomly( all_sprite_textures : Array[Texture2D], is_below_road : bool, position_as_percent : float, spawn_amount : int ) -> void:
	var should_spawn : int = randi_range( 0, spawn_amount )
	if should_spawn == 1:
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
				# Draw clouds anywhere on the background.
				var min_y_offset : float = camera_2d.get_screen_center_position().y - (camera_rect.size.y)
				var max_y_offset : float = camera_2d.get_screen_center_position().y + (camera_rect.size.y / 2)
				
				y_offset = randi_range( min_y_offset, max_y_offset )
		else:
			y_offset = breathline.curve.get_baked_points()[ len( breathline.curve.get_baked_points() ) -1 ].y
			if is_below_road:
				y_offset += randi_range( 0, 200 )
			else:
				y_offset -= randi_range( 0, 200 )

		var sprite : SelfDestroyingSprite = SelfDestroyingSprite.new()
		sprite.centered = false
		sprite.texture = all_sprite_textures[ randi_range(0, len(all_sprite_textures)-1 ) ]
		sprite.position = Vector2( x_offset + randi_range( 0,50 ), y_offset )
		var sprite_scale : float = randf_range( 0.5, 1.0 )
		sprite.scale = Vector2( sprite_scale, sprite_scale )
		
		add_child( sprite )
		if is_below_road:
			sprite.z_index = y_offset + (sprite.texture.get_height() * sprite.scale.y)

			all_trees.append( sprite )
		else:
			sprite.z_index = -1500 + y_offset + (sprite.texture.get_height() * sprite.scale.y)# make it less, so the car and ground can appear in front of the clouds.

			all_clouds.append( sprite )
