extends Node

## Global stopwatch tracking how long the current round has been running.
## Registered as an autoload singleton (see project.godot [autoload]) so any
## script can read GameClock.elapsed_time, and the on-screen clock
## (clock_display.gd) and the enemy spawner's difficulty scaling
## (enemy_spawner.gd's calculate_enemy_count()) both read from one place.

var elapsed_time : float = 0.0

func _process(delta: float) -> void:
	elapsed_time += delta

# Call this whenever a new round starts (see main_scene.gd) so the timer
# doesn't carry over from a previous run.
func reset() -> void:
	elapsed_time = 0.0

# Formats elapsed_time as MM:SS for display.
func get_formatted_time() -> String:
	var total_seconds := int(elapsed_time)
	var minutes := total_seconds / 60
	var seconds := total_seconds % 60
	return "%02d:%02d" % [minutes, seconds]
