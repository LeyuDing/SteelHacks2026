extends CharacterBody2D


const SPEED = 300.0

func _onready():
	# Makes the camera attach to the player the main one
	$Camera2D.make_current()

func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Vector2(Input.get_axis("ui_left", "ui_right"),
							 Input.get_axis("ui_up", "ui_down"))
							
	if direction:
		velocity.x = direction[0] * SPEED
		velocity.y = direction[1] * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)

	move_and_slide()
