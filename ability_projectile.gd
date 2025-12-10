extends CharacterBody2D

var speed = 500.0
var direction = Vector2.RIGHT
var lifetime = 2.0
var damage = 0  # Can be used for future damage system
var effect_type = "water"  # "water", "wind", "fire"

@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	# Set velocity based on direction
	velocity = direction * speed
	
	# Setup animated sprite based on effect type - do this first
	_setup_effect_sprite()
	
	# Flip sprite if going left
	if animated_sprite and direction.x < 0:
		animated_sprite.flip_h = true
	
	# Auto-destroy after lifetime
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _setup_effect_sprite():
	if not animated_sprite:
		return
	
	var sprite_frames = null
	match effect_type:
		"water":
			sprite_frames = AbilityEffects.create_water_effect_frames()
		"wind":
			sprite_frames = AbilityEffects.create_wind_effect_frames()
		"fire":
			sprite_frames = AbilityEffects.create_fire_effect_frames()
	
	if sprite_frames and sprite_frames.has_animation("default"):
		# Check if we actually have frames
		var frame_count = sprite_frames.get_frame_count("default")
		if frame_count > 0:
			animated_sprite.sprite_frames = sprite_frames
			animated_sprite.play("default")
			animated_sprite.set_frame(0)  # Start at first frame
		else:
			print("Warning: No frames extracted for ", effect_type, " effect")

func _physics_process(delta):
	# Move the projectile
	var old_position = position
	position += velocity * delta
	
	# Check for collisions with destructible objects (wind only)
	if effect_type == "wind":
		# Use space_state to check for collisions at current position
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsPointQueryParameters2D.new()
		query.position = position
		query.collision_mask = 1  # Check layer 1
		var results = space_state.intersect_point(query, 1)
		
		for result in results:
			var collider = result.collider
			# Check if it's a destructible object
			if collider and collider.is_in_group("destructible"):
				if collider.has_method("apply_wind_force"):
					var push_force = direction * speed * 0.02  # Convert velocity to force
					collider.apply_wind_force(push_force)
					print("Wind projectile pushing destructible object!")
					# Don't destroy projectile, let it continue
	
	# Check if out of bounds (optional - can remove if you want them to travel forever)
	if position.x < -1000 or position.x > 10000:
		queue_free()

