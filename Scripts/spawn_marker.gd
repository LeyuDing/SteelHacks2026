extends Node2D

## TEMPORARY placeholder visual that telegraphs where an enemy is about to
## spawn. Replace with a proper warning/telegraph VFX or animation once art
## is available - this is just a tinted placeholder sprite (see
## Scenes/spawn_marker.tscn).

# How long the marker stays on screen before the enemy spawns and this
# marker removes itself. Set by whoever instantiates this scene
# (see enemy_spawner.gd) to match the spawn delay.
@export var lifetime : float = 3.0

func _ready() -> void:
	get_tree().create_timer(lifetime).timeout.connect(queue_free)

func _process(delta: float) -> void:
	# Simple pulse so the placeholder marker is easy to notice.
	modulate.a = 0.5 + 0.5 * sin(Time.get_ticks_msec() / 150.0)
