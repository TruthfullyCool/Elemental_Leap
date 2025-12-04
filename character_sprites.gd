extends Node

# Helper function to split sprite sheet into individual frames
static func split_sprite_sheet(texture: Texture2D, frame_count: int) -> Array:
	var frames = []
	if not texture:
		return frames
	
	# Get the image from the texture
	var image = texture.get_image()
	if not image:
		return frames
	
	var sheet_width = image.get_width()
	var sheet_height = image.get_height()
	var frame_width = sheet_width / frame_count
	
	# Extract each frame
	for i in range(frame_count):
		var x = i * frame_width
		var frame_image = image.get_region(Rect2i(x, 0, frame_width, sheet_height))
		var frame_texture = ImageTexture.create_from_image(frame_image)
		frames.append(frame_texture)
	
	return frames

static func create_water_spriteframes() -> SpriteFrames:
	var sprite_frames = SpriteFrames.new()
	
	# Idle animation (4 frames - sprite sheet)
	var idle_texture = load("res://Assets/1 Pink_Monster/Pink_Monster_Idle_4.png")
	if idle_texture:
		sprite_frames.add_animation("idle")
		sprite_frames.set_animation_speed("idle", 6.0)
		var idle_frames = split_sprite_sheet(idle_texture, 4)
		for frame in idle_frames:
			sprite_frames.add_frame("idle", frame)
	
	# Run animation (6 frames - sprite sheet)
	var run_texture = load("res://Assets/1 Pink_Monster/Pink_Monster_Run_6.png")
	if run_texture:
		sprite_frames.add_animation("run")
		sprite_frames.set_animation_speed("run", 10.0)
		var run_frames = split_sprite_sheet(run_texture, 6)
		for frame in run_frames:
			sprite_frames.add_frame("run", frame)
	
	# Jump animation (8 frames - sprite sheet)
	var jump_texture = load("res://Assets/1 Pink_Monster/Pink_Monster_Jump_8.png")
	if jump_texture:
		sprite_frames.add_animation("jump")
		sprite_frames.set_animation_speed("jump", 8.0)
		var jump_frames = split_sprite_sheet(jump_texture, 8)
		for frame in jump_frames:
			sprite_frames.add_frame("jump", frame)
	
	return sprite_frames

static func create_wind_spriteframes() -> SpriteFrames:
	var sprite_frames = SpriteFrames.new()
	
	# Idle animation (4 frames)
	var idle_texture = load("res://Assets/2 Owlet_Monster/Owlet_Monster_Idle_4.png")
	if idle_texture:
		sprite_frames.add_animation("idle")
		sprite_frames.set_animation_speed("idle", 6.0)
		var idle_frames = split_sprite_sheet(idle_texture, 4)
		for frame in idle_frames:
			sprite_frames.add_frame("idle", frame)
	
	# Run animation (6 frames)
	var run_texture = load("res://Assets/2 Owlet_Monster/Owlet_Monster_Run_6.png")
	if run_texture:
		sprite_frames.add_animation("run")
		sprite_frames.set_animation_speed("run", 10.0)
		var run_frames = split_sprite_sheet(run_texture, 6)
		for frame in run_frames:
			sprite_frames.add_frame("run", frame)
	
	# Jump animation (8 frames)
	var jump_texture = load("res://Assets/2 Owlet_Monster/Owlet_Monster_Jump_8.png")
	if jump_texture:
		sprite_frames.add_animation("jump")
		sprite_frames.set_animation_speed("jump", 8.0)
		var jump_frames = split_sprite_sheet(jump_texture, 8)
		for frame in jump_frames:
			sprite_frames.add_frame("jump", frame)
	
	return sprite_frames

static func create_fire_spriteframes() -> SpriteFrames:
	var sprite_frames = SpriteFrames.new()
	
	# Idle animation (4 frames)
	var idle_texture = load("res://Assets/3 Dude_Monster/Dude_Monster_Idle_4.png")
	if idle_texture:
		sprite_frames.add_animation("idle")
		sprite_frames.set_animation_speed("idle", 6.0)
		var idle_frames = split_sprite_sheet(idle_texture, 4)
		for frame in idle_frames:
			sprite_frames.add_frame("idle", frame)
	
	# Run animation (6 frames)
	var run_texture = load("res://Assets/3 Dude_Monster/Dude_Monster_Run_6.png")
	if run_texture:
		sprite_frames.add_animation("run")
		sprite_frames.set_animation_speed("run", 10.0)
		var run_frames = split_sprite_sheet(run_texture, 6)
		for frame in run_frames:
			sprite_frames.add_frame("run", frame)
	
	# Jump animation (8 frames)
	var jump_texture = load("res://Assets/3 Dude_Monster/Dude_Monster_Jump_8.png")
	if jump_texture:
		sprite_frames.add_animation("jump")
		sprite_frames.set_animation_speed("jump", 8.0)
		var jump_frames = split_sprite_sheet(jump_texture, 8)
		for frame in jump_frames:
			sprite_frames.add_frame("jump", frame)
	
	return sprite_frames

