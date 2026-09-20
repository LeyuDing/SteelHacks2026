extends Sprite2D



func _on_area_2d_body_entered(body: Node2D) -> void:
	body.get_parent().exp += 1
	queue_free()
