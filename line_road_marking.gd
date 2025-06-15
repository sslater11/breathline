# © Copyright 2025, Simon Slater
# 
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 2 of the License.
# 
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.

extends Line2D
@onready var breathline: Path2D = $"../breathline"

func draw_breathline() -> void:
	clear_points()
	
	for i in range( len( breathline.curve.get_baked_points() ) ):
		var y_offset : float = 50
		var position : Vector2 = Vector2( breathline.curve.get_baked_points()[i].x, breathline.curve.get_baked_points()[i].y + y_offset )
		add_point( position )
