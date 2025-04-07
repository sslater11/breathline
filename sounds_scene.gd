extends Node2D

@onready var kirks_song_1: AudioStreamPlayer = $kirks_song_1
@onready var kirks_song_2: AudioStreamPlayer = $kirks_song_2
@onready var kirks_song_3: AudioStreamPlayer = $kirks_song_3

@onready var breathe_in : AudioStreamPlayer  = $breathe_in
@onready var breathe_out : AudioStreamPlayer = $breathe_out
@onready var breathe_hold: AudioStreamPlayer = $breathe_hold

var all_background_music : Array[AudioStreamPlayer] = []

var is_background_music_allowed_to_play : bool = false
var is_background_music_playing : bool = false
var is_voice_enabled : bool = true
var current_track_index : int = 0
var current_track_volume : float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	all_background_music = [ kirks_song_1, kirks_song_2, kirks_song_3 ]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#if is_background_music_allowed_to_play:
		#start_background_music()
	pass

func play_breathe_in() -> void:
	if is_voice_enabled:
		breathe_in.play( 0.0 )
		await fade_out_and_in()
	
func play_breathe_out() -> void:
	if is_voice_enabled:
		breathe_out.play( 0.0 )
		await fade_out_and_in()

func play_breathe_hold() -> void:
	if is_voice_enabled:
		breathe_hold.play( 0.0 )
		await fade_out_and_in()

func fade_out_and_in():
	await fade_out_music( all_background_music, 0.001, -20.0, 0.1 )
	await fade_out_music( all_background_music, -20.0, 0.001, 0.1 )



func stop_background_music():
	is_background_music_allowed_to_play = false
	for track in all_background_music:
		track.stop()
	is_background_music_playing = false
	
func start_background_music():
	is_background_music_allowed_to_play = true
	is_background_music_playing = false
		
	if len( all_background_music ) > 0:
		current_track_index = randi() % len( all_background_music )
		#print( "track: " + str( current_track_index ) )
		##var track : AudioStreamPlayer = all_background_music[ track_index ]
		#print( "track: " + str( all_background_music ) )
		#print( "track: " + str( all_background_music[ current_track_index ] ) )
		all_background_music[ current_track_index ].volume_db = current_track_volume
		all_background_music[ current_track_index ].play( 0.0 )
		await all_background_music[ current_track_index ].finished
		is_background_music_playing = false
		
		
func pause_background_music():
	all_background_music[ current_track_index ].stream_paused = true

func resume_background_music():
	all_background_music[ current_track_index ].stream_paused = false

func play_pause_toggle_background_music():
	if all_background_music[ current_track_index ].stream_paused:
		all_background_music[ current_track_index ].stream_paused = false
	else:
		all_background_music[ current_track_index ].stream_paused = true

func is_music_paused() -> bool:
	return all_background_music[ current_track_index ].stream_paused

#func play_pokemon_cry( pokemon_name : String ):
	#if pokemon_name == Globals.SAMANTHA_POKEMON_NAME:
		#pokemon_cry_sarmander.play( 0.0 )
	#elif pokemon_name == Globals.KIRK_POKEMON_NAME:
		#pokemon_cry_kirkachu.play( 0.0 )
	#elif pokemon_name == Globals.MANATEE_POKEMON_NAME:
		#pokemon_cry_manatee.play( 0.0 )
	#elif pokemon_name == Globals.BUNNY_POKEMON_NAME:
		#pokemon_cry_big_red.play( 0.0 )
	#else:
		#print("unknown pokemon cry sound, can't play it. check sounds_scene code for this message.")
	#
#func play_pokemon_die( pokemon_gender : int ) -> void:
	#if pokemon_gender == Globals.GENDER_MALE:
		#randomize()
		#var choice : int = randi() % 2
		#if choice == 0:
			#die_kirk_1.play( 0.0 )
		#else:
			#die_kirk_2.play( 0.0 )
	#elif pokemon_gender == Globals.GENDER_BUNNY:
		#die_big_red.play( 0.0 )
	#elif pokemon_gender == Globals.GENDER_FEMALE:
		#die_sarmander.play( 0.0 )
		#
#
		#
#func play_pokemon_theme() -> void:
	#pokemon_theme.volume_db = -10.0
	#current_track_volume = -10.0
	#pokemon_theme.play(0.0)
#
#func play_manatee_song() -> void:
	#print("should be bloody playing")
	#await fade_out_music(all_background_music, 0.001, -60.0, 0.35)
	#is_manatee_song_playing = true
	#for track in all_background_music:
		#if track.playing:
			#track.stop()
			#is_background_music_playing = false
			#current_track_volume = 0
			##fade_out_music(all_background_music, -60.0, 0.001, 0.35)
	##play_background_music()
#func stop_manatee_song():
	#is_manatee_song_playing = false
	#is_background_music_playing = false
	#manatee_song.stop()
	#
#
#func fade_out_pokemon_theme_and_play_music() -> void:
	#await fade_out_music([pokemon_theme], -10.0, -60.0, 1.00)
	#pokemon_theme.stop()
	#current_track_volume = 0.0
	#is_background_music_allowed_to_play = true
	


		
		
		
#func fade_music_out_and_in( duration : float ):
	#print( "fading out" )
	#range(0.0,-60.0)
	#var silent_db : float = -60.0
	#var fade_out_speed : float = silent_db / duration
	#
	#var fade_out_speed : float = 
	#while current_track_volume > -60.0:
		#
		#var times_a_second : float = 0.01
		#
		#print("loop: " + str( fade_out_speed ) )
		#print("volume: " + str( current_track_volume ) )
		##current_track_volume -= 0.3
		#current_track_volume += fade_out_speed
		#all_background_music[ current_track_index ].volume_db = current_track_volume
		#await get_tree().create_timer(0.01).timeout
		##await get_tree().create_timer(0.00061250).timeout
		#await get_tree().create_timer( fade_out_speed ).timeout
		#
	#print( "faded out fully" )

	
func fade_out_music(all_tracks : Array[AudioStreamPlayer], start_volume: float, end_volume: float, duration: float):
	# Set the initial volume
	var steps = 100 * duration
	var step_duration = duration / steps
	var volume_delta = (end_volume - start_volume) / steps

	for i in range(steps):
		#print("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
		#print("index: " + str(current_track_index))
		#print("volume: " + str(current_track_volume))
		# Use a timer to wait before changing the volume
		await get_tree().create_timer( step_duration ).timeout
		var new_volume : float = current_track_volume + volume_delta
		#var new_volume : float = all_tracks[ current_track_index ].volume_db + volume_delta
		if new_volume > 0.0:
			current_track_volume = 0.0
		else:
			current_track_volume = new_volume
		for track in all_tracks:
			track.volume_db = current_track_volume


#func play_battle_start() -> void:
	#fade_out_music(all_background_music, 0.001, -60.0, 0.35)
	#battle_start.play( 0.0 )
	#battle_start.get_playback_position()
	#
	#await get_tree().create_timer( 2.0 ).timeout
	#
	#fade_out_music(all_background_music, -60.0, 0.001, 0.5)
#
#func is_battle_start_playing() -> bool:
	#return battle_start.playing
	#
#func play_run_away() -> void:
	#run_away.play( 0.0 )
#
#func play_battle_victory() -> void:
	#fade_out_music(all_background_music, 0.001, -60.0, 0.35)
	#battle_victory.play( 0.0 )
	#await get_tree().create_timer( 9.5 ).timeout
	#fade_out_music(all_background_music, -60.0, 0.001, 1.5)
#
#func play_low_hp() -> void:
	#low_hp.play( 0.0 )
#
#func play_pokeball_open() -> void:
	#pokeball_open.play( 0.0 )
