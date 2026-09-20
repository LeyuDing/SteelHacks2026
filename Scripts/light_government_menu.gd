extends CanvasLayer

## Level-up flow triggered from main_scene.gd's "Press F..." prompt.
##
## Runs at process_mode = ALWAYS (see main_scene.tscn) so this menu, its
## LineEdit input, and the wait in _process_request() below all keep working
## while get_tree().paused is true (main_scene.gd pauses the tree so the
## rest of the round - enemies, timers, the player - freezes while the menu
## is open).
##
## Three screens, one visible at a time:
##  1. InputScreen  - character sprite + a LineEdit for the player's request.
##  2. WaitingScreen - character sprite + a "Waiting..." label.
##  3. ResponseScreen - character sprite + the response text, plus three
##     selectable spell options.

signal resolved

@onready var input_screen = $Background/InputScreen
@onready var waiting_screen = $Background/WaitingScreen
@onready var response_screen = $Background/ResponseScreen

@onready var input_box = $Background/InputScreen/InputBox
@onready var response_text = $Background/ResponseScreen/ResponseText
@onready var spell_option_buttons = [
	$Background/ResponseScreen/SpellOptions/Option1,
	$Background/ResponseScreen/SpellOptions/Option2,
	$Background/ResponseScreen/SpellOptions/Option3,
]

# Set by _on_input_box_text_submitted(), read by _process_request().
var submitted_text : String = ""

# Set once the response comes back (see _on_response_ready()).
var spell_options : Array = []


func _ready() -> void:
	visible = false
	for i in spell_option_buttons.size():
		spell_option_buttons[i].pressed.connect(_on_spell_option_pressed.bind(i))


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


func _on_input_box_text_submitted(new_text: String) -> void:
	submitted_text = new_text
	_show_screen(waiting_screen)
	_process_request(submitted_text)


# TODO: replace this stand-in with the real Light Government request/response
# system. Whatever calls it just needs to end by calling _on_response_ready()
# with a response string and a list of spell options. get_tree().create_timer()
# defaults to process_always = true, so it (like everything else in this
# menu) keeps ticking while get_tree().paused is true.
func _process_request(text: String) -> void:
	await get_tree().create_timer(2.0).timeout

	var response := "The Light Government has reviewed your request."
	var options := ["Placeholder Spell A", "Placeholder Spell B", "Placeholder Spell C"]
	_on_response_ready(response, options)


func _on_response_ready(response: String, options: Array) -> void:
	response_text.text = response
	spell_options = options

	for i in spell_option_buttons.size():
		var button = spell_option_buttons[i]
		button.visible = i < options.size()
		if i < options.size():
			button.text = str(options[i])

	_show_screen(response_screen)


func _on_spell_option_pressed(index: int) -> void:
	# TODO: apply spell_options[index] to the player once upgrade effects are
	# designed (see the docstring above main_scene.gd's spell dictionaries).
	visible = false
	get_tree().paused = false
	resolved.emit()
