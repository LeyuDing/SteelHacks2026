extends Control

## Bottom-of-screen HUD tracking each spell's cooldown as a rounded square
## labeled 1-4, centered on the screen's vertical axis.
##
## Everything (square size, spacing, margin, corner rounding, colors) is
## driven by the @export vars below and applied in _layout(), so resizing
## or repositioning the whole bar never requires touching the scene tree -
## just change a value here or in the Inspector.
##
## Each square starts dull white (ready). Casting a spell (see
## main_scene.gd's spell_caster(), which starts SpellNTimer) turns its
## square gray; as SpellNTimer counts down, a gray "CooldownOverlay" panel
## pinned to the top of the square shrinks at the same rate as the
## cooldown, uncovering the dull-white base from the bottom up until the
## square reads fully ready again.
##
## Cooldown state is read straight from the main scene's spellN dicts and
## SpellNTimer nodes every _process() frame, so it can never go stale -
## in particular, whatever changes an upgrade makes to a spell's cooldown
## shows up on the very next frame after the upgrade screen closes, which
## satisfies "update at least once per upgrade pick" for free.

@export var square_size : float = 64.0
@export var square_spacing : float = 16.0
@export var bottom_margin : float = 24.0
@export var corner_radius : float = 12.0
@export var number_font_size : int = 28

@export var ready_color : Color = Color(0.92, 0.92, 0.9, 1.0)
@export var cooldown_color : Color = Color(0.35, 0.35, 0.35, 1.0)
@export var number_color : Color = Color(0.15, 0.15, 0.15, 1.0)

const SPELL_COUNT := 4

@onready var game_scene = get_tree().current_scene

var _bases : Array[Panel] = []
var _overlays : Array[Panel] = []

var names = ["Left\n Click", "Right\n Click", "q", "e"]


func _ready() -> void:
	_build_slots()
	_layout()


# Creates the 4 slots (base square + cooldown overlay + number label) purely
# in code, so the scene file only ever needs this one Control node.
func _build_slots() -> void:
	for i in SPELL_COUNT:
		var slot := Control.new()
		slot.name = "Slot%d" % (i + 1)
		slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(slot)

		var base := Panel.new()
		base.name = "Base"
		base.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(base)
		_bases.append(base)

		var overlay := Panel.new()
		overlay.name = "CooldownOverlay"
		overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(overlay)
		_overlays.append(overlay)

		var label := Label.new()
		label.name = "NumberLabel"
		label.text = names[i]
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(label)


# Positions/sizes the bar and its slots from the @export knobs above. Called
# once at startup; re-call manually (e.g. from the editor's "Remote" tree,
# or by bumping one of the exports) if you change a knob at runtime.
func _layout() -> void:
	var total_width := SPELL_COUNT * square_size + (SPELL_COUNT - 1) * square_spacing

	# Center the whole bar on the screen's vertical axis, flush near the
	# bottom edge.
	anchor_left = 0.5
	anchor_right = 0.5
	anchor_top = 1.0
	anchor_bottom = 1.0
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	offset_left = -total_width / 2.0
	offset_right = total_width / 2.0
	offset_top = -(square_size + bottom_margin)
	offset_bottom = -bottom_margin

	var base_style := StyleBoxFlat.new()
	base_style.set_corner_radius_all(int(corner_radius))
	base_style.bg_color = ready_color

	var overlay_style := StyleBoxFlat.new()
	overlay_style.set_corner_radius_all(int(corner_radius))
	overlay_style.bg_color = cooldown_color

	for i in SPELL_COUNT:
		var slot : Control = get_child(i)
		slot.position = Vector2(i * (square_size + square_spacing), 0.0)
		slot.size = Vector2(square_size, square_size)

		var base : Panel = _bases[i]
		base.position = Vector2.ZERO
		base.size = Vector2(square_size, square_size)
		base.add_theme_stylebox_override("panel", base_style)

		var overlay : Panel = _overlays[i]
		overlay.position = Vector2.ZERO
		overlay.size = Vector2(square_size, 0.0)
		overlay.add_theme_stylebox_override("panel", overlay_style)

		var label : Label = slot.get_node("NumberLabel")
		label.position = Vector2.ZERO
		label.size = Vector2(square_size, square_size)
		label.add_theme_font_size_override("font_size", number_font_size)
		label.add_theme_color_override("font_color", number_color)


func _process(_delta: float) -> void:
	if game_scene == null:
		return

	for i in SPELL_COUNT:
		var spell : Variant = game_scene.get("spell%d" % (i + 1))
		var timer : Timer = game_scene.get_node_or_null("Spell%dTimer" % (i + 1))

		var fraction := 0.0
		if spell != null and timer != null:
			var cooldown : float = spell.get("cooldown", 0.0)
			if cooldown > 0.0:
				fraction = clampf(timer.time_left / cooldown, 0.0, 1.0)

		# fraction is 1.0 right after casting (fully gray) and eases to 0.0
		# as the cooldown finishes (fully dull white again), so the overlay
		# height tracks the cooldown 1:1.
		_overlays[i].size.y = square_size * fraction
