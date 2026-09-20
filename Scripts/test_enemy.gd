extends CharacterBody2D

@export var SPEED : float = 300.0

@export var HP : float = 10.0

@onready var player =  get_parent().get_parent().get_node("PlayerCharacter")
@onready var navAgent = $NavigationAgent2D
@onready var timer = $AttackTimer
@onready var attack = preload("res://Scenes/attack.tscn")

const exp = preload("res://Scenes/exp_drop.tscn")

func _ready():
	modulate = Color(randf(), randf(), randf(), 1.0)

func _physics_process(delta: float) -> void:
	
	if HP <= 0:
		var expDrop = exp.instantiate()
		expDrop.global_position = global_position
		get_parent().add_child(expDrop)
		queue_free()
	
	var distance_to_player = global_position.distance_to(player.global_position)

	# Close enough to attack
	if distance_to_player <= 200:
		velocity = Vector2.ZERO
		
		if timer.time_left == 0:
			attack_player()
		
		return
	
	
	var direction = to_local(navAgent.get_next_path_position()).normalized()
	velocity = direction * SPEED
	
	move_and_slide()

func make_path():
	navAgent.target_position = player.global_position
	
func take_damage(damage : int):
	HP -= damage
	
func attack_player():
	timer.start(1)

	var attack_instance = attack.instantiate()
	attack_instance.global_position = global_position
	attack_instance.look_at(player.global_position)
	get_parent().add_child(attack_instance)

func _on_timer_timeout() -> void:
	make_path()
