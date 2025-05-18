extends RichTextLabel

var show_countup : bool = false

func _process(delta: float) -> void:
	if Globals.is_playing:
		var font_size : int = 150
		var countdown_str : String = "0:00"
		var countup_str : String = ""
		
		# update the countdown timer.
		var current_time_in_millis : int = Time.get_ticks_msec() - Globals.start_time_in_millis
		var time_left : int = Globals.total_time_in_millis - current_time_in_millis
		if time_left > 0:
			var countdown_minutes : int = abs( time_left / 1000 / 60 )
			var countdown_seconds : int = abs( (time_left / 1000) - (countdown_minutes * 60) )
			var countdown_seconds_str : String = ""
			if countdown_seconds < 10:
				countdown_seconds_str = "0" + str(countdown_seconds)
			else:
				countdown_seconds_str = str(countdown_seconds)
			countdown_str = str( countdown_minutes ) + ":" + countdown_seconds_str

		if show_countup:
			font_size = 60
			var countup_minutes : int = abs( current_time_in_millis / 1000 / 60 )
			var countup_seconds : int = abs( (current_time_in_millis / 1000) - (countup_minutes * 60) )
			var countup_seconds_str : String = ""
			countup_str = "\n"
			if countup_seconds < 10:
				countup_seconds_str += "0" + str(countup_seconds)
			else:
				countup_seconds_str += str(countup_seconds)
			countup_str += str( countup_minutes ) + ":" + countup_seconds_str

		#self.text = "[font_size=150][color=black]" + str(countdown_minutes) + ":" + countdown_seconds_str + "/" + str(countup_minutes)+":"+str(countup_seconds) + "[/color][/font_size]"
		self.text = "[center][font_size=" + str( font_size ) + "][color=black]" + countdown_str + countup_str + "[/color][/font_size][/center]"


func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = get_viewport().get_mouse_position() 
		mouse_pos = get_global_mouse_position()
		
		if get_global_rect().has_point(mouse_pos):
			show_countup = !show_countup
