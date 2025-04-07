extends Node2D
@onready var firework: CPUParticles2D = $firework

var all_fireworks : Array[ CPUParticles2D ] = []
var random_spawn_amount = 20

const SCREEN_WIDTH = 1000.0
const SCREEN_HEIGHT = 1000.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Globals.are_fireworks_on:
		print("fffffffff firework")
		create_new_firework()
	
	# Delete old fireworks.
	#while ( all_fireworks.size() > 0 ):
		#if all_fireworks[ 0 ].emitting == false:
			#all_fireworks.remove_at( 0 )
		#else:
			#break

func create_new_firework() -> void:
	# Create a new firework explosion.
	var random_spawn = randi_range(0, 100)
	if random_spawn < random_spawn_amount:
		print("ffffffffff 111111")
		var new_firework : CPUParticles2D = firework.duplicate()
		new_firework.position = Vector2( randf_range(0.0, SCREEN_WIDTH), randf_range(0.0, SCREEN_HEIGHT) )
		var hue_variation : float = randf_range(0.0, 1.0)
		new_firework.hue_variation_min = hue_variation
		new_firework.hue_variation_max = hue_variation
		var firework_scale = randf_range(5.5, 15.5)
		new_firework.scale = Vector2( firework_scale, firework_scale )
		new_firework.lifetime = randf_range( 1.0, 3.0 )
		
		# Create a new color to offset the hue with.
		var random_color = Color( randf_range( 0.0, 1.0 ), randf_range( 0.0, 1.0 ), randf_range( 0.0, 1.0 ) )
		random_color *= 18.5 # add a glow effect
		var random_gradient : PackedColorArray = PackedColorArray()

		var new_color_ramp = new_firework.color_initial_ramp.duplicate()
		
		for i in range( 0, new_color_ramp.colors.size() ):
			random_gradient.append( new_color_ramp.colors[i] * random_color )
		new_color_ramp.colors = random_gradient
		new_firework.color_initial_ramp = new_color_ramp
		
		#var color_gradient : Gradient = Gradient.new()
		#color_gradient.offsets = PackedFloat32Array( [0.0, 1.0] )
		#for i in range( 0, new_firework.color_initial_ramp.colors.size() ):
			#random_gradient.append( new_firework.color_initial_ramp.colors[i] / random_color )
		#new_firework.color_initial_ramp.colors = random_gradient
		#new_firework.color




		#new_firework.color_initial_ramp.colors = new_firework.color_initial_ramp.colors * PackedColorArray( [ random_color, random_color ] )
		#new_firework.color_initial_ramp.offsets = PackedColorArray( [ random_color, random_color ] )
		#
		#color_gradient = color_gradient * GradientTexture1D.new( new_firework.color_initial_ramp)
		
		
		all_fireworks.append( new_firework )
		add_child( new_firework )
		print( new_firework )
		new_firework.emitting = true
