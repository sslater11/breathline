extends Button
@onready var start_button: Node2D = $".."


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pressed() -> void:
	# Hint for me on how to use buttons:
	# quick 10 second video for buttons - https://www.youtube.com/watch?v=mlS1p7-9u6k
	# Click "Node" tab at the top of properties, to see all the signals this node has.
	Globals.total_breath_rounds = 1
	print(Globals.total_breath_rounds)
	Globals.is_start_button_visible = false
	start_button.visible = false
	self.visible = false

	Globals.start_time_in_millis = Time.get_ticks_msec()
	Globals.is_playing = true
	Globals.is_first_breath = true
	get_tree().change_scene_to_file("res://node_2d.tscn")
