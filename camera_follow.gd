extends Camera2D

# Camera follow settings
@export var follow_speed: float = 5.0
@export var look_ahead: float = 50.0

func _ready():
	# Make sure camera is enabled
	enabled = true
	# Set smoothing for smooth camera movement
	position_smoothing_enabled = true
	position_smoothing_speed = follow_speed

func _process(delta):
	# Get the player (parent node)
	var player = get_parent()
	if player:
		# Follow player horizontally only, with slight look-ahead
		var target_x = player.global_position.x + look_ahead
		# Keep current Y position (camera doesn't follow vertically)
		var target_y = global_position.y
		
		# Smoothly move camera horizontally
		global_position.x = lerp(global_position.x, target_x, follow_speed * delta)

