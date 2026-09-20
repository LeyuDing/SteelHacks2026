extends Control

## Bottom-of-screen HUD showing the player's health as a square (sharp-cornered)
## bar, centered horizontally at the bottom of the screen.
##
## The bar fills red from the left; as the player takes damage the red
## portion shrinks from the right, tracking HP / max_HP. Both the red fill
## and the empty-portion backing are semi-transparent so the arena stays
## visible through the bar, while the "SWAG" label on top is fully opaque.
##
## HP is read straight from the player's HP/max_HP every _process() frame
## (same pattern as Scripts/spell_cooldown_bar.gd), so the bar updates the
## instant damage is taken with no signal wiring required.

@export var bar_width : float = 320.0
@export var bar_height : float = 48.0
@export var bottom_margin : float = 12.0

@export var empty_color : Color = Color(0.12, 0.12, 0.12, 0.55)
@export var fill_color : Color = Color(0.85, 0.05, 0.05, 0.75)
@export var label_font_size : int = 26
@export var label_outline_size : int = 6

@onready var player = get_tree().current_scene.get_node_or_null("PlayerCharacter")

var _empty_panel : Panel
var _fill_panel : Panel
var _label : Label


func _ready() -> void:
	_build()
	_layout()


func _build() -> void:
	_empty_panel = Panel.new()
	_empty_panel.name = "Empty"
	_empty_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_empty_panel)

	_fill_panel = Panel.new()
	_fill_panel.name = "Fill"
	_fill_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_fill_panel)

	_label = Label.new()
	_label.name = "SwagLabel"
	_label.text = "SWAG"
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_label)


func _layout() -> void:
	anchor_left = 0.5
	anchor_right = 0.5
	anchor_top = 1.0
	anchor_bottom = 1.0
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	offset_left = -bar_width / 2.0
	offset_right = bar_width / 2.0
	offset_top = -(bar_height + bottom_margin)
	offset_bottom = -bottom_margin

	var empty_style := StyleBoxFlat.new()
	empty_style.corner_radius_top_left = 0
	empty_style.corner_radius_top_right = 0
	empty_style.corner_radius_bottom_left = 0
	empty_style.corner_radius_bottom_right = 0
	empty_style.bg_color = empty_color

	var fill_style := StyleBoxFlat.new()
	fill_style.corner_radius_top_left = 0
	fill_style.corner_radius_top_right = 0
	fill_style.corner_radius_bottom_left = 0
	fill_style.corner_radius_bottom_right = 0
	fill_style.bg_color = fill_color

	_empty_panel.position = Vector2.ZERO
	_empty_panel.size = Vector2(bar_width, bar_height)
	_empty_panel.add_theme_stylebox_override("panel", empty_style)

	_fill_panel.position = Vector2.ZERO
	_fill_panel.size = Vector2(bar_width, bar_height)
	_fill_panel.add_theme_stylebox_override("panel", fill_style)

	_label.position = Vector2.ZERO
	_label.size = Vector2(bar_width, bar_height)
	_label.add_theme_font_size_override("font_size", label_font_size)
	_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	_label.add_theme_constant_override("outline_size", label_outline_size)


func _process(_delta: float) -> void:
	if player == null:
		return

	var hp : float = player.get("HP")
	var max_hp : float = player.get("max_HP")

	var fraction := 0.0
	if max_hp > 0.0:
		fraction = clampf(hp / max_hp, 0.0, 1.0)

	# Fill shrinks from the right as HP drops, leaving the empty backing
	# (drawn underneath, full width) exposed on the right side.
	_fill_panel.size.x = bar_width * fraction
