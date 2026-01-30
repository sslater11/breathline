# © Copyright 2025, Simon Slater
# 
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 2 of the License.
# 
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.

extends Node2D
@onready var spotlight: PointLight2D = $breathline/PathFollow2D/vehicle/helicopter/spotlight
@onready var headlights: PointLight2D = $breathline/PathFollow2D/vehicle/car/headlights
@onready var brakelights: PointLight2D = $breathline/PathFollow2D/vehicle/car/brakelights
@onready var headlight_beam: PointLight2D = $breathline/PathFollow2D/vehicle/headlight_beam
@onready var world_lighting2: DirectionalLight2D = $world_lighting2

@onready var car_headlight_beam_anchor: Node2D = $breathline/PathFollow2D/vehicle/car_headlight_beam_anchor
@onready var helicopter_headlight_beam_anchor: Node2D = $breathline/PathFollow2D/vehicle/helicopter_headlight_beam_anchor


@onready var breathline: Path2D = $breathline

@onready var vehicle: Node2D = $breathline/PathFollow2D/vehicle
@onready var helicopter: Sprite2D = $breathline/PathFollow2D/vehicle/helicopter
@onready var car: Sprite2D = $breathline/PathFollow2D/vehicle/car
@onready var wheel_1: Sprite2D = $breathline/PathFollow2D/vehicle/car/wheel_1
@onready var wheel_2: Sprite2D = $breathline/PathFollow2D/vehicle/car/wheel_2
@onready var toilet: Sprite2D = $breathline/PathFollow2D/toilet
@onready var camera_2d: Camera2D = $breathline/camera_path_follow/Camera2D

@onready var car_trail_particles: CPUParticles2D = $breathline/PathFollow2D/vehicle/car/car_trail_particles
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
@onready var headlight_sprite: Sprite2D = $breathline/PathFollow2D/vehicle/car/headlight_sprite
@onready var line_road_marking: Line2D = $line_road_marking

@onready var tree_0: AnimatedSprite2D = $tree0
@onready var tree_1: AnimatedSprite2D = $tree1
@onready var tree_2: AnimatedSprite2D = $tree2
@onready var tree_3: AnimatedSprite2D = $tree3
@onready var pine_tree_1: AnimatedSprite2D = $pine_tree1
@onready var pine_tree_2: AnimatedSprite2D = $pine_tree2
@onready var sheep: AnimatedSprite2D = $sheep

@onready var cloud_0: AnimatedSprite2D = $cloud0
@onready var cloud_1: AnimatedSprite2D = $cloud1
@onready var cloud_2: AnimatedSprite2D = $cloud2
@onready var cloud_3: AnimatedSprite2D = $cloud3


const START_X : float = 400.0
const START_Y : float = 800.0
const SPAWN_TIME_OFFSET_IN_MILLIS : int = 10000 #  Add a few seconds to spawn trees/clouds ahead of time.

const DARK_SKY  : Color = Color(0.011, 0.244, 0.264) # Really Dark
#const DARK_SKY  : Color = Color(0.055, 0.564, 0.604) # Little bit dark
const LIGHT_SKY : Color = Color(0.592, 0.958, 0.994)


var straight_path : Curve2D = Curve2D.new()

# These are to keep all sprites that are made using godot's gui.
var all_animated_trees  : Array[AnimatedSprite2D] = []
var all_animated_clouds : Array[AnimatedSprite2D] = []

# For keeping track of all the automatically generated sprites.
var all_trees  : Array[AnimatedSprite2D] = []
var all_clouds : Array[AnimatedSprite2D] = []
var clouds_to_remove : Array[int] = []

var is_blue : bool = false

var has_shit_spray_played : bool = false

var last_breath : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	all_animated_trees  = [ sheep, pine_tree_1, pine_tree_2, tree_0 , tree_1 , tree_2 , tree_3  ]
	all_animated_clouds = [ cloud_0, cloud_1, cloud_2, cloud_3 ]

	randomize()
	SoundsScene.start_background_music()
	
	SignalBus.car_chosen.connect( switch_to_car )
	SignalBus.helicopter_chosen.connect( switch_to_helicopter )
	

	vehicle.visible = false
	car_trail_particles.emitting = false

	toilet.visible = false
	toilet_trail_particles.emitting = false
	
	rain_particles.emitting = false
	snow_particles.emitting = true
	wind_particles.emitting = true
	shit_everywhere_particles.emitting = false

	Globals.total_time_in_millis = Globals.get_length_of_a_full_breath_round_in_millis() * Globals.total_breath_rounds
	Globals.start_time_in_millis = Time.get_ticks_msec()
	#Globals.start_time_in_millis -= 4.75 * 60 * 1000 # make it start a bit later
	#Globals.start_time_in_millis -= 2.85 * 60 * 1000 # make it start a bit later
	
	# Make sure both the sprite and path have the same position in
	# the properties setting as this makes the sprite follow the line properly.
	breathline.curve.clear_points()
	
	var bend_size : float = float( Globals.line_length_for_one_second ) * Globals.bend_multiplier
	var bend_in  : Vector2 = Vector2( -bend_size, 0 )
	var bend_out : Vector2 = Vector2( bend_size,  0 )

	# Starting point
	if breathline.curve.point_count == 0:
		breathline.curve.add_point( Vector2( START_X, START_Y ) )


	# The rest of the breathline points.
	for k in range( Globals.total_breath_rounds ):
		print(Globals.total_breath_rounds)
		for i in range( Globals.breath_length.size() ):
			var last_x : float = breathline.curve.get_point_position( breathline.curve.point_count - 1 ).x
			var last_y : float = breathline.curve.get_point_position( breathline.curve.point_count - 1 ).y

			var new_x : float = last_x + ( Globals.breath_length[ i ] * Globals.line_length_for_one_second )
			var new_y : float = last_y
			
			if i % 2 == 1:
				new_y = last_y
			else:
				if last_y < START_Y:
					new_y += Globals.line_height
				else:
					new_y -= Globals.line_height

			if i % 4 == 0:
				bend_in  = Vector2( -bend_size, 0 )
				bend_out = Vector2( bend_size,  0 )
			elif i % 4 == 1:
				bend_in  = Vector2( -bend_size, 0 )
				bend_out = Vector2( bend_size,  0 )
			elif i % 4 == 2:
				bend_in  = Vector2( -bend_size, 0 )
				bend_out = Vector2( bend_size,  0 )
			elif i % 4 == 1:
				bend_in  = Vector2( -bend_size, 0 )
				bend_out = Vector2( bend_size,  0 )

			breathline.curve.add_point( Vector2( new_x, new_y ), bend_in, bend_out )

	line_road_marking.draw_breathline()
	line_particles.emission_points = breathline.curve.get_baked_points()
	draw_ground()
	
	# TODO:
	# figure out a better way of generating the trees and clouds dynamically.
	# This only works for the 2 time lengths we've set.
	if Globals.total_breath_rounds == 1:
		# Setup trees and clouds for demo scene
		for i in range( SPAWN_TIME_OFFSET_IN_MILLIS * 0.525 ):
			var position_on_line : float = float(i) / float( SPAWN_TIME_OFFSET_IN_MILLIS )
			spawn_texture_randomly( all_animated_trees , true , position_on_line, 50  )
			spawn_texture_randomly( all_animated_clouds, false, position_on_line, 250 )

	else:
		# Setup trees and clouds for main game
		var current_time_in_millis : int = Time.get_ticks_msec() - Globals.start_time_in_millis + Globals.start_time_offset_in_millis
		var final_spawn_position_in_millis = get_length_of_breathline_on_screen_in_millis() + current_time_in_millis

		for i in range(0, final_spawn_position_in_millis, 10 ):
			var spawn_position_as_percent : float = float(i) / float( Globals.total_time_in_millis )

			spawn_texture_randomly( all_animated_trees , true , spawn_position_as_percent, 5  )
			spawn_texture_randomly( all_animated_clouds, false, spawn_position_as_percent, 25 )

	# Move bunny to the end of the line.
	#var last_point : Vector2 = breathline.curve.get_baked_points()[ breathline.curve.get_baked_points().size() - 1 ]
	#bunny.position = Vector2( last_point.x-140, last_point.y -200)
	
func _process(delta : float) -> void:
	if (snow_particles.emitting == false) and (Globals.is_playing == true):
		snow_particles.preprocess = 0.0
	snow_particles.emitting = Globals.is_playing
	
	if Input.is_key_pressed(KEY_F):
		if Globals.are_fireworks_on == false:
			celebration.visible = true
			#animation_breathe.play("fireworks")
		Globals.are_fireworks_on = true


	if Globals.is_playing:
		if (vehicle.visible == false) and (toilet.visible == false):
			vehicle.visible = true

		vehicle.z_index = vehicle.global_position.y - 150
		var current_time_in_millis : int = Time.get_ticks_msec() - Globals.start_time_in_millis + Globals.start_time_offset_in_millis


		var car_progress = float(current_time_in_millis) / float(Globals.total_time_in_millis)

		if car_progress > 1.0:
			car_progress = 1.0
		else:
			var wheel_speed : float = 5
			wheel_1.rotate( delta * wheel_speed )
			wheel_2.rotate( delta * wheel_speed )
		# Set the car and camera positions.
		path_follow_2d.progress_ratio     = car_progress
		camera_path_follow.progress_ratio = car_progress
		
		
		if vehicle.global_position.x > breathline.curve.get_baked_points()[ breathline.curve.get_baked_points().size() -1 ].x - 500:
			if Globals.has_celebration_sound_played == false:
				SoundsScene.play_celebration()
				Globals.has_celebration_sound_played = true
			
			if has_shit_spray_played == false:
				has_shit_spray_played = true
				animation_breathe.play("shit_spray")
				car_trail_particles.emitting = false
				#shit_everywhere_particles.emitting = true
				
				animation_breathe.play("fireworks")
				Globals.are_fireworks_on = true
			#Globals.is_playing = false


		# Animation for each breath.
		# Calculate the current breath.
		var breath : int = (current_time_in_millis / 1000) % Globals.get_length_of_a_full_breath_round_in_seconds()
		var current_breath : int = 0

		if (current_time_in_millis - Globals.get_length_of_a_full_breath_round_in_millis() <= 0):
			current_breath = -1
		elif breath < Globals.breath_length[0]:
			current_breath = 0
		elif breath < Globals.breath_length[0] + Globals.breath_length[1]:
			current_breath = 1
		elif breath < Globals.breath_length[0] + Globals.breath_length[1] + Globals.breath_length[2]:
			current_breath = 2
		elif breath < Globals.breath_length[0] + Globals.breath_length[1] + Globals.breath_length[2] + Globals.breath_length[3]:
			current_breath = 3
		
		
		if (current_breath != last_breath):
			last_breath = current_breath
			
			if current_breath == -1:
				animation_scene_start()

			elif current_breath % 4 == 0:
				animation_breathe_in()

			elif current_breath % 4 == 1:
				set_text_breath("HOLD")
				print("hold after breath in")
				SoundsScene.play_breathe_hold()

			elif current_breath % 4 == 2:
				animation_breathe_out()

			elif current_breath % 4 == 3:
				set_text_breath("HOLD")
				SoundsScene.play_breathe_hold()
				print("hold after breath out")

		var final_spawn_position_in_millis = get_length_of_breathline_on_screen_in_millis() + current_time_in_millis
		var spawn_position_as_percent : float = final_spawn_position_in_millis / float( Globals.total_time_in_millis )

		spawn_texture_randomly( all_animated_trees , true , spawn_position_as_percent, 5  )
		spawn_texture_randomly( all_animated_clouds, false, spawn_position_as_percent, 25 )
		update_cloud_locations( delta )

func get_length_of_breathline_on_screen_in_millis() -> int:
	var line_length_on_screen_in_seconds : float = (get_viewport_rect().size.x / get_viewport().get_camera_2d().zoom.x) / Globals.line_length_for_one_second
	return int( line_length_on_screen_in_seconds * 1000 )

func animation_scene_start() -> void:
	set_text_breath("")
	print("scene start")
	var tween : Tween = get_tree().create_tween()
	var tween_length : float = Globals.breath_length[0] - 0.2
	tween.set_parallel( true )

	# Set to 0 in compatibility mode.
	tween.tween_property( world_lighting2, "energy", 0.0, tween_length )
	# use 0.45 when the project is in mobile mode.
	#tween.tween_property( world_lighting2, "energy", 0.45, tween_length )
	
	tween.tween_property( sun, "modulate", Color(3.0, 3.0, 3.0, 1.0 ), tween_length )
	tween.tween_property( moon_glow, "modulate", Color(1, 1, 1, 0.0 ), tween_length * 1.85 )
	
	tween.tween_property( background_sprite, "modulate", LIGHT_SKY, tween_length )
	#tween.tween_property( headlights, "energy", 0, tween_length / 2.0 )
	tween.tween_property( brakelights, "energy", 0, tween_length / 2.0 )
	
	tween.tween_property( spotlight,      "energy", 0.0, tween_length / 2.0 )
	tween.tween_property( headlight_beam, "energy", 0.0, tween_length / 2.0 )

func animation_breathe_in() -> void:
	set_text_breath("IN")
	SoundsScene.play_breathe_in()
	print("breathe in")
	#animation_breathe.play("breath_in_complete")
	var tween : Tween = get_tree().create_tween()
	var tween_length : float = Globals.breath_length[0] - 0.2
	tween.set_parallel( true )

	# Set to 0 in compatibility mode.
	tween.tween_property( world_lighting2, "energy", 0.0, tween_length )
	# use 0.45 when the project is in mobile mode.
	#tween.tween_property( world_lighting2, "energy", 0.45, tween_length )
	
	tween.tween_property( sun, "modulate", Color(3.0, 3.0, 3.0, 1.0 ), tween_length )
	tween.tween_property( moon_glow, "modulate", Color(1, 1, 1, 0.0 ), tween_length * 1.85 )
	
	tween.tween_property( background_sprite, "modulate", LIGHT_SKY, tween_length )
	#tween.tween_property( headlights, "energy", 0, tween_length / 2.0 )
	tween.tween_property( brakelights, "energy", 0, tween_length / 2.0 )
	
	tween.tween_property( spotlight,      "energy", 0.0, tween_length / 2.0 )
	tween.tween_property( headlight_beam, "energy", 0.0, tween_length / 2.0 )


func animation_breathe_out() -> void:
	set_text_breath("OUT")
	SoundsScene.play_breathe_out()
	#animation_breathe.play("breathe_out")
	#background.modulate.r = 0.5
	#background.modulate.g = 0.5
	print("breathe out")
	var tween : Tween = get_tree().create_tween()
	var tween_length : float = Globals.breath_length[2] - 0.2
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

	tween.tween_property( spotlight,      "energy", 1.0, tween_length )
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


func spawn_texture_randomly( all_animated_sprites : Array[AnimatedSprite2D], is_below_road : bool, position_as_percent : float, spawn_amount : int ) -> void:
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

		var random_sprite : AnimatedSprite2D = all_animated_sprites[ randi_range( 0, all_animated_sprites.size()-1 ) ]
		var sprite : SelfDestroyingSprite = SelfDestroyingSprite.new()
		sprite.offset = random_sprite.offset
		sprite.centered = false
		sprite.sprite_frames = random_sprite.sprite_frames
		sprite.frame = randi_range( 0, sprite.sprite_frames.get_frame_count("default") )
		sprite.position = Vector2( x_offset + randi_range( 0,50 ), y_offset )
		var sprite_scale : float = randf_range( 0.5, 1.0 )
		sprite.scale = Vector2( sprite_scale, sprite_scale )
		sprite.play("default")
		
		add_child( sprite )
		if is_below_road:
			sprite.z_index = y_offset + (sprite.get_texture_of_current_frame().get_height() * sprite.scale.y)
			sprite.z_index += sprite.offset.y * sprite.scale.y

			all_trees.append( sprite )
		else:
			sprite.z_index = -1500 + y_offset + (sprite.get_texture_of_current_frame().get_height() * sprite.scale.y)# make it less, so the car and ground can appear in front of the clouds.

			all_clouds.append( sprite )

func switch_to_car() -> void:
	headlight_beam.position = car_headlight_beam_anchor.position
	car.visible = true
	helicopter.visible = false

func switch_to_helicopter() -> void:
	headlight_beam.position = helicopter_headlight_beam_anchor.position
	car.visible = false
	helicopter.visible = true
