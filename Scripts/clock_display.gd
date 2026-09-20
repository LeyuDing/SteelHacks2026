extends Label

## Small on-screen clock showing total elapsed time since the round started.
## Reads from the GameClock autoload singleton (Scripts/game_clock.gd).

func _process(delta: float) -> void:
	text = GameClock.get_formatted_time()
