extends Node2D

@onready var win_area = $WinArea
@onready var win_label = $WinLabel

func _ready():
	# Connect win signal - check if it's a GoalDoor or WinArea
	var goal_door = get_node_or_null("FinalPlatform/GoalDoor")
	if goal_door:
		print("Level2: Connected to GoalDoor")
		goal_door.player_won.connect(_on_player_won)
		# Lock the door initially (will unlock when key is collected)
		goal_door.has_key = false
		print("Level2: Door is LOCKED - need key to unlock")
	
	# WinArea is disabled - door is the only way to complete level
	if win_area:
		# Disconnect WinArea signal completely
		if win_area.has_signal("player_won") and win_area.player_won.is_connected(_on_player_won):
			win_area.player_won.disconnect(_on_player_won)
		print("Level2: WinArea is disabled and disconnected - door is the only way to complete level")
	
	if not goal_door and not win_area:
		print("Level2: WARNING - No win condition found!")
	
	# Hide win label initially
	if win_label:
		win_label.visible = false
	
	# Setup terrain and decorations
	_setup_terrain()
	_place_trees()
	_place_destructible_with_key()

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
		print("Setting up FinalPlatform at position: ", final_platform.position)
		# Keep ColorRect as fallback visual - don't remove it
		# Just ensure it's visible
		var color_rect = final_platform.get_node_or_null("ColorRect")
		if color_rect:
			color_rect.visible = true
			print("FinalPlatform ColorRect is visible")
		
		# Check for GoalDoor
		var goal_door = final_platform.get_node_or_null("GoalDoor")
		if goal_door:
			print("FinalPlatform has GoalDoor at position: ", goal_door.position)
		else:
			print("WARNING: FinalPlatform has no GoalDoor!")
		
		# Create tiled final platform (will be on top of ColorRect)
		var collision = final_platform.get_node_or_null("CollisionShape2D")
		if collision:
			var shape = collision.shape
			if shape:
				var x = final_platform.position.x - shape.size.x / 2.0
				var width = shape.size.x
				var y = final_platform.position.y
				print("Creating FinalPlatform tiles at x=", x, " width=", width, " y=", y)
				TerrainHelper.create_platform_sprite(final_platform, x, y, width)
				print("FinalPlatform setup complete")
		else:
			print("ERROR: FinalPlatform has no CollisionShape2D!")
		
		# Ensure platform is visible
		final_platform.visible = true
		print("FinalPlatform visibility: ", final_platform.visible)

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
	
	# Place decorations
	TerrainHelper.place_random_decorations(self, start_x, end_x, ground_y, player_spawn_x, 200.0, 400.0)

func _place_destructible_with_key():
	# Find a platform to place the destructible object on
	# Let's use Platform3 or Platform4 (around middle of level)
	var platform = get_node_or_null("Platform3")
	if not platform:
		platform = get_node_or_null("Platform4")
	if not platform:
		platform = get_node_or_null("Platform2")
	if not platform:
		print("ERROR: Could not find a platform for destructible object!")
		return
	
	var platform_collision = platform.get_node_or_null("CollisionShape2D")
	if not platform_collision:
		print("ERROR: Platform has no collision shape!")
		return
	
	var platform_shape = platform_collision.shape
	if not platform_shape:
		print("ERROR: Platform collision has no shape!")
		return
	
	# Position destructible object on the platform
	var platform_x = platform.position.x
	var platform_y = platform.position.y
	var platform_width = platform_shape.size.x
	
	# Place it on the left side of the platform
	var destructible_x = platform_x - platform_width / 2.0 + 50
	var destructible_y = platform_y - 48  # Position above platform
	
	# Load destructible object scene
	var destructible_scene = load("res://destructible_object.tscn")
	if not destructible_scene:
		print("ERROR: Could not load destructible_object.tscn")
		return
	
	# Create destructible object
	var destructible = destructible_scene.instantiate()
	destructible.position = Vector2(destructible_x, destructible_y)
	destructible.name = "DestructibleObject"
	add_child(destructible)
	
	# Set fall detection - breaks if it falls below the platform
	var fall_y = platform_y + 50  # Breaks if it falls 50 pixels below platform
	destructible.set_fall_detection_y(fall_y)
	print("Placed destructible object on platform at: ", destructible.position, " fall_y: ", fall_y)
	
	# Load key scene
	var key_scene = load("res://key.tscn")
	if not key_scene:
		print("ERROR: Could not load key.tscn")
		return
	
	# Create key (hidden, will appear when destructible breaks)
	var key = key_scene.instantiate()
	key.position = Vector2(destructible_x, destructible_y)  # Same position as destructible
	key.name = "Key"
	key.add_to_group("key")
	add_child(key)
	print("Placed key (hidden) at: ", key.position)
	
	# Connect key to destructible object
	destructible.set_key_reference(key)
	
	# Connect key to goal door
	var goal_door = get_node_or_null("FinalPlatform/GoalDoor")
	if goal_door:
		if key.has_signal("key_collected"):
			key.key_collected.connect(goal_door._on_key_collected)
			print("Level2: Connected key to goal door")
	
	print("Destructible object placed on platform. Push it with WIND ability to make it fall and break!")

func _on_player_won():
	print("Level2: _on_player_won called!")
	
	# Disable player movement
	var player = get_node_or_null("Player")
	if player:
		player.set_physics_process(false)
		print("Level2: Disabled player physics")
	
	# Check if this is the final level
	print("Level2: Current level = ", LevelManager.current_level, ", Total levels = ", LevelManager.total_levels)
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
		print("Level2: Loading next level in 1.5 seconds...")
		await get_tree().create_timer(1.5).timeout
		print("Level2: Calling LevelManager.load_next_level()")
		LevelManager.load_next_level()

func _input(event):
	# Allow restarting from level 1 by pressing R when win label is visible
	if event.is_action_pressed("ui_cancel") and win_label and win_label.visible:
		LevelManager.current_level = 1
		LevelManager.load_level(1)

