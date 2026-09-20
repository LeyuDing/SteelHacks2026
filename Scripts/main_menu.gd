extends Control

# The scene that a round of the game is played in.
const GAME_SCENE = "res://Scenes/main_scene.tscn"

# TODO: Point these at the real scenes once they exist, then uncomment the
# change_scene_to_file() calls in the button handlers below.
#const CREDITS_SCENE = "res://Scenes/credits.tscn"
#const SETTINGS_SCENE = "res://Scenes/settings.tscn"


func _ready() -> void:
	# The menu is mouse driven, but give the keyboard somewhere to start.
	$Menu/StartButton.grab_focus()


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)


func _on_credits_button_pressed() -> void:
	# TODO: link to the credits scene.
	#get_tree().change_scene_to_file(CREDITS_SCENE)
	print("Credits scene not implemented yet")


func _on_settings_button_pressed() -> void:
	# TODO: link to the settings scene.
	#get_tree().change_scene_to_file(SETTINGS_SCENE)
	print("Settings scene not implemented yet")
