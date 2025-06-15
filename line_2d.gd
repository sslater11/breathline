# © Copyright 2025, Simon Slater
# 
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 2 of the License.
# 
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.

extends Line2D

@onready var breathline: Path2D = $"../breathline"

var all_path_follows : Array[PathFollow2D] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#
	#var path_follow_1 = PathFollow2D.new()
	#path_follow_1.progress_ratio = 0.1
	#all_path_follows.append( path_follow_1 )
	#
	#var path_follow_2 = PathFollow2D.new()
	#path_follow_2.progress_ratio = 0.91
	#all_path_follows.append( path_follow_2 )
	#
	#add_point( Vector2(0.0, 0.0) )
	#add_point( Vector2(123.0104, 155.1722) )
	#add_point( Vector2(123.0104, 155.1722) )
	#add_point( Vector2 (845.5035, 229.5032) )
	clear_points()
	for i in breathline.curve.get_baked_points():
		add_point( i )


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	clear_points()
	for i in breathline.curve.get_baked_points():
		add_point( i )


	#all_path_follows[0].progress_ratio = 0.1
	#all_path_follows[1].progress_ratio = 0.6
	#for path_follow in all_path_follows:
		#print("global_ppsitiiion: " + str(path_follow.global_position) )
		#add_point( path_follow.global_position )
