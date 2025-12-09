extends CharacterBody2D

var speed = 500.0
var direction = Vector2.RIGHT
var lifetime = 2.0
var damage = 0  # Can be used for future damage system

func _ready():
	# Set velocity based on direction
	velocity = direction * speed
	
	# Auto-destroy after lifetime
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta):
	# Move the projectile
	position += velocity * delta
	
	# Check if out of bounds (optional - can remove if you want them to travel forever)
	if position.x < -1000 or position.x > 10000:
		queue_free()


