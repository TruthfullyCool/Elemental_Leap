extends CharacterBody2D

# Character data - Elemental characters
var characters = [
	{
		"name": "Water",
		"element": "Water",
		"create_frames": CharacterSprites.create_water_spriteframes,
		"speed": 300.0,
		"jump": -500.0
	},
	{
		"name": "Wind",
		"element": "Wind",
		"create_frames": CharacterSprites.create_wind_spriteframes,
		"speed": 350.0,  # Faster
		"jump": -450.0   # Lower jump
	},
	{
		"name": "Fire",
		"element": "Fire",
		"create_frames": CharacterSprites.create_fire_spriteframes,
		"speed": 250.0,  # Slower
		"jump": -550.0   # Higher jump
	}
]

var current_character_index = 0
var current_character = characters[0]
var animation_state = "idle"  # idle, run, jump

# Base constants
const GRAVITY = 980.0
const ABILITY_COOLDOWN = 0.5  # Cooldown between ability uses
var ability_timer = 0.0

# Ability projectiles
const WATER_PROJECTILE = preload("res://water_projectile.tscn")
const WIND_PROJECTILE = preload("res://wind_projectile.tscn")
const FIRE_PROJECTILE = preload("res://fire_projectile.tscn")

@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	_update_character_visuals()
	_update_animation()

func _input(event):
	# Handle character switching with X key
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_X:
			_switch_character()
		elif event.keycode == KEY_F:
			_use_ability()

func _switch_character():
	# Cycle to next character
	current_character_index = (current_character_index + 1) % characters.size()
	current_character = characters[current_character_index]
	_update_character_visuals()
	_update_animation()
	
	# Optional: Print character name for debugging
	print("Switched to: ", current_character.name, " (", current_character.element, ")")

func _update_character_visuals():
	# Create sprite frames for the current character
	if animated_sprite:
		var sprite_frames = current_character.create_frames.call()
		animated_sprite.sprite_frames = sprite_frames
		# Set default animation
		if sprite_frames.has_animation("idle"):
			animated_sprite.play("idle")
		_update_animation()

func _update_animation():
	if not animated_sprite:
		return
	
	# Determine animation state based on movement
	var new_state = "idle"
	
	if not is_on_floor():
		new_state = "jump"
	elif abs(velocity.x) > 10:
		new_state = "run"
	else:
		new_state = "idle"
	
	# Only change animation if state changed
	if new_state != animation_state:
		animation_state = new_state
		if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation(animation_state):
			animated_sprite.play(animation_state)

func _physics_process(delta):
	# Update ability cooldown timer
	if ability_timer > 0:
		ability_timer -= delta
	
	# Apply gravity when not on floor
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		# Reset vertical velocity when on floor to prevent sliding
		velocity.y = 0
	
	# Handle jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = current_character.jump
	
	# Handle horizontal movement (left/right)
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * current_character.speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_character.speed)
	
	# Flip sprite based on movement direction
	if direction != 0 and animated_sprite:
		animated_sprite.flip_h = direction < 0
	
	# Update animation
	_update_animation()
	
	# Move the character
	move_and_slide()

func _use_ability():
	# Check cooldown
	if ability_timer > 0:
		return
	
	# Reset cooldown
	ability_timer = ABILITY_COOLDOWN
	
	# Determine direction based on sprite flip
	var facing_direction = Vector2.RIGHT
	if animated_sprite and animated_sprite.flip_h:
		facing_direction = Vector2.LEFT
	
	# Spawn appropriate projectile based on character
	var projectile_scene = null
	match current_character.element:
		"Water":
			projectile_scene = WATER_PROJECTILE
		"Wind":
			projectile_scene = WIND_PROJECTILE
		"Fire":
			projectile_scene = FIRE_PROJECTILE
	
	if projectile_scene:
		var projectile = projectile_scene.instantiate()
		# Position projectile in front of player
		var spawn_offset = Vector2(20, 0) if facing_direction.x > 0 else Vector2(-20, 0)
		projectile.position = global_position + spawn_offset
		projectile.direction = facing_direction
		
		# Add to scene tree (parent is the level)
		get_tree().current_scene.add_child(projectile)
		
		print("Used ", current_character.element, " ability!")
