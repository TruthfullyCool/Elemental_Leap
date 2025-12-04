extends Area2D

signal player_won

func _ready():
	# Connect body entered signal
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
	# Check if the body is the player
	if body.name == "Player":
		player_won.emit()

