extends Node

const TILE_SIZE = 32

static func create_terrain_texture() -> Texture2D:
	var texture = load("res://Assets/Terrain/Grassland/tilesetgrass.png")
	if not texture:
		print("ERROR: Could not load tileset texture from res://Assets/Terrain/Grassland/tilesetgrass.png")
	else:
		print("Successfully loaded tileset texture")
	return texture

static func create_grass_texture() -> Texture2D:
	return load("res://Assets/Terrain/Grassland/grass.png")

static func create_tree_texture() -> Texture2D:
	return load("res://Assets/Terrain/Grassland/tree.png")

static func create_bush_texture() -> Texture2D:
	return load("res://Assets/Terrain/Grassland/bush.png")

# Get a specific tile from the tileset based on grid coordinates
static func get_tile_from_tileset(tileset_texture: Texture2D, tile_x: int, tile_y: int) -> ImageTexture:
	if not tileset_texture:
		print("get_tile_from_tileset: No tileset texture provided")
		return null
	
	var image = tileset_texture.get_image()
	if not image:
		print("get_tile_from_tileset: Could not get image from texture")
		return null
	
	var tileset_width = image.get_width()
	var tileset_height = image.get_height()
	
	print("Tileset dimensions: ", tileset_width, "x", tileset_height, " (tiles: ", tileset_width/TILE_SIZE, "x", tileset_height/TILE_SIZE, ")")
	
	# Calculate tile position
	var x = tile_x * TILE_SIZE
	var y = tile_y * TILE_SIZE
	
	# Bounds check
	if x + TILE_SIZE > tileset_width or y + TILE_SIZE > tileset_height:
		print("get_tile_from_tileset: Tile position out of bounds: tile_x=", tile_x, " tile_y=", tile_y, " calculated x=", x, " y=", y)
		return null
	
	# Extract the tile
	var tile_image = image.get_region(Rect2i(x, y, TILE_SIZE, TILE_SIZE))
	if not tile_image:
		print("get_tile_from_tileset: Could not extract region")
		return null
	
	var tile_texture = ImageTexture.create_from_image(tile_image)
	if not tile_texture:
		print("get_tile_from_tileset: Could not create texture from image")
		return null
	
	print("Successfully extracted tile at (", tile_x, ",", tile_y, ")")
	return tile_texture

# Get tileset dimensions in tiles
static func get_tileset_dimensions(tileset_texture: Texture2D) -> Vector2i:
	if not tileset_texture:
		return Vector2i(0, 0)
	
	var image = tileset_texture.get_image()
	if not image:
		return Vector2i(0, 0)
	
	return Vector2i(image.get_width() / TILE_SIZE, image.get_height() / TILE_SIZE)

# Get a ground tile (left, middle, or right)
static func get_ground_tile(tileset_texture: Texture2D, position: String = "middle") -> ImageTexture:
	# First row (y=0) typically has ground tiles
	# Try different tile positions - some tilesets have different layouts
	var tile_x = 0
	var tile_y = 0
	
	match position:
		"left":
			tile_x = 0
			tile_y = 0
		"middle":
			tile_x = 1
			tile_y = 0
		"right":
			tile_x = 2
			tile_y = 0
		_:
			tile_x = 1
			tile_y = 0
	
	var tile = get_tile_from_tileset(tileset_texture, tile_x, tile_y)
	if not tile:
		# Fallback: try row 1 if row 0 doesn't work
		tile = get_tile_from_tileset(tileset_texture, tile_x, 1)
	
	return tile

# Create ground sprite using individual tiles
static func create_ground_sprite(parent: Node2D, start_x: float, end_x: float, y: float, height: float = 32.0):
	print("create_ground_sprite called: parent=", parent.name, " start_x=", start_x, " end_x=", end_x, " y=", y)
	
	var tileset_texture = create_terrain_texture()
	if not tileset_texture:
		print("TerrainHelper: Could not load tileset texture")
		return
	
	# Check if container already exists and remove it
	var existing_container = parent.get_node_or_null("GroundTiles")
	if existing_container:
		existing_container.queue_free()
	
	var ground_container = Node2D.new()
	ground_container.name = "GroundTiles"
	ground_container.visible = true
	ground_container.z_index = 0
	parent.add_child(ground_container)
	
	# Position container relative to parent
	ground_container.position = Vector2.ZERO
	
	# Make sure parent is also visible
	if parent.has_method("set_visible"):
		parent.visible = true
	
	var current_x = start_x
	var tile_count = 0
	var successful_tiles = 0
	
	while current_x < end_x:
		var tile_texture: ImageTexture
		
		# Determine which tile to use (left, middle, right)
		if tile_count == 0:
			tile_texture = get_ground_tile(tileset_texture, "left")
		elif current_x + TILE_SIZE >= end_x:
			tile_texture = get_ground_tile(tileset_texture, "right")
		else:
			tile_texture = get_ground_tile(tileset_texture, "middle")
		
		if tile_texture:
			var sprite = Sprite2D.new()
			sprite.texture = tile_texture
			sprite.visible = true
			# Position relative to parent (Ground node)
			var relative_x = current_x - parent.position.x
			var relative_y = y - parent.position.y
			sprite.position = Vector2(relative_x + TILE_SIZE / 2.0, relative_y - TILE_SIZE / 2.0)
			ground_container.add_child(sprite)
			successful_tiles += 1
		else:
			print("TerrainHelper: Could not get tile texture at x=", current_x, " tile_count=", tile_count)
		
		current_x += TILE_SIZE
		tile_count += 1
	
	print("TerrainHelper: Created ", successful_tiles, "/", tile_count, " ground tiles from ", start_x, " to ", end_x)

# Create platform sprite using individual tiles
static func create_platform_sprite(parent: Node2D, x: float, y: float, width: float):
	var tileset_texture = create_terrain_texture()
	if not tileset_texture:
		print("TerrainHelper: Could not load tileset texture for platform")
		return
	
	# Check if container already exists and remove it
	var existing_container = parent.get_node_or_null("PlatformTiles")
	if existing_container:
		existing_container.queue_free()
	
	var platform_container = Node2D.new()
	platform_container.name = "PlatformTiles"
	platform_container.visible = true
	platform_container.z_index = 0
	parent.add_child(platform_container)
	
	# Position container relative to parent
	platform_container.position = Vector2.ZERO
	
	# Make sure parent is also visible
	if parent.has_method("set_visible"):
		parent.visible = true
	
	var current_x = x
	var tile_count = 0
	var end_x = x + width
	
	while current_x < end_x:
		var tile_texture: ImageTexture
		
		# Determine which tile to use (left, middle, right)
		if tile_count == 0:
			tile_texture = get_ground_tile(tileset_texture, "left")
		elif current_x + TILE_SIZE >= end_x:
			tile_texture = get_ground_tile(tileset_texture, "right")
		else:
			tile_texture = get_ground_tile(tileset_texture, "middle")
		
		if tile_texture:
			var sprite = Sprite2D.new()
			sprite.texture = tile_texture
			sprite.visible = true
			# Position relative to parent (Platform node)
			var relative_x = current_x - parent.position.x
			var relative_y = y - parent.position.y
			sprite.position = Vector2(relative_x + TILE_SIZE / 2.0, relative_y - TILE_SIZE / 2.0)
			platform_container.add_child(sprite)
		else:
			print("TerrainHelper: Could not get tile texture for platform at x=", current_x, " position=", tile_count)
		
		current_x += TILE_SIZE
		tile_count += 1

# Place random trees
static func place_random_trees(parent: Node2D, start_x: float, end_x: float, ground_y: float, min_spacing: float = 300.0, max_spacing: float = 600.0, player_spawn_x: float = -1.0):
	var tree_texture = create_tree_texture()
	if not tree_texture:
		return
	
	var current_x = start_x
	var tree_count = 0
	
	while current_x < end_x:
		# Check if we're in the player spawn safe zone
		if player_spawn_x >= 0:
			var distance_from_spawn = abs(current_x - player_spawn_x)
			if distance_from_spawn < 200.0:  # 200 pixel safe zone
				current_x += max_spacing
				continue
		
		# Random chance to spawn tree (30% chance)
		if randf() < 0.3:
			var tree = StaticBody2D.new()
			tree.name = "Tree_" + str(tree_count)
			# Position tree on top of ground
			# ground_y is the center Y of the ground, so position tree base at ground_y - 16 (half of 32px ground height)
			var sprite_size = tree_texture.get_size()
			tree.position = Vector2(current_x, ground_y - 16)  # 16 is half of ground height (32/2)
			parent.add_child(tree)
			
			# Add sprite - position it so the bottom aligns with the ground
			var sprite = Sprite2D.new()
			sprite.texture = tree_texture
			# Sprite's origin is at center, so offset it up by half its height to align bottom with ground
			sprite.position = Vector2(0, sprite_size.y / 2.0)
			tree.add_child(sprite)
			
			# Add collision (80% of sprite size)
			var collision = CollisionShape2D.new()
			var shape = RectangleShape2D.new()
			shape.size = sprite_size * 0.8
			collision.shape = shape
			# Position collision at bottom of tree sprite
			collision.position = Vector2(0, sprite_size.y * 0.4)
			tree.add_child(collision)
			
			tree_count += 1
		
		# Move to next potential spawn location
		current_x += randf_range(min_spacing, max_spacing)

# Place random bushes
static func place_random_bushes(parent: Node2D, start_x: float, end_x: float, ground_y: float, min_spacing: float = 100.0, max_spacing: float = 250.0):
	var bush_texture = create_bush_texture()
	if not bush_texture:
		return
	
	var current_x = start_x
	
	while current_x < end_x:
		if randf() < 0.4:  # 40% chance
			var bush = Sprite2D.new()
			bush.texture = bush_texture
			bush.position = Vector2(current_x, ground_y - bush_texture.get_size().y / 2.0)
			parent.add_child(bush)
		
		current_x += randf_range(min_spacing, max_spacing)

