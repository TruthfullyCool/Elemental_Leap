extends Node

# Helper functions for creating terrain and placing decorative elements

# Tile size in the tileset (typically 16x16 or 32x32)
const TILE_SIZE = 32

static func create_terrain_texture() -> Texture2D:
	return load("res://Assets/Terrain/Grassland/tilesetgrass.png")

static func create_grass_texture() -> Texture2D:
	return load("res://Assets/Terrain/Grassland/grass.png")

static func create_tree_texture() -> Texture2D:
	return load("res://Assets/Terrain/Grassland/tree.png")

static func create_bush_texture() -> Texture2D:
	return load("res://Assets/Terrain/Grassland/bush.png")

# Extract a specific tile from the tileset grid
# tile_x and tile_y are the grid coordinates (0,0 is top-left)
static func get_tile_from_tileset(tileset_texture: Texture2D, tile_x: int, tile_y: int) -> Texture2D:
	if not tileset_texture:
		return null
	
	var image = tileset_texture.get_image()
	if not image:
		return null
	
	# Calculate pixel coordinates
	var pixel_x = tile_x * TILE_SIZE
	var pixel_y = tile_y * TILE_SIZE
	
	# Check bounds
	if pixel_x + TILE_SIZE > image.get_width() or pixel_y + TILE_SIZE > image.get_height():
		# Return full texture as fallback
		return tileset_texture
	
	# Extract the tile region
	var tile_image = image.get_region(Rect2i(pixel_x, pixel_y, TILE_SIZE, TILE_SIZE))
	var tile_texture = ImageTexture.create_from_image(tile_image)
	return tile_texture

# Get tileset dimensions (how many tiles wide and tall)
static func get_tileset_dimensions(tileset_texture: Texture2D) -> Vector2i:
	if not tileset_texture:
		return Vector2i(0, 0)
	
	var image = tileset_texture.get_image()
	if not image:
		return Vector2i(0, 0)
	
	var tiles_x = image.get_width() / TILE_SIZE
	var tiles_y = image.get_height() / TILE_SIZE
	return Vector2i(tiles_x, tiles_y)

# Get a ground tile based on position (left, middle, right)
# Common tileset layout: first row usually has ground tiles
static func get_ground_tile(tileset_texture: Texture2D, position: String = "middle") -> Texture2D:
	if not tileset_texture:
		return tileset_texture
	
	var dims = get_tileset_dimensions(tileset_texture)
	if dims.x == 0 or dims.y == 0:
		return tileset_texture
	
	# Try to find appropriate tiles
	# Position: "left", "middle", "right"
	var tile_x = 0
	var tile_y = 0  # First row is usually ground tiles
	
	match position:
		"left":
			tile_x = 0  # Left edge tile
		"right":
			tile_x = min(2, dims.x - 1)  # Right edge tile
		"middle":
			tile_x = min(1, dims.x - 1)  # Middle tile
		_:
			tile_x = min(1, dims.x - 1)  # Default to middle
	
	return get_tile_from_tileset(tileset_texture, tile_x, tile_y)

# Create a tiled ground sprite using individual tiles from tileset
static func create_ground_sprite(parent: Node2D, start_x: float, end_x: float, y: float, height: float = 32.0) -> Node2D:
	var ground_container = Node2D.new()
	ground_container.name = "GroundVisual"
	parent.add_child(ground_container)
	
	var tileset = create_terrain_texture()
	if not tileset:
		return ground_container
	
	var tile_size = float(TILE_SIZE)
	var tile_width = end_x - start_x
	var num_tiles = int(ceil(tile_width / tile_size))
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	# Create tiled sprites using individual tiles from tileset
	for i in range(num_tiles):
		var sprite = Sprite2D.new()
		
		# Use different tiles for variety (left edge, middle, right edge)
		var tile_position = "middle"
		if i == 0:
			tile_position = "left"  # Left edge tile
		elif i == num_tiles - 1:
			tile_position = "right"  # Right edge tile
		else:
			tile_position = "middle"  # Middle tile
		
		# Get the specific tile from tileset
		var tile_texture = get_ground_tile(tileset, tile_position)
		if tile_texture:
			sprite.texture = tile_texture
		else:
			# Fallback to full tileset if extraction fails
			sprite.texture = tileset
		
		# Position relative to parent (which is at ground center)
		var world_x = start_x + i * tile_size + tile_size / 2
		sprite.position = Vector2(world_x - parent.position.x, y - parent.position.y)
		ground_container.add_child(sprite)
	
	return ground_container

# Create a platform sprite with terrain texture using individual tiles
static func create_platform_sprite(parent: Node2D, x: float, y: float, width: float) -> Node2D:
	var platform_container = Node2D.new()
	platform_container.name = "PlatformVisual"
	parent.add_child(platform_container)
	
	var tileset = create_terrain_texture()
	if not tileset:
		return platform_container
	
	var tile_size = float(TILE_SIZE)
	var num_tiles = int(ceil(width / tile_size))
	
	# Create tiled sprites for platform using individual tiles
	for i in range(num_tiles):
		var sprite = Sprite2D.new()
		
		# Use different tiles for platform edges and middle
		var tile_position = "middle"
		if i == 0:
			tile_position = "left"  # Left edge
		elif i == num_tiles - 1:
			tile_position = "right"  # Right edge
		else:
			tile_position = "middle"  # Middle
		
		# Get the specific tile from tileset
		var tile_texture = get_ground_tile(tileset, tile_position)
		if tile_texture:
			sprite.texture = tile_texture
		else:
			# Fallback to full tileset if extraction fails
			sprite.texture = tileset
		
		# Position relative to parent (which is at platform center)
		var world_x = x + i * tile_size + tile_size / 2
		sprite.position = Vector2(world_x - parent.position.x, y - parent.position.y)
		platform_container.add_child(sprite)
	
	return platform_container

# Randomly place trees in the level with collision
static func place_random_trees(parent: Node2D, start_x: float, end_x: float, ground_y: float, min_spacing: float = 200.0, max_spacing: float = 400.0, player_spawn_x: float = 0.0):
	var tree_texture = create_tree_texture()
	if not tree_texture:
		return
	
	var trees_container = Node2D.new()
	trees_container.name = "Trees"
	parent.add_child(trees_container)
	
	var current_x = start_x + 100.0  # Start a bit in from the edge
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	# Define safe zone around player spawn (no trees within this range)
	var spawn_safe_zone = 200.0  # 200 pixels on each side of spawn
	
	while current_x < end_x - 100.0:
		# Skip if too close to player spawn position
		var distance_from_spawn = abs(current_x - player_spawn_x)
		if distance_from_spawn < spawn_safe_zone:
			# Skip this position and move past the safe zone
			current_x = player_spawn_x + spawn_safe_zone
			continue
		
		# Reduced chance to place a tree (30% chance instead of 70%)
		if rng.randf() < 0.3:
			# Create a StaticBody2D for the tree with collision
			var tree_body = StaticBody2D.new()
			tree_body.position = Vector2(current_x, ground_y - tree_texture.get_height() / 2)
			
			# Add sprite
			var tree_sprite = Sprite2D.new()
			tree_sprite.texture = tree_texture
			tree_body.add_child(tree_sprite)
			
			# Add collision shape
			var collision_shape = CollisionShape2D.new()
			var rectangle_shape = RectangleShape2D.new()
			# Use tree texture dimensions for collision, or a reasonable size
			var tree_width = tree_texture.get_width()
			var tree_height = tree_texture.get_height()
			rectangle_shape.size = Vector2(tree_width * 0.8, tree_height * 0.8)  # Slightly smaller than sprite for better feel
			collision_shape.shape = rectangle_shape
			collision_shape.position = Vector2(0, -tree_height * 0.1)  # Adjust position slightly
			tree_body.add_child(collision_shape)
			
			trees_container.add_child(tree_body)
		
		# Move to next position with random spacing (increased spacing for fewer trees)
		current_x += rng.randf_range(min_spacing * 1.5, max_spacing * 1.5)

# Place bushes randomly
static func place_random_bushes(parent: Node2D, start_x: float, end_x: float, ground_y: float, min_spacing: float = 150.0, max_spacing: float = 300.0):
	var bush_texture = create_bush_texture()
	if not bush_texture:
		return
	
	var bushes_container = Node2D.new()
	bushes_container.name = "Bushes"
	parent.add_child(bushes_container)
	
	var current_x = start_x + 50.0
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	while current_x < end_x - 50.0:
		# Random chance to place a bush (50% chance)
		if rng.randf() < 0.5:
			var bush = Sprite2D.new()
			bush.texture = bush_texture
			bush.position = Vector2(current_x, ground_y - bush_texture.get_height() / 2)
			bushes_container.add_child(bush)
		
		# Move to next position with random spacing
		current_x += rng.randf_range(min_spacing, max_spacing)

