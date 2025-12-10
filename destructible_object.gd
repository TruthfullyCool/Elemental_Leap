extends CharacterBody2D

signal destroyed
signal key_revealed

var is_destroyed = false
var key_reference = null
var push_force = 300.0
var fall_detection_y = 0.0  # Y position threshold - if it falls below this, it breaks
var original_platform_y = 0.0

const GRAVITY = 980.0
const FRICTION = 500.0

@onready var hit_area = $HitArea

func _ready():
	# Add to group for easy finding
	add_to_group("destructible")
	
	# Set up fall detection - will be set by level script
	fall_detection_y = global_position.y + 100  # Default: breaks if falls 100 pixels below start
	original_platform_y = global_position.y
	
	# Set up Area2D for wind projectile detection
	if hit_area:
		hit_area.body_entered.connect(_on_wind_projectile_hit)
	
	print("DestructibleObject ready at position: ", global_position, " fall_detection_y: ", fall_detection_y)

func _on_wind_projectile_hit(body):
	# Check if it's a wind projectile
	if body is CharacterBody2D:
		var effect_type = body.get("effect_type")
		if effect_type == "wind":
			# Apply wind force to push the object
			var wind_direction = body.direction if body.has("direction") else Vector2.RIGHT
			var wind_force = wind_direction * 400.0  # Push force
			apply_wind_force(wind_force)
			print("DestructibleObject: Hit by wind projectile! Applying force: ", wind_force)

func _physics_process(delta):
	if is_destroyed:
		return
	
	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0
	
	# Check if it has fallen off the platform
	if global_position.y > fall_detection_y:
		print("DestructibleObject: Fell off platform! Breaking!")
		break_object()
		return
	
	# Apply friction when on floor
	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	
	# Move the object
	move_and_slide()

func set_fall_detection_y(y_position: float):
	fall_detection_y = y_position
	print("DestructibleObject: Fall detection set to y=", y_position)

func set_key_reference(key_node):
	key_reference = key_node
	print("DestructibleObject: Key reference set")

# This will be called by wind ability when it hits the object
func apply_wind_force(force: Vector2):
	if not is_destroyed:
		velocity += force
		print("DestructibleObject: Wind force applied: ", force, " new velocity: ", velocity)

func break_object():
	if is_destroyed:
		return
	
	is_destroyed = true
	print("DestructibleObject: Breaking!")
	
	# Show the key if it exists
	if key_reference and is_instance_valid(key_reference):
		key_reference.show_key()
		key_reference.global_position = global_position  # Key appears where object broke
		key_revealed.emit()
		print("Key revealed after destructible object broke!")
	
	# Emit destroyed signal
	destroyed.emit()
	
	# Remove the object
	queue_free()

