extends Timer

## Spawns waves of enemies at random points inside the arena.
##
## This Timer fires every `wait_time` seconds (see main_scene.tscn, default
## 5s) to trigger a new wave. Each wave's enemy count is decided by
## calculate_enemy_count() based on GameClock.elapsed_time. Each enemy in the
## wave gets its own random spot in the box; that spot is telegraphed with a
## temporary marker sprite for `spawn_delay` seconds before the enemy
## actually appears there.

const enemy = preload("res://Scenes/test_enemy.tscn")
const spawnMarker = preload("res://Scenes/spawn_marker.tscn")

const wizard1 = preload("res://Assets/wizard/shadow_wizard.png")
const wizard2 = preload("res://Assets/wizard/shadow_wiz_green.png") 
const wizard3 = preload("res://Assets/wizard/shadow_wiz_purple.png")
const wizard4 = preload("res://Assets/wizard/shadow_wiz_red.png")
const wizard5 = preload("res://Assets/wizard/shadow_wiz_yellow.png")

# How long a spawn point is telegraphed before the enemy appears.
@export var spawn_delay : float = 3.0

# The rectangular area enemies can spawn inside, centered on
# spawn_area_center. Sized to stay inside the arena walls in
# main_scene.tscn (those walls sit at roughly +/-1920).
@export var spawn_area_size : Vector2 = Vector2(3600, 3600)
@export var spawn_area_center : Vector2 = Vector2.ZERO

var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()

func _on_timeout() -> void:
	var count = calculate_enemy_count(GameClock.elapsed_time)
	for i in range(count):
		queue_spawn()

# Decides how many enemies should spawn in the current wave, scaling with
# how long the round has been going. A small amount of randomness keeps
# waves from being perfectly predictable without swinging wildly.
func calculate_enemy_count(elapsed_time: float) -> int:
	# Base difficulty ramps up steadily: +1 enemy per 30 seconds elapsed.
	var base_count : int = 1 + int(elapsed_time / 30.0)
	# Small randomness: at most +/-1 off the base count.
	var variance : int = rng.randi_range(-1, 1)
	return max(1, base_count + variance)

func get_random_spawn_position() -> Vector2:
	var half = spawn_area_size / 2.0
	return Vector2(
		rng.randf_range(spawn_area_center.x - half.x, spawn_area_center.x + half.x),
		rng.randf_range(spawn_area_center.y - half.y, spawn_area_center.y + half.y)
	)

# Marks a random spot in the box, then spawns an enemy there after
# spawn_delay seconds have passed.
func queue_spawn() -> void:
	var spawn_position = get_random_spawn_position()

	# TEMPORARY: placeholder marker sprite telegraphing an incoming enemy
	# spawn. Replace with real warning VFX/animation once available
	# (see Scripts/spawn_marker.gd).
	var marker = spawnMarker.instantiate()
	marker.global_position = spawn_position
	marker.lifetime = spawn_delay
	add_child(marker)

	get_tree().create_timer(spawn_delay).timeout.connect(
		func(): _spawn_enemy(spawn_position)
	)

func _spawn_enemy(spawn_position: Vector2) -> void:
	var instance = enemy.instantiate()
	var enemyTexture = instance.get_node("Sprite2D")
	var wizard = [wizard1, wizard2, wizard3, wizard4, wizard5]
	enemyTexture.texture = wizard.pick_random()
	instance.global_position = spawn_position
	add_child(instance)
