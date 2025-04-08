extends Node

var is_start_button_visible : bool = true
var is_playing : bool= false
var is_first_breath : bool = true
var are_fireworks_on : bool = false
var start_time_in_millis : int = 0
var total_time_in_millis : int = 0
var paused_time_in_millis : int = 0
var total_breath_rounds : int = 16

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
