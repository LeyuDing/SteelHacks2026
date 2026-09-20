extends Sprite2D

@onready var parent = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mousePos = get_global_mouse_position()
	var oppositePoint = parent.global_position * 2.0 - mousePos
	look_at(oppositePoint)
	
	flip_v = get_global_mouse_position().x > parent.global_position.x
		
