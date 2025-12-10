extends Area2D

signal player_won

var has_key = false  # Door is locked until key is collected

func _ready():
	# Ensure monitoring is enabled
	monitoring = true
	monitorable = false
	
	# Connect both body_entered and area_entered signals
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	
	# Check if there's a key in the scene and connect to it
	var key = get_node_or_null("../Key")
	if not key:
		# Try to find key anywhere in the scene tree
		key = get_tree().get_first_node_in_group("key")
	
	if key:
		if key.has_signal("key_collected"):
			key.key_collected.connect(_on_key_collected)
			print("GoalDoor: Connected to key, door is LOCKED until key is collected")
		else:
			print("GoalDoor: Key found but no signal")
	else:
		# Check again after a delay
		await get_tree().create_timer(0.1).timeout
		key = get_node_or_null("../Key")
		if not key:
			key = get_tree().get_first_node_in_group("key")
		if key and key.has_signal("key_collected"):
			key.key_collected.connect(_on_key_collected)
			print("GoalDoor: Connected to key (delayed), door is LOCKED")
	
	print("GoalDoor ready at position: ", global_position, " has_key: ", has_key)

func _on_body_entered(body):
	print("GoalDoor: Body entered - ", body.name, " (type: ", body.get_class(), ")")
	_check_for_player(body)

func _on_area_entered(area):
	print("GoalDoor: Area entered - ", area.name)
	
	# Check if door is locked
	if not has_key:
		print("GoalDoor: Door is LOCKED! You need to collect the key first!")
		return
	
	# Check if the area belongs to the player
	var parent = area.get_parent()
	if parent and parent.name == "Player":
		print("GoalDoor: Player area detected with key! Emitting win signal!")
		player_won.emit()

func _on_key_collected():
	has_key = true
	print("GoalDoor: Key collected! Door is now UNLOCKED!")

func _check_for_player(body):
	# Check if door is locked
	if not has_key:
		print("GoalDoor: Door is LOCKED! You need to collect the key first!")
		# Check if key still exists
		var key = get_node_or_null("../Key")
		if not key:
			key = get_tree().get_first_node_in_group("key")
		if key and is_instance_valid(key) and not key.is_collected:
			print("GoalDoor: Key is still available. Find and destroy the flammable object to reveal it!")
		return
	
	# Check if it's the player directly
	if body.name == "Player":
		print("GoalDoor: Player detected with key! Emitting win signal!")
		player_won.emit()
		return
	
	# Check if it's a child of the player
	var parent = body.get_parent()
	while parent:
		if parent.name == "Player":
			print("GoalDoor: Player parent detected with key! Emitting win signal!")
			player_won.emit()
			return
		parent = parent.get_parent()
