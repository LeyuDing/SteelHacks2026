extends CanvasLayer

## Death sequence shown when the player's HP hits 0.
##
## Sequence: the health bar (Scripts/health_bar.gd) already reads HP every
## frame, so it reads empty the same frame HP hits 0 - no extra work needed
## there. This node then fades a full-screen black overlay in over
## `fade_duration` seconds (the world keeps running/visible underneath while
## it fades), then fades in the "FIRED FOR LOSS OF SWAG" title and EXIT
## button, centered on both axes, and finally pauses the game tree.
##
## Runs at PROCESS_MODE_ALWAYS so its own tween and the EXIT button keep
## working after the tree is paused.

@export var fade_duration : float = 5.0

@onready var player = get_tree().current_scene.get_node_or_null("PlayerCharacter")

var _triggered := false

var _overlay : ColorRect
var _title : Label
var _exit_button : Button


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 10
	_build()


func _build() -> void:
	_overlay = ColorRect.new()
	_overlay.name = "Overlay"
	_overlay.color = Color(0, 0, 0, 0)
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_overlay)

	_title = Label.new()
	_title.name = "Title"
	_title.text = "FIRED FOR LOSS OF SWAG"
	_title.modulate.a = 0.0
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_title.add_theme_font_size_override("font_size", 44)
	_title.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	_title.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	_title.add_theme_constant_override("outline_size", 6)
	_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_title.anchor_left = 0.5
	_title.anchor_right = 0.5
	_title.anchor_top = 0.5
	_title.anchor_bottom = 0.5
	_title.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_title.offset_left = -420.0
	_title.offset_right = 420.0
	_title.offset_top = -90.0
	_title.offset_bottom = -30.0
	add_child(_title)

	_exit_button = Button.new()
	_exit_button.name = "ExitButton"
	_exit_button.text = "EXIT"
	_exit_button.modulate.a = 0.0
	_exit_button.disabled = true
	_exit_button.anchor_left = 0.5
	_exit_button.anchor_right = 0.5
	_exit_button.anchor_top = 0.5
	_exit_button.anchor_bottom = 0.5
	_exit_button.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_exit_button.offset_left = -70.0
	_exit_button.offset_right = 70.0
	_exit_button.offset_top = 20.0
	_exit_button.offset_bottom = 60.0
	_exit_button.pressed.connect(_on_exit_pressed)
	add_child(_exit_button)


func _process(_delta: float) -> void:
	if _triggered or player == null:
		return

	if player.get("HP") <= 0.0:
		_triggered = true
		_play_death_sequence()


func _play_death_sequence() -> void:
	var tween := create_tween()
	tween.tween_property(_overlay, "color:a", 1.0, fade_duration)
	tween.tween_callback(_fade_in_ui)


func _fade_in_ui() -> void:
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(_title, "modulate:a", 1.0, 0.6)
	tween.tween_property(_exit_button, "modulate:a", 1.0, 0.6)
	tween.chain().tween_callback(_finish_sequence)


func _finish_sequence() -> void:
	_exit_button.disabled = false
	get_tree().paused = true


func _on_exit_pressed() -> void:
	get_tree().quit()
