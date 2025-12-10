extends Area2D

signal key_collected

var is_collected = false

func _ready():
	# Start hidden - will be shown when flammable object is destroyed
	visible = false
	monitoring = true
	monitorable = false
	
	body_entered.connect(_on_body_entered)
	print("Key ready at position: ", global_position, " (hidden)")

func _on_body_entered(body):
	if is_collected:
		return
	
	# Check if it's the player
	var player = body
	if body.get_parent() and body.get_parent().name == "Player":
		player = body.get_parent()
	
	if player.name == "Player":
		print("Key collected by player!")
		is_collected = true
		key_collected.emit()
		# Hide the key
		visible = false
		monitoring = false
		queue_free()

func show_key():
	visible = true
	monitoring = true
	print("Key is now visible at position: ", global_position)

