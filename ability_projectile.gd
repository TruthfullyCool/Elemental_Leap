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
	position += velocity * delta
	
	# Check if out of bounds (optional - can remove if you want them to travel forever)
	if position.x < -1000 or position.x > 10000:
		queue_free()

