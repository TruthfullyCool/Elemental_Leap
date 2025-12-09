extends Node

# Helper script to create SpriteFrames for ability effects
static func create_water_effect_frames() -> SpriteFrames:
	var sprite_frames = SpriteFrames.new()
	var effect_texture = load("res://Assets/1 Pink_Monster/Water_Effects.png")
	
	if not effect_texture:
		return sprite_frames
	
	sprite_frames.add_animation("default")
	sprite_frames.set_animation_loop("default", true)
	sprite_frames.set_animation_speed("default", 12.0)
	
	var image = effect_texture.get_image()
	if not image:
		return sprite_frames
	
	var sheet_width = image.get_width()
	var sheet_height = image.get_height()
	
	# Frame size: narrow width to show one asset, keep height
	var frame_width = 32  # Narrow width to show only one asset
	var frame_height = 24  # Keep height
	
	# Extract from specific pixel coordinates - animate through 3 frames
	var start_x = 450
	var y = 220 - 66 + (2 * 24) + 24  # Dropped by 3 rows total (frame_height = 24)
	
	print("Water effect: Extracting 3 frames starting from position (", start_x, ", ", y, ") with size ", frame_width, "x", frame_height)
	
	# Extract 3 frames horizontally - each frame is one asset
	# The spacing between assets might be different, so we'll extract at intervals
	for i in range(3):
		# Each asset might be spaced by the original frame width (100 pixels apart)
		var x = start_x + (i * 100)  # Space them 100 pixels apart
		
		if x + frame_width <= sheet_width and y + frame_height <= sheet_height:
			var frame_image = image.get_region(Rect2i(x, y, frame_width, frame_height))
			var frame_texture = ImageTexture.create_from_image(frame_image)
			if frame_texture:
				sprite_frames.add_frame("default", frame_texture)
				print("Successfully extracted frame ", i + 1, " at position (", x, ", ", y, ")")
		else:
			print("Warning: Frame ", i + 1, " out of bounds! Sheet size: ", sheet_width, "x", sheet_height, " Requested: (", x, ", ", y, ")")
	
	print("Water effect: Created ", sprite_frames.get_frame_count("default"), " animated frames")
	
	return sprite_frames

static func create_wind_effect_frames() -> SpriteFrames:
	var sprite_frames = SpriteFrames.new()
	var effect_texture = load("res://Assets/2 Owlet_Monster/Wind_Effects.png")
	
	if not effect_texture:
		return sprite_frames
	
	sprite_frames.add_animation("default")
	sprite_frames.set_animation_loop("default", true)
	sprite_frames.set_animation_speed("default", 12.0)
	
	var image = effect_texture.get_image()
	if not image:
		return sprite_frames
	
	var sheet_width = image.get_width()
	var sheet_height = image.get_height()
	
	# Frame size: narrow width to show one asset, keep height
	var frame_width = 32  # Narrow width to show only one asset
	var frame_height = 24  # Keep height
	
	# Extract from specific pixel coordinates - animate through 3 frames
	# Using similar coordinates as water (adjust if needed)
	var start_x = 450
	var y = 220 - 66 + (2 * 24) + 24  # Same row position as water
	
	print("Wind effect: Extracting 3 frames starting from position (", start_x, ", ", y, ") with size ", frame_width, "x", frame_height)
	
	# Extract 3 frames horizontally - each frame is one asset
	for i in range(3):
		var x = start_x + (i * 100)  # Space them 100 pixels apart
		
		if x + frame_width <= sheet_width and y + frame_height <= sheet_height:
			var frame_image = image.get_region(Rect2i(x, y, frame_width, frame_height))
			var frame_texture = ImageTexture.create_from_image(frame_image)
			if frame_texture:
				sprite_frames.add_frame("default", frame_texture)
				print("Successfully extracted wind frame ", i + 1, " at position (", x, ", ", y, ")")
		else:
			print("Warning: Wind frame ", i + 1, " out of bounds! Sheet size: ", sheet_width, "x", sheet_height, " Requested: (", x, ", ", y, ")")
	
	print("Wind effect: Created ", sprite_frames.get_frame_count("default"), " animated frames")
	return sprite_frames

static func create_fire_effect_frames() -> SpriteFrames:
	var sprite_frames = SpriteFrames.new()
	var effect_texture = load("res://Assets/3 Dude_Monster/Fire_Effects.png")
	
	if not effect_texture:
		return sprite_frames
	
	sprite_frames.add_animation("default")
	sprite_frames.set_animation_loop("default", true)
	sprite_frames.set_animation_speed("default", 12.0)
	
	var image = effect_texture.get_image()
	if not image:
		return sprite_frames
	
	var sheet_width = image.get_width()
	var sheet_height = image.get_height()
	
	# Frame size: narrow width to show one asset, keep height
	var frame_width = 32  # Narrow width to show only one asset
	var frame_height = 24  # Keep height
	
	# Extract from specific pixel coordinates - animate through 3 frames
	# Using similar coordinates as water (adjust if needed)
	var start_x = 450
	var y = 220 - 66 + (2 * 24) + 24  # Same row position as water
	
	print("Fire effect: Extracting 3 frames starting from position (", start_x, ", ", y, ") with size ", frame_width, "x", frame_height)
	
	# Extract 3 frames horizontally - each frame is one asset
	for i in range(3):
		var x = start_x + (i * 100)  # Space them 100 pixels apart
		
		if x + frame_width <= sheet_width and y + frame_height <= sheet_height:
			var frame_image = image.get_region(Rect2i(x, y, frame_width, frame_height))
			var frame_texture = ImageTexture.create_from_image(frame_image)
			if frame_texture:
				sprite_frames.add_frame("default", frame_texture)
				print("Successfully extracted fire frame ", i + 1, " at position (", x, ", ", y, ")")
		else:
			print("Warning: Fire frame ", i + 1, " out of bounds! Sheet size: ", sheet_width, "x", sheet_height, " Requested: (", x, ", ", y, ")")
	
	print("Fire effect: Created ", sprite_frames.get_frame_count("default"), " animated frames")
	return sprite_frames

