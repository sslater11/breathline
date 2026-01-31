# © Copyright 2025, Simon Slater
# 
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 2 of the License.
# 
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.

extends Node2D

@onready var path_follow_2d: PathFollow2D = $breathline/PathFollow2D
@onready var line_road_marking: Line2D = $line_road_marking
@onready var breathline: Path2D = $breathline
@onready var wheel_1: Sprite2D = $breathline/PathFollow2D/car/wheel_1
@onready var wheel_2: Sprite2D = $breathline/PathFollow2D/car/wheel_2
@onready var time_up_button: Button = $timer/time_up_button
@onready var time_down_button: Button = $timer/time_down_button
@onready var label_selected_time_in_minutes: RichTextLabel = $timer/label_selected_time_in_minutes

var breathline_in_minutes : int = 5


func _ready() -> void:
	line_road_marking.draw_breathline()
	draw_ground()

func _process(delta: float) -> void:
	path_follow_2d.progress_ratio += delta / 10
	var wheel_speed : float = 5
	wheel_1.rotate( delta * wheel_speed )
	wheel_2.rotate( delta * wheel_speed )

	if Input.is_action_just_pressed("ui_up"):
		_on_time_up_button_pressed()
		
	if Input.is_action_just_pressed("ui_down"):
		_on_time_down_button_pressed()

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

func update_breathline_length() -> void:
	var total_seconds : int = 0
	var total_minutes : int = 0
	var total_breath_rounds : int = 0
	while total_minutes < breathline_in_minutes:
		total_seconds += Globals.get_length_of_a_full_breath_round_in_seconds()
		total_minutes = floor( float(total_seconds) / 60.0 )
		total_breath_rounds += 1
		
	total_breath_rounds += 1 # Add 1 to the total breaths to account for a full breath round at the start of the scene.
	Globals.total_breath_rounds = int( total_breath_rounds )

	label_selected_time_in_minutes.text = str( breathline_in_minutes )
	if breathline_in_minutes == 1:
		label_selected_time_in_minutes.text += " minute"
	else:
		label_selected_time_in_minutes.text += " minutes"

func _on_time_up_button_pressed() -> void:
	breathline_in_minutes += 1
	update_breathline_length()

func _on_time_down_button_pressed() -> void:
	if breathline_in_minutes >= 2:
		breathline_in_minutes -= 1
		update_breathline_length()

