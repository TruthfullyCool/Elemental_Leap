extends CharacterBody2D

# Character data with element types
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
		"speed": 350.0,
		"jump": -450.0
	},
	{
		"name": "Fire",
		"element": "Fire",
		"create_frames": CharacterSprites.create_fire_spriteframes,
		"speed": 250.0,
		"jump": -550.0
	}
]

var current_character_index = 0
var current_character = characters[0]

# Base constants
const GRAVITY = 980.0

@onready var animated_sprite = $AnimatedSprite2D

# Ability cooldown
@export var ability_cooldown: float = 0.5
var can_use_ability: bool = true

func _ready():
	_update_character_visuals()
	_update_animation()

func _input(event):
	# Handle character switching with X key
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_X:
			_switch_character()
		elif event.keycode == KEY_F and can_use_ability:
			_cast_ability()

func _switch_character():
	# Cycle to next character
	current_character_index = (current_character_index + 1) % characters.size()
	current_character = characters[current_character_index]
	_update_character_visuals()
	_update_animation()
	
	print("Switched to: ", current_character.name)

func _update_character_visuals():
	if not animated_sprite:
		return
	
	# Load sprite frames for current character
	var sprite_frames = current_character.create_frames.call()
	if sprite_frames:
		animated_sprite.sprite_frames = sprite_frames
		_update_animation()

func _update_animation():
	if not animated_sprite:
		return
	
	# Determine which animation to play
	if not is_on_floor():
		if animated_sprite.sprite_frames.has_animation("jump"):
			animated_sprite.play("jump")
	else:
		if abs(velocity.x) > 10:
			if animated_sprite.sprite_frames.has_animation("run"):
				animated_sprite.play("run")
		else:
			if animated_sprite.sprite_frames.has_animation("idle"):
				animated_sprite.play("idle")

func _cast_ability():
	can_use_ability = false
	var cooldown_timer = get_tree().create_timer(ability_cooldown)
	cooldown_timer.timeout.connect(func(): can_use_ability = true)
	
	var projectile_scene: PackedScene
	var facing_direction = Vector2.RIGHT if not animated_sprite.flip_h else Vector2.LEFT
	
	match current_character.element:
		"Water":
			projectile_scene = load("res://water_projectile.tscn")
		"Wind":
			projectile_scene = load("res://wind_projectile.tscn")
		"Fire":
			projectile_scene = load("res://fire_projectile.tscn")
		_:
			return
	
	if projectile_scene:
		var projectile = projectile_scene.instantiate()
		# Position projectile in front of player
		var spawn_offset = Vector2(20, 0) if facing_direction.x > 0 else Vector2(-20, 0)
		projectile.position = global_position + spawn_offset
		projectile.direction = facing_direction
		
		# Set effect type based on character element
		projectile.effect_type = current_character.element.to_lower()
		
		# Add to scene tree (parent is the level)
		get_tree().current_scene.add_child(projectile)
		
		print("Used ", current_character.element, " ability!")

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
