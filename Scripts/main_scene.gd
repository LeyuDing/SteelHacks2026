extends Node2D

@onready var player = $PlayerCharacter

const rectangleSpell = preload("res://Scenes/rectangle_spell.tscn")
const circleSpell = preload("res://Scenes/circle_spell.tscn")

# Spells are a dictionary in the following format:
# {"element" : "fire"/"ice"/"lightning",
#  "damage" : float,
#  "cooldown" : float,
#  "duration" : float,
#  "projectile" : boolean,
#  "aoe" : "circle"/"rectangle",
#  "origin" : "mouse"/"self",
#  "width" : float,
#  "height" : float}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if Input.is_action_just_released("ui_spell1"):
		spell_caster({"damage" : 1.0, "duration" : 10.0, "aoe" : "rectangle", "origin" : "self", "width" : 10.0, "height" : 1.0})
		
	if Input.is_action_just_released("ui_spell2"):
		spell_caster({"damage" : 1.0, "duration" : 10.0, "aoe" : "circle", "origin" : "mouse", "width" : 1.0, "height" : 1.0})
		
	if Input.is_action_just_released("ui_spell3"):
		spell_caster({"damage" : 10.0, "duration" : 0.1, "aoe" : "rectangle", "origin" : "mouse", "width" : 1.0, "height" : 2.0})
		
	if Input.is_action_just_released("ui_spell4"):
		spell_caster({"damage" : 10.0, "duration" : 0.1, "aoe" : "circle", "origin" : "self", "width" : 2.0, "height" : 2.0})
		

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
		
	spell_instance.damage = properties["damage"]
	spell_instance.duration = properties["duration"]
		
	spell_instance.scale = Vector2(int(properties["width"]), int(properties["height"]))
	
	add_child(spell_instance)
