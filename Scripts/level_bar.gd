extends TextureProgressBar

## Vertical "level up" bar on the right edge of the HUD.
##
## Fills from the bottom up as the player collects mana/exp (see
## Scenes/exp_drop.gd, which adds to MainScene.exp) and resets on its own
## once MainScene.gd levels the player up (exp wraps back to 0 and expCap
## grows), since this just mirrors exp / expCap each frame.
##
## The visible fill (texture_progress, set to a placeholder sprite in
## main_scene.tscn) is semi-transparent via modulate so the arena behind the
## HUD stays visible, and it sits inside a rounded-rectangle Panel ("Frame",
## its sibling in main_scene.tscn) that encases it.

# How quickly the bar animates toward the real exp ratio, instead of
# snapping instantly, so gains read as a "slow reveal".
const FILL_SPEED : float = 4.0

@onready var game_scene = get_tree().current_scene

func _process(delta: float) -> void:
	if game_scene == null:
		return

	var target_ratio : float = float(game_scene.exp) / float(game_scene.expCap)
	value = lerp(value, target_ratio, delta * FILL_SPEED)
