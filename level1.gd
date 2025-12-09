extends Node2D

@onready var win_area = $WinArea
@onready var win_label = $WinLabel

func _ready():
	# Connect win signal - check if it's a GoalDoor or WinArea
	var goal_door = get_node_or_null("FinalPlatform/GoalDoor")
	if goal_door:
		goal_door.player_won.connect(_on_player_won)
	elif win_area:
		win_area.player_won.connect(_on_player_won)
	
	# Hide win label initially
	if win_label:
		win_label.visible = false
	
	# Setup terrain and decorations
	_setup_terrain()
	_place_trees()

func _setup_terrain():
	# Get player spawn position for safe zone
	var player = get_node_or_null("Player")
	var player_spawn_x = -1.0
	if player:
		player_spawn_x = player.position.x
	
	# Setup ground
	var ground = get_node_or_null("Ground")
	if ground:
		# Remove ColorRect children immediately
		var to_remove = []
		for child in ground.get_children():
			if child.name == "ColorRect":
				to_remove.append(child)
		for rect in to_remove:
			ground.remove_child(rect)
			rect.queue_free()
		
		# Create tiled ground
		var ground_collision = ground.get_node_or_null("CollisionShape2D")
		if ground_collision:
			var shape = ground_collision.shape
			if shape:
				var start_x = ground.position.x - shape.size.x / 2.0
				var end_x = ground.position.x + shape.size.x / 2.0
				var y = ground.position.y
				print("Setting up ground: position=", ground.position, " size=", shape.size, " start_x=", start_x, " end_x=", end_x)
				TerrainHelper.create_ground_sprite(ground, start_x, end_x, y)
				print("Ground setup complete")
	
	# Setup platforms
	for i in range(1, 10):
		var platform = get_node_or_null("Platform" + str(i))
		if platform:
			# Remove ColorRect immediately
			var to_remove = []
			for child in platform.get_children():
				if child.name == "ColorRect":
					to_remove.append(child)
			for rect in to_remove:
				platform.remove_child(rect)
				rect.queue_free()
			
			# Create tiled platform
			var collision = platform.get_node_or_null("CollisionShape2D")
			if collision:
				var shape = collision.shape
				if shape:
					var x = platform.position.x - shape.size.x / 2.0
					var width = shape.size.x
					var y = platform.position.y
					TerrainHelper.create_platform_sprite(platform, x, y, width)
	
	# Setup final platform
	var final_platform = get_node_or_null("FinalPlatform")
	if final_platform:
		# Remove ColorRect immediately (but keep GoalDoor)
		var to_remove = []
		for child in final_platform.get_children():
			if child.name == "ColorRect":
				to_remove.append(child)
		for rect in to_remove:
			final_platform.remove_child(rect)
			rect.queue_free()
		
		# Create tiled final platform
		var collision = final_platform.get_node_or_null("CollisionShape2D")
		if collision:
			var shape = collision.shape
			if shape:
				var x = final_platform.position.x - shape.size.x / 2.0
				var width = shape.size.x
				var y = final_platform.position.y
				TerrainHelper.create_platform_sprite(final_platform, x, y, width)

func _place_trees():
	# Get ground bounds
	var ground = get_node_or_null("Ground")
	if not ground:
		return
	
	var ground_collision = ground.get_node_or_null("CollisionShape2D")
	if not ground_collision:
		return
	
	var shape = ground_collision.shape
	if not shape:
		return
	
	# Get player spawn position
	var player = get_node_or_null("Player")
	var player_spawn_x = -1.0
	if player:
		player_spawn_x = player.position.x
	
	var start_x = ground.position.x - shape.size.x / 2.0
	var end_x = ground.position.x + shape.size.x / 2.0
	var ground_y = ground.position.y
	
	# Place trees
	TerrainHelper.place_random_trees(self, start_x, end_x, ground_y, 300.0, 600.0, player_spawn_x)
	
	# Place bushes
	TerrainHelper.place_random_bushes(self, start_x, end_x, ground_y)

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
