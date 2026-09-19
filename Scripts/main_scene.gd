extends Node2D

@onready var player = $PlayerCharacter

const rectangleSpell = preload("res://Scenes/rectangle_spell.tscn")
const circleSpell = preload("res://Scenes/circle_spell.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if Input.is_action_just_released("ui_spell1"):
		spell_caster({"aoe" : "rectangle", "origin" : "self", "width" : 10, "height" : 1})
		
	if Input.is_action_just_released("ui_spell2"):
		spell_caster({"aoe" : "circle", "origin" : "mouse", "width" : 1, "height" : 1})
		
	if Input.is_action_just_released("ui_spell3"):
		spell_caster({"aoe" : "rectangle", "origin" : "mouse", "width" : 1, "height" : 2})
		
	if Input.is_action_just_released("ui_spell4"):
		spell_caster({"aoe" : "circle", "origin" : "self", "width" : 2, "height" : 2})
		

func spell_caster(properties: Dictionary):
	
	var spell_instance
	
	if properties["aoe"] == "rectangle":
		spell_instance = rectangleSpell.instantiate()
		spell_instance.look_at(get_global_mouse_position() - player.global_position)
	if properties["aoe"] == "circle":
		spell_instance = circleSpell.instantiate()
	
	if properties["origin"] == "self":
		spell_instance.position = player.position
		
	if properties["origin"] == "mouse":
		spell_instance.position = get_global_mouse_position()
		
	spell_instance.scale = Vector2(int(properties["width"]), int(properties["height"]))
	
	add_child(spell_instance)
