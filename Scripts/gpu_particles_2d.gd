extends GPUParticles2D

@export var duration : float


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(duration).timeout
	queue_free()
