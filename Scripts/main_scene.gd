extends Node2D

const player = preload("res://Scenes/player_character.tscn")

const rectangleSpell = preload("res://Scenes/rectangle_spell.tscn")
const circleSpell = preload("res://Scenes/circle_spell.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(player.instantiate())
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if Input.is_action_just_released("ui_spell1"):
		spell_caster({"type" : "rectangle", "width" : 10, "height" : 1})
		
	if Input.is_action_just_released("ui_spell2"):
		spell_caster({"type" : "circle", "width" : 1, "height" : 1})


func spell_caster(properties: Dictionary):
	
	var spell_instance
	
	if properties["type"] == "rectangle":
		spell_instance = rectangleSpell.instantiate()
		spell_instance.position = $PlayerCharacter.position
		spell_instance.look_at(get_global_mouse_position())
		
	if properties["type"] == "circle":
		spell_instance = circleSpell.instantiate()
		spell_instance.position = get_global_mouse_position()
		
	spell_instance.scale = Vector2(int(properties["width"]), int(properties["height"]))
	
	add_child(spell_instance)
	
	print("spell cast")
