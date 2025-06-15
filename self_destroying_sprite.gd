# © Copyright 2025, Simon Slater
# 
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 2 of the License.
# 
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.

extends AnimatedSprite2D
class_name SelfDestroyingSprite

var x_cut_off        : float = 0.0
var y_cut_off_top    : float = 0.0
var y_cut_off_bottom : float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var texture : Texture2D = sprite_frames.get_frame_texture("default", frame)
	
	# Delete sprite that's above the screen.
	y_cut_off_top = get_viewport().get_camera_2d().global_position.y
	y_cut_off_top -= get_viewport_rect().size.y
	y_cut_off_top -= texture.get_height() * scale.y
	
	# Delete sprite that's below the screen.
	y_cut_off_bottom = get_viewport().get_camera_2d().global_position.y
	y_cut_off_bottom += get_viewport_rect().size.y
	y_cut_off_bottom += texture.get_height() * scale.y

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var texture : Texture2D = sprite_frames.get_frame_texture("default", frame)

	# Delete sprite once it's off the left side of the screen
	x_cut_off = get_viewport().get_camera_2d().global_position.x
	x_cut_off -= (get_viewport_rect().size.x)
	x_cut_off -= texture.get_width() * scale.x

	if x_cut_off > global_position.x:
		self.queue_free()
	elif y_cut_off_top > global_position.y:
		queue_free()
	elif y_cut_off_bottom < global_position.y:
		queue_free()

func get_texture_of_current_frame() -> Texture2D:
	return sprite_frames.get_frame_texture("default", frame)
