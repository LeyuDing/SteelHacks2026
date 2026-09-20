extends CharacterBody2D

@export var SPEED : float = 300.0

@export var HP : float = 10.0

@export var burn : float = 0.0
@export var freeze : float = 0.0
@export var stun : bool = false

@onready var player =  get_parent().get_parent().get_node("PlayerCharacter")
@onready var navAgent = $NavigationAgent2D
@onready var AttackTimer = $AttackTimer
@onready var StatusTimer = $StatusTimer
@onready var attack = preload("res://Scenes/attack.tscn")
@onready var burnParticles = $Burn
@onready var freezeParticles = $Freeze

const exp = preload("res://Scenes/exp_drop.tscn")

func _ready():
	$Sprite2D.material = $Sprite2D.material.duplicate()
	SPEED *= GameClock.elapsed_time/10.0
	HP *= GameClock.elapsed_time/10.0
	make_path()

func _physics_process(delta: float) -> void:
	
	if HP <= 0:
		var expDrop = exp.instantiate()
		expDrop.global_position = global_position
		get_parent().add_child(expDrop)
		queue_free()
		
	if (burn != 0):
		if (!burnParticles.visible): burnParticles.visible = true
	if (freeze != 0):
		if (!freezeParticles.visible): freezeParticles.visible = true
		
	if (stun): 
		flash_white()
		await get_tree().create_timer(1.0).timeout
		stun = false
		
	
	var distance_to_player = global_position.distance_to(player.global_position)

	# Close enough to attack
	if distance_to_player <= 200:
		velocity = Vector2.ZERO
		
		if AttackTimer.time_left == 0:
			attack_player()
		
		return
	
	
	var direction = to_local(navAgent.get_next_path_position()).normalized()
	velocity = direction * (SPEED - freeze * 10)
	
	move_and_slide()

func make_path():
	navAgent.target_position = player.global_position
	
func take_damage(damage : int, element : String):
	if (damage != 0) : flash_red()
	HP -= damage
	if element == "fire": burn += 2
	if element == "ice": freeze += 5
	if element == "lightning": 
		stun = true
		velocity = Vector2.ZERO
	
func attack_player():
	AttackTimer.start(1)

	var attack_instance = attack.instantiate()
	attack_instance.global_position = global_position
	attack_instance.look_at(player.global_position)
	get_parent().add_child(attack_instance)
	
func flash_white():
	$Sprite2D.material.set_shader_parameter("flash_color", Color(1, 1, 1, 1))
	$Sprite2D.material.set_shader_parameter("flash_modifier", 1.0)
	
	await get_tree().create_timer(0.1).timeout
	$Sprite2D.material.set_shader_parameter("flash_modifier", 0.0)

func flash_red():
	$Sprite2D.material.set_shader_parameter("flash_color", Color(1, 0, 0, 1))
	$Sprite2D.material.set_shader_parameter("flash_modifier", 1.0)
	
	await get_tree().create_timer(0.15).timeout
	$Sprite2D.material.set_shader_parameter("flash_modifier", 0.0)

func _on_timer_timeout() -> void:	
	if (stun): return
	make_path()

func _on_status_timer_timeout() -> void:
	HP -= burn
	if (burn > 0): 
		burn -= 1
		flash_red()
	else: burnParticles.visible = false
	if (freeze > 0): freeze -= 1
	else: freezeParticles.visible = false
