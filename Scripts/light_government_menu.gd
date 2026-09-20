extends CanvasLayer

## Level-up flow triggered from main_scene.gd's "Press F..." prompt.
##
## Runs at process_mode = ALWAYS (see main_scene.tscn) so this menu, its
## LineEdit input, and the wait in _process_request() below all keep working
## while get_tree().paused is true (main_scene.gd pauses the tree so the
## rest of the round - enemies, timers, the player - freezes while the menu
## is open).
##
## Four screens, one visible at a time:
##  1. InputScreen  - character sprite + a LineEdit for the player's request.
##  2. WaitingScreen - character sprite + a "Waiting..." label.
##  3. ResponseScreen - character sprite + the response text, plus three
##     selectable spell options (fully described).
##  4. SlotSelectScreen - shown after picking one of the 3 new spells; lists
##     the player's 4 current spells (fully described) so they can pick
##     which slot the new spell replaces.

signal resolved

@onready var main_scene = get_parent()

@onready var input_screen = $Background/InputScreen
@onready var waiting_screen = $Background/WaitingScreen
@onready var response_screen = $Background/ResponseScreen
@onready var slot_select_screen = $Background/SlotSelectScreen

@onready var input_box = $Background/InputScreen/InputBox
@onready var response_text = $Background/ResponseScreen/ResponseText
@onready var spell_option_buttons = [
	$Background/ResponseScreen/SpellOptions/Option1,
	$Background/ResponseScreen/SpellOptions/Option2,
	$Background/ResponseScreen/SpellOptions/Option3,
]
@onready var slot_option_buttons = [
	$Background/SlotSelectScreen/SlotOptions/Slot1,
	$Background/SlotSelectScreen/SlotOptions/Slot2,
	$Background/SlotSelectScreen/SlotOptions/Slot3,
	$Background/SlotSelectScreen/SlotOptions/Slot4,
]

# The order/labels used to render a spell dictionary as
# "attribute: value" lines on the selection buttons.
const SPELL_FIELD_ORDER := [
	"name", "description", "element", "damage", "cooldown",
	"duration", "projectile", "aoe", "origin", "width", "height",
]

# Set by _on_input_box_text_submitted(), read by _process_request().
var submitted_text : String = ""

# Set once the response comes back (see _on_response_ready()).
var spell_options : Array = []

# The new spell the player picked on ResponseScreen, waiting to be dropped
# into whichever slot they pick on SlotSelectScreen.
var chosen_spell : Dictionary = {}


func _ready() -> void:
	visible = false
	for i in spell_option_buttons.size():
		spell_option_buttons[i].pressed.connect(_on_spell_option_pressed.bind(i))
	for i in slot_option_buttons.size():
		slot_option_buttons[i].pressed.connect(_on_slot_option_pressed.bind(i))


func open() -> void:
	visible = true
	submitted_text = ""
	input_box.text = ""
	_show_screen(input_screen)
	# Deferred: grab_focus() on the same frame the LineEdit becomes visible
	# is unreliable (the viewport hasn't processed the visibility change
	# yet), so the player would have to click the box before typing.
	input_box.call_deferred("grab_focus")


func _show_screen(screen: Control) -> void:
	input_screen.visible = screen == input_screen
	waiting_screen.visible = screen == waiting_screen
	response_screen.visible = screen == response_screen
	slot_select_screen.visible = screen == slot_select_screen


func _on_input_box_text_submitted(new_text: String) -> void:
	submitted_text = new_text
	_show_screen(waiting_screen)
	_process_request(submitted_text)

# Sends the player's prompt (plus their current spells, for context) to the
# model and waits for a response - the waiting screen stays up the whole
# time since nothing here changes _show_screen() until it resolves.
# get_tree().create_timer() (used inside ApiCall) defaults to
# process_always = true, so it (like everything else in this menu) keeps
# ticking while get_tree().paused is true.
func _process_request(text: String) -> void:
	print(text)
	var api_response := await ApiCall.ask(text, main_scene.get_dict_of_spells())
	print(api_response["response"])
	var witty_quip : String = api_response["response"]
	var spells : Array[Dictionary] = api_response["json"]
	var spell_desc := [spells[0]["name"], spells[1]["name"], spells[2]["name"]]
	_on_response_ready(witty_quip, spell_desc, spells)


# Renders a spell dictionary as "attribute: value" lines, one per line, for
# display on a selection button. Handles the empty-slot case ({}).
func _format_spell_lines(spell: Dictionary) -> String:
	if spell.is_empty():
		return "(Empty Slot)"

	var lines : Array[String] = []
	for field in SPELL_FIELD_ORDER:
		if spell.has(field):
			lines.append("%s: %s" % [field, spell[field]])
	return "\n".join(lines)


func _on_response_ready(response: String, options: Array, spells : Array[Dictionary]) -> void:
	response_text.text = response
	spell_options = options

	for i in spell_option_buttons.size():
		var button = spell_option_buttons[i]
		button.visible = i < options.size()
		if i < options.size():
			button.text = _format_spell_lines(spells[i])

			#When a button gets pressed, it should read from self.spell_itself to figure out the spell
			button.set_meta("spell_itself", spells[i])

	_show_screen(response_screen)


func _on_spell_option_pressed(index: int) -> void:
	chosen_spell = spell_option_buttons[index].get_meta("spell_itself")
	_open_slot_select_screen()


# Shows the 4 current spells (fully described, same as the spell options)
# so the player can pick which slot chosen_spell replaces.
func _open_slot_select_screen() -> void:
	var current_spells : Array[Dictionary] = main_scene.get_dict_of_spells()

	for i in slot_option_buttons.size():
		slot_option_buttons[i].text = _format_spell_lines(current_spells[i])

	_show_screen(slot_select_screen)


func _on_slot_option_pressed(index: int) -> void:
	main_scene.set_spell(index, chosen_spell)

	visible = false
	get_tree().paused = false
	resolved.emit()
