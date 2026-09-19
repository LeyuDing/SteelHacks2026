extends Timer

const enemy = preload("res://Scenes/test_enemy.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()


func _on_timeout() -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var path = get_parent().get_node("PlayerCharacter/EnemySpawner/PathFollow2D")
	
	path.progress_ratio = rng.randi_range(0.0, 1.0)
	
	var instance = enemy.instantiate()

	instance.global_position = path.get_node("Marker2D").global_position
	
	add_child(instance)
