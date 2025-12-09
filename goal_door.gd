extends Area2D

signal player_won

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player" or body.is_in_group("player"):
		player_won.emit()

