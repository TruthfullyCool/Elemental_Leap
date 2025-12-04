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

@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	_update_character_visuals()
	_update_animation()

func _input(event):
	# Handle character switching with X key
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_X:
			_switch_character()

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
