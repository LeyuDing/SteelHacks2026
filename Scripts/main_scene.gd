extends Node2D

@onready var player = $PlayerCharacter

@onready var spell1timer = $Spell1Timer
@onready var spell2timer = $Spell2Timer
@onready var spell3timer = $Spell3Timer
@onready var spell4timer = $Spell4Timer

const rectangleSpell = preload("res://Scenes/rectangle_spell.tscn")
const circleSpell = preload("res://Scenes/circle_spell.tscn")
const particle = preload("res://Scenes/particle.tscn")

# Spells are a dictionary in the following format:
# {"element" : "fire"/"ice"/"lightning"/"",
#  "damage" : float,
#  "cooldown" : float,
#  "duration" : float,
#  "projectile" : boolean,
#  "aoe" : "circle"/"rectangle",
#  "origin" : "mouse"/"self",
#  "width" : float,
#  "height" : float}

@export var spell1 = null
@export var spell2 = null
@export var spell3 = null
@export var spell4 = null

@export var exp : int = 0
var expCap = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spell1 = {"element" : "ice",
			  "damage" : 5.0,
			  "cooldown" : 1.0, 
			  "duration" : 0.1, 
			  "projectile" : false,
			  "aoe" : "rectangle", 
			  "origin" : "self", 
			  "width" : 2.0, 
			  "height" : 1.0}
	spell2 = {"element" : "fire",
			  "damage" : 1.0,
			  "cooldown" : 5.0, 
			  "duration" : 5.0, 
			  "projectile" : true,
			  "aoe" : "rectangle", 
			  "origin" : "mouse", 
			  "width" : 3.0, 
			  "height" : 10.0}	
	
	# Restart the round clock (see Scripts/game_clock.gd) so it doesn't
	# carry over elapsed time from a previous round.
	GameClock.reset()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if exp >= expCap:
		print("level up")
		expCap = 2 * expCap
		exp = 0
	
	if Input.is_action_just_released("ui_spell1") && \
	   spell1timer.time_left == 0 && \
	   spell1 != null:
		spell1timer.start(spell1["cooldown"])
		spell_caster(spell1)
		
	if Input.is_action_just_released("ui_spell2") && \
	   spell2timer.time_left == 0 && \
	   spell2 != null:
		spell2timer.start(spell2["cooldown"])
		spell_caster(spell2)
		
	if Input.is_action_just_released("ui_spell3") && \
	   spell3timer.time_left == 0 && \
	   spell3 != null:
		spell3timer.start(spell3["cooldown"])
		spell_caster(spell3)
		
	if Input.is_action_just_released("ui_spell4") && \
	   spell4timer.time_left == 0 && \
	   spell4 != null:
		spell4timer.start(spell4["cooldown"])
		spell_caster(spell4)
		

func spell_caster(properties: Dictionary):
	
	var spell_instance
	
	var particle_instance = particle.instantiate()
	var particle_emitter = particle_instance.get_node("GPUParticles2D")
	
	#aoe
	if properties["aoe"] == "rectangle":
		spell_instance = rectangleSpell.instantiate()
		spell_instance.look_at(get_global_mouse_position() - player.global_position)
	if properties["aoe"] == "circle":
		spell_instance = circleSpell.instantiate()
		
	#basic attributes
	spell_instance.element = properties["element"]
	spell_instance.damage = properties["damage"]
	spell_instance.duration = properties["duration"]
		
	spell_instance.scale = Vector2(int(properties["width"]), int(properties["height"]))
	
	#instantiation point
	if properties["origin"] == "self":
		spell_instance.position = player.position
		particle_instance.position = player.position
		
		if properties["aoe"] == "rectangle":
			var offset = properties["width"] / 2.0
			spell_instance.global_position += Vector2.RIGHT.rotated(spell_instance.rotation) * offset
			particle_instance.global_position += Vector2.RIGHT.rotated(spell_instance.rotation) * offset
		
	if properties["origin"] == "mouse":
		spell_instance.position = get_global_mouse_position()
		particle_instance.position = get_global_mouse_position()
	
	add_child(spell_instance)
	
	if properties["duration"] <= 0.5:
		particle_emitter.duration = 0.5
	else:
		particle_emitter.duration = properties["duration"]
	
	if properties["element"] == "fire":
		particle_emitter.modulate = Color.RED
	if properties["element"] == "ice":
		particle_emitter.modulate = Color.BLUE
	if properties["element"] == "lightning":
		particle_emitter.modulate = Color.PURPLE
		
	particle_instance.scale = Vector2(int(properties["width"]), int(properties["height"]))
	
	add_child(particle_instance)
