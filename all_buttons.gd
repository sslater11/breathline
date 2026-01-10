# © Copyright 2025, Simon Slater
# 
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 2 of the License.
# 
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.

extends Node2D
@onready var reset: Button = $reset
@onready var play_pause: Button = $play_pause
@onready var music_on_off: Button = $music_on_off
@onready var voice_on_off: Button = $voice_on_off
@onready var countdown: RichTextLabel = $countdown
@onready var vehicle_selection_menu: Node2D = $vehicle_selection_menu
@onready var vehicle_selection: Button = $vehicle_selection

const icon_car = preload("res://assets/icon_car.png")
const icon_helicopter = preload("res://assets/icon_helicopter.png")

var show_countup : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_play_pause_icon()
	update_music_on_off_icon()
	update_voice_on_off_icon()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_music_on_off_icon()


func _on_reset_button_pressed() -> void:
	if not Globals.is_start_button_visible:
		Globals.start_time_in_millis = Time.get_ticks_msec()
		Globals.has_celebration_sound_played = false
		if Globals.is_playing == false:
			Globals.is_playing = true
			Globals.is_first_breath = true
			update_play_pause_icon()
			
			SoundsScene.resume_background_music()


func _on_play_pause_pressed() -> void:
	if not Globals.is_start_button_visible:
		if Globals.is_playing:
			Globals.paused_time_in_millis = Time.get_ticks_msec()
			Globals.is_playing = false
			SoundsScene.pause_background_music()
		else:
			Globals.is_playing = true
			var current_time_in_millis : int = Time.get_ticks_msec()
			
			var time_diff : int = Time.get_ticks_msec() - Globals.paused_time_in_millis
			Globals.start_time_in_millis += time_diff
			
			SoundsScene.resume_background_music()
		update_play_pause_icon()

func update_play_pause_icon() -> void:
	if Globals.is_playing:
		play_pause.icon = preload("res://assets/play.png")
		play_pause.text = "Playing"
	else:
		play_pause.icon = preload("res://assets/pause.png")
		play_pause.text = "Paused"


func _on_music_on_off_pressed() -> void:
	SoundsScene.play_pause_toggle_background_music()
	update_music_on_off_icon()

func update_music_on_off_icon() -> void:
	if SoundsScene.is_music_paused():
		music_on_off.icon = preload("res://assets/music_off.png")
		music_on_off.text = "Music Off"
	else:
		music_on_off.icon = preload("res://assets/music_on.png")
		music_on_off.text = "Music On"


func _on_voice_on_off_pressed() -> void:
	SoundsScene.is_voice_enabled = not SoundsScene.is_voice_enabled
	update_voice_on_off_icon()

func update_voice_on_off_icon() -> void:
	if SoundsScene.is_voice_enabled:
		voice_on_off.icon = preload("res://assets/voice_on.png")
		voice_on_off.text = "Voice On"
	else:
		voice_on_off.icon = preload("res://assets/voice_off.png")
		voice_on_off.text = "Voice Off"


func _on_vehicle_selection_pressed() -> void:
	vehicle_selection_menu.visible = not vehicle_selection_menu.visible

func _on_helicopter_pressed() -> void:
	vehicle_selection.icon = icon_helicopter
	vehicle_selection_menu.visible = false
	SignalBus.helicopter_chosen.emit()
	
func _on_car_pressed() -> void:
	vehicle_selection.icon = icon_car
	vehicle_selection_menu.visible = false
	SignalBus.car_chosen.emit()
