extends StaticBody2D

signal destroyed

var is_burning = false
var key_reference = null  # Reference to the key that will appear when this is destroyed

func set_key_reference(key_node):
	key_reference = key_node
	print("FlammableObject: Key reference set")

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D

func _ready():
	print("FlammableObject: _ready() called at position: ", global_position)
	# Add to a group so we can find it easily for win condition checks
	add_to_group("flammable")
	# Ensure this object is visible
	visible = true
	
	# Load and set up sprite from sprite sheet
	_setup_sprite()
	
	# Set up collision detection for projectiles using Area2D
	var area = Area2D.new()
	area.name = "HitArea"
	area.monitoring = true
	area.monitorable = false
	add_child(area)
	
	var area_collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	var sprite_size = Vector2(64, 64)
	if sprite and sprite.texture:
		sprite_size = sprite.texture.get_size()
	shape.size = sprite_size * 1.2  # Slightly larger than object for easier hit detection
	area_collision.shape = shape
	area.add_child(area_collision)
	
	area.body_entered.connect(_on_projectile_hit)
	print("FlammableObject: Setup complete, sprite visible: ", sprite.visible if sprite else "NO SPRITE")

func _setup_sprite():
	# Load the flammable objects sprite sheet
	var sprite_sheet = load("res://Assets/Obstacles/Flameable Objects Sprite Sheet.png")
	if not sprite_sheet:
		print("ERROR: Could not load flammable object sprite sheet!")
		# Create a fallback visual
		if sprite:
			var fallback = ColorRect.new()
			fallback.color = Color(0.8, 0.4, 0.2, 1)
			fallback.size = Vector2(96, 96)
			add_child(fallback)
		return
	
	var image = sprite_sheet.get_image()
	if not image:
		print("ERROR: Could not get image from sprite sheet!")
		return
	
	print("FlammableObject: Loaded sprite sheet, size: ", image.get_size())
	
	# Extract first object from sprite sheet (top-left, 64x64) and scale it up
	var frame_size = 64
	var frame_image = image.get_region(Rect2i(0, 0, frame_size, frame_size))
	
	# Scale up the image to make it bigger (96x96)
	frame_image.resize(96, 96, Image.INTERPOLATE_LANCZOS)
	
	var frame_texture = ImageTexture.create_from_image(frame_image)
	
	if sprite:
		sprite.texture = frame_texture
		sprite.visible = true
		sprite.z_index = 2  # Make sure it's visible above platform
		print("FlammableObject: Sprite set, texture size: ", frame_texture.get_size())
		# Update collision size to match scaled sprite (96x96)
		if collision and collision.shape:
			collision.shape.size = Vector2(96, 96)
			print("FlammableObject: Collision size set to: ", collision.shape.size)
	else:
		print("ERROR: FlammableObject has no Sprite2D node!")

func _on_projectile_hit(body):
	print("FlammableObject: Projectile hit - ", body.name)
	
	# Check if it's a fire projectile - ONLY fire can destroy this
	var is_fire_projectile = false
	
	# Check by name first
	if "Fire" in body.name:
		is_fire_projectile = true
		print("FlammableObject: Fire projectile detected by name")
	# Check by effect_type property (if it's a CharacterBody2D projectile)
	elif body is CharacterBody2D:
		# Try to access effect_type property safely
		var effect_type = body.get("effect_type")
		if effect_type != null and effect_type == "fire":
			is_fire_projectile = true
			print("FlammableObject: Fire projectile detected by effect_type")
	
	if is_fire_projectile:
		if not is_burning:
			print("FlammableObject: Destroyed by fire ability!")
			burn_down()
			# Destroy the projectile
			body.queue_free()
		else:
			print("FlammableObject: Already burning, ignoring hit")
			body.queue_free()
	else:
		# Other projectiles (water, wind) cannot destroy this object
		print("FlammableObject: Non-fire projectile hit (", body.name, "). Only fire can destroy this object!")
		body.queue_free()

func burn_down():
	is_burning = true
	print("Flammable object is burning down!")
	
	# Show the key if it exists
	if key_reference and is_instance_valid(key_reference):
		key_reference.show_key()
		print("Key revealed after destroying flammable object!")
	
	# Disable collision so player can pass through
	collision.set_deferred("disabled", true)
	
	# Play burn animation or effect
	# Fade out and remove
	var tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 0.5)
	tween.tween_callback(queue_free)
	
	# Emit signal that object is destroyed
	destroyed.emit()
