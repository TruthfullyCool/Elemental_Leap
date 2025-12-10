extends Node

# Level progression system
var current_level = 1
var total_levels = 3
var level_scenes = [
	"res://level1.tscn",
	"res://level2.tscn",
	"res://level3.tscn"
]

func _ready():
	# Make this an autoload singleton
	pass

func load_level(level_number: int):
	if level_number > 0 and level_number <= total_levels:
		current_level = level_number
		var scene_path = level_scenes[level_number - 1]
		# Defer scene change to avoid conflicts with scene tree operations
		get_tree().call_deferred("change_scene_to_file", scene_path)

func load_next_level():
	print("LevelManager: load_next_level called. Current level: ", current_level, ", Total: ", total_levels)
	if current_level < total_levels:
		current_level += 1
		var scene_path = level_scenes[current_level - 1]
		print("LevelManager: Loading level ", current_level, " from path: ", scene_path)
		# Defer scene change to avoid conflicts with scene tree operations
		get_tree().call_deferred("change_scene_to_file", scene_path)
	else:
		# All levels completed!
		print("All levels completed!")
		# Could show a completion screen here

func restart_current_level():
	var scene_path = level_scenes[current_level - 1]
	get_tree().reload_current_scene()
