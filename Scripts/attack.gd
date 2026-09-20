extends Node2D

@export var damage = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	var bodies = $Area2D.get_overlapping_bodies()
	if bodies != null:
		for body in bodies:
			if body.has_method("take_damage"):
				body.take_damage(damage)
	
	await get_tree().create_timer(0.1).timeout
	queue_free()
