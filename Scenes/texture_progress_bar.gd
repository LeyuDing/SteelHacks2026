extends TextureProgressBar

@onready var root = get_tree().current_scene

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	max_value = root.expCap
	value = root.exp
	
