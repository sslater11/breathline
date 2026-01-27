# © Copyright 2025, Simon Slater
# 
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 2 of the License.
# 
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.

extends Node

var is_start_button_visible : bool = true
var is_playing : bool= false
var are_fireworks_on : bool = false
var start_time_offset_in_millis : int = 0
var start_time_in_millis : int = 0
var total_time_in_millis : int = 0
var paused_time_in_millis : int = 0
var total_breath_rounds : int = 16 + 1 # Add 1 to the total breaths to account for a full breath round at the start of the scene.
var has_celebration_sound_played : bool = false

var breath_length : Array[int] = []
var line_height : int = -1
var line_length_for_one_second : int = -1
var bend_multiplier : float = 0.0

var _memo_length_of_a_full_breath_round_in_seconds : int = -1
var _memo_length_of_a_full_breath_round_in_millis  : int = -1

func get_length_of_a_full_breath_round_in_seconds() -> int:
	if _memo_length_of_a_full_breath_round_in_seconds != -1:
		return _memo_length_of_a_full_breath_round_in_seconds
	
	var result : int = 0
	for i in breath_length:
		result += i

	return result

func get_length_of_a_full_breath_round_in_millis() -> int:
	if _memo_length_of_a_full_breath_round_in_millis != -1:
		return _memo_length_of_a_full_breath_round_in_millis

	return get_length_of_a_full_breath_round_in_seconds() * 1000

func reset_length_of_a_full_breath_round() -> void:
	_memo_length_of_a_full_breath_round_in_seconds = -1
	_memo_length_of_a_full_breath_round_in_millis  = -1
	get_length_of_a_full_breath_round_in_seconds()
	get_length_of_a_full_breath_round_in_millis()
	
func set_start_time_offset( offset_in_millis : int ) -> void:
	start_time_offset_in_millis = get_length_of_a_full_breath_round_in_millis() - offset_in_millis # a full breath round minus a few seconds will give us a good starting position when the scene loads.





func set_square_breathing() -> void:
	breath_length = [ 2, 2, 2, 2 ]
	reset_length_of_a_full_breath_round()
	set_start_time_offset( 2000 )
	line_height                = 250
	line_length_for_one_second = 300
	bend_multiplier            = 1.0

func set_deep_calm_breathing() -> void:
	breath_length = [4, 7, 6, 2] # Deep Calm from Breathly App
	reset_length_of_a_full_breath_round()
	set_start_time_offset( 2000 )
	line_height                = 400
	line_length_for_one_second = 200
	bend_multiplier            = 1.75

# othwer breat lengths to use when testing things.
#var breath_length : Array[int] = [0, 0, 4, 5]
#var breath_length : Array[int] = [2, 2, 2, 2]
#var breath_length : Array[int] = [2, 2, 3, 2]
#var breath_length : Array[int] = [1, 2, 3, 4]
#var breath_length : Array[int] = [1, 2, 3, 5]# fibonacci
#var breath_length : Array[int] = [4, 7, 6, 2] # Deep Calm from Breathly App

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_deep_calm_breathing()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
