extends Node2D

func _ready():
	# Load level 1 when game starts - defer to next frame to avoid scene tree conflicts
	call_deferred("_load_first_level")

func _load_first_level():
	LevelManager.load_level(1)
