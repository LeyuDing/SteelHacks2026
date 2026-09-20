extends CharacterBody2D


const SPEED = 300.0

@export var HP = 10.0
@export var max_HP = 10.0
@export var health_regen_rate = 0.02 # HP regenerated per second

func _onready():
	# Makes the camera attach to the player the main one
	$Camera2D.make_current()

func _physics_process(delta: float) -> void:
	
	# HP hitting 0 is handled by Scripts/game_over_screen.gd, which plays a
	# fade-to-black death sequence and pauses the tree once it finishes -
	# no instant pause here.
	if HP > 0.0 and HP < max_HP:
		HP = min(HP + health_regen_rate * delta, max_HP)

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
	
func take_damage(damage : int):
	HP = max(HP - damage, 0.0)
