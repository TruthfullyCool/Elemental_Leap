extends Area2D

signal player_won

func _ready():
	# COMPLETELY DISABLE WinArea - door is the only way to complete level
	monitoring = false
	monitorable = false
	visible = false
	set_process(false)
	set_physics_process(false)
	print("WinArea: COMPLETELY DISABLED - door is the only way to complete level")

func _on_body_entered(body: Node2D):
	print("WinArea: Body entered - ", body.name, " (checking if flammable object is destroyed)")
	
	# MANDATORY: ALWAYS check if flammable object still exists - if it does, BLOCK win completely
	var final_platform = get_node_or_null("../FinalPlatform")
	if final_platform:
		var flammable = final_platform.get_node_or_null("FlammableObject")
		if flammable and is_instance_valid(flammable):
			print("WinArea: BLOCKED! Flammable object still exists! You MUST destroy it with FIRE ability first!")
			return
	
	# Double-check by searching the entire scene tree for any flammable objects
	var flammable_nodes = get_tree().get_nodes_in_group("flammable")
	for node in flammable_nodes:
		if is_instance_valid(node):
			print("WinArea: BLOCKED! Found flammable object in scene! Destroy it first!")
			return
	
	# Only trigger if player is actually on the platform (check Y position)
	var player = body
	if body.get_parent() and body.get_parent().name == "Player":
		player = body.get_parent()
	
	if player.name == "Player":
		# Only trigger if player is near the platform (y should be around 400 or less)
		if player.global_position.y <= 420:
			print("WinArea: Player detected on platform! Emitting win signal!")
			player_won.emit()
		else:
			print("WinArea: Player detected but not on platform (y=", player.global_position.y, "), ignoring")

