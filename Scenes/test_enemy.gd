extends CharacterBody2D

@export var SPEED : float = 150.0

@export var HP : float = 10.0

@onready var player =  get_parent().get_parent().get_node("PlayerCharacter")
@onready var navAgent = $NavigationAgent2D

func _ready():
	modulate = Color(randf(), randf(), randf(), 1.0)
	make_path()

func _physics_process(delta: float) -> void:
	
	if HP <= 0:
		queue_free()
	
	var direction = to_local(navAgent.get_next_path_position()).normalized()
	velocity = direction * SPEED
	
	move_and_slide()

func make_path():
	navAgent.target_position = player.global_position
	
func take_damage(damage : int):
	HP -= damage

func _on_timer_timeout() -> void:
	make_path()
