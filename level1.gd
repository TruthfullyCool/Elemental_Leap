extends Node2D

@onready var win_area = $WinArea
@onready var win_label = $WinLabel
const GOAL_DOOR = preload("res://goal_door.tscn")

func _ready():
	# Connect win signal
	if win_area:
		win_area.player_won.connect(_on_player_won)
	
	# Hide win label initially
	if win_label:
		win_label.visible = false
	
	# Setup terrain visuals and trees
	_setup_terrain()
	_place_trees()
	_setup_goal()

func _setup_terrain():
	# Replace ColorRect visuals with terrain tileset
	var terrain_texture = TerrainHelper.create_terrain_texture()
	if not terrain_texture:
		return
	
	# Update ground visual
	var ground = get_node_or_null("Ground")
	if ground:
		var color_rect = ground.get_node_or_null("ColorRect")
		if color_rect:
			# Calculate ground width from ColorRect offsets
			var ground_width = color_rect.offset_right - color_rect.offset_left
			var ground_start = ground.position.x + color_rect.offset_left
			var ground_end = ground.position.x + color_rect.offset_right
			color_rect.queue_free()
			
			# Create tiled ground sprite
			TerrainHelper.create_ground_sprite(ground, ground_start, ground_end, ground.position.y, 32)
	
	# Update platform visuals - check for platforms 1-9
	for i in range(1, 10):
		var platform = get_node_or_null("Platform" + str(i))
		if platform:
			var color_rect = platform.get_node_or_null("ColorRect")
			if color_rect:
				# Calculate platform width from ColorRect offsets
				var platform_width = color_rect.offset_right - color_rect.offset_left
				var platform_x = platform.position.x + color_rect.offset_left
				color_rect.queue_free()
				
				# Create tiled platform sprite
				TerrainHelper.create_platform_sprite(platform, platform_x, platform.position.y, platform_width)
	
	# Update final platform
	var final_platform = get_node_or_null("FinalPlatform")
	if final_platform:
		var color_rect = final_platform.get_node_or_null("ColorRect")
		if color_rect:
			var platform_width = color_rect.offset_right - color_rect.offset_left
			var platform_x = final_platform.position.x + color_rect.offset_left
			color_rect.queue_free()
			
			TerrainHelper.create_platform_sprite(final_platform, platform_x, final_platform.position.y, platform_width)

func _place_trees():
	# Place trees randomly along the ground
	var ground = get_node_or_null("Ground")
	if ground:
		var color_rect = ground.get_node_or_null("ColorRect")
		var ground_start = ground.position.x
		var ground_end = ground.position.x
		
		# Calculate ground bounds from ColorRect if it still exists, otherwise use position
		if color_rect:
			ground_start = ground.position.x + color_rect.offset_left
			ground_end = ground.position.x + color_rect.offset_right
		else:
			# Fallback: estimate from ground position (for level 1: 1750 width)
			ground_start = ground.position.x - 2000
			ground_end = ground.position.x + 2000
		
		# Get player spawn position to avoid placing trees near it
		var player = get_node_or_null("Player")
		var player_spawn_x = 100.0  # Default spawn position
		if player:
			player_spawn_x = player.position.x
		
		# Place trees with increased spacing for fewer trees, avoiding spawn area
		TerrainHelper.place_random_trees(self, ground_start, ground_end, ground.position.y, 300.0, 600.0, player_spawn_x)
		TerrainHelper.place_random_bushes(self, ground_start, ground_end, ground.position.y, 100.0, 250.0)

func _setup_goal():
	# Place goal door on the final platform
	var final_platform = get_node_or_null("FinalPlatform")
	if final_platform and GOAL_DOOR:
		# Create goal door
		var goal_door = GOAL_DOOR.instantiate()
		# Position door on top of the final platform, centered
		goal_door.position = Vector2(final_platform.position.x, final_platform.position.y - 45)
		add_child(goal_door)
		
		# Connect goal door signal
		goal_door.player_reached_goal.connect(_on_player_won)
		
		# Hide or disable the old win area since door handles it now
		if win_area:
			win_area.queue_free()

func _on_player_won():
	# Disable player movement
	var player = get_node_or_null("Player")
	if player:
		player.set_physics_process(false)
	
	# Check if this is the final level
	if LevelManager.current_level >= LevelManager.total_levels:
		# Final level completed!
		if win_label:
			win_label.visible = true
			win_label.text = "All Levels Complete!\nCongratulations!\nPress R to Restart"
			var font = win_label.get_theme_font("font")
			if font:
				win_label.add_theme_font_size_override("font_size", 48)
		
		# Allow restart with R key
		set_process_input(true)
	else:
		# Show level complete message
		if win_label:
			win_label.visible = true
			win_label.text = "Level Complete!\nLoading Next Level..."
			# Make text larger and more visible
			var font = win_label.get_theme_font("font")
			if font:
				win_label.add_theme_font_size_override("font_size", 48)
		
		# Load next level after a short delay
		await get_tree().create_timer(1.5).timeout
		LevelManager.load_next_level()

func _input(event):
	if event.is_action_pressed("ui_select") or (event is InputEventKey and event.keycode == KEY_R):
		if win_label and win_label.visible:
			LevelManager.load_level(1)  # Restart from level 1

