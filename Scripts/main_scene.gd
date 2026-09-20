extends Node2D

@onready var player = $PlayerCharacter

@onready var spell1timer = $Spell1Timer
@onready var spell2timer = $Spell2Timer
@onready var spell3timer = $Spell3Timer
@onready var spell4timer = $Spell4Timer

@onready var level_up_prompt = $UI/LevelUpPrompt
@onready var light_government_menu = $LevelUpMenu

# How long the "Press F..." prompt stays visible/hidden per blink, so a full
# on+off cycle takes 2 seconds (see the task: "flashes once every two
# seconds").
const PROMPT_FLASH_PERIOD : float = 2.0

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

@export var spell1 = {}
@export var spell2 = {}
@export var spell3 = {}
@export var spell4 = {}

func get_dict_of_spells() -> Array[Dictionary]:
	return [spell1, spell2, spell3, spell4]

# Called by the Light Government menu's slot-select screen once the player
# picks which slot a newly-chosen spell replaces.
func set_spell(index: int, spell: Dictionary) -> void:
	match index:
		0: spell1 = spell
		1: spell2 = spell
		2: spell3 = spell
		3: spell4 = spell

@export var exp : int = 0
@export var expCap : int = 1

# Levels the player has earned but not yet spent on an upgrade. Incremented
# whenever exp fills expCap; only decremented once the Light Government menu
# resolves a level (see _on_light_government_menu_resolved()).
var pending_level_ups : int = 0

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
	spell2 = {"element" : "lightning",
			  "damage" : 0.1,
			  "cooldown" : 5.0, 
			  "duration" : 5.0, 
			  "projectile" : true,
			  "aoe" : "circle", 
			  "origin" : "mouse", 
			  "width" : 3.0, 
			  "height" : 10.0}	
	
	# Restart the round clock (see Scripts/game_clock.gd) so it doesn't
	# carry over elapsed time from a previous round.
	GameClock.reset()

	level_up_prompt.visible = false
	light_government_menu.resolved.connect(_on_light_government_menu_resolved)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	if exp >= expCap:
		pending_level_ups += 1
		expCap = 2 * expCap
		exp = 0

	_update_level_up_prompt()

	if Input.is_action_just_released("ui_spell1") && \
	   spell1timer.time_left == 0 && \
	   spell1 != {}:
		spell1timer.start(spell1["cooldown"])
		spell_caster(spell1)
		
	if Input.is_action_just_released("ui_spell2") && \
	   spell2timer.time_left == 0 && \
	   spell2 != {}:
		spell2timer.start(spell2["cooldown"])
		spell_caster(spell2)
		
	if Input.is_action_just_released("ui_spell3") && \
	   spell3timer.time_left == 0 && \
	   spell3 != {}:
		spell3timer.start(spell3["cooldown"])
		spell_caster(spell3)
		
	if Input.is_action_just_released("ui_spell4") && \
	   spell4timer.time_left == 0 && \
	   spell4 != {}:
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
		particle_instance.look_at(get_global_mouse_position() - player.global_position)
	if properties["aoe"] == "circle":
		spell_instance = circleSpell.instantiate()
		spell_instance.look_at(get_global_mouse_position() - player.global_position)
		particle_instance.look_at(get_global_mouse_position() - player.global_position)
		
	#basic attributes
	spell_instance.element = properties["element"]
	spell_instance.damage = properties["damage"]
	spell_instance.duration = properties["duration"]
		
	spell_instance.scale = Vector2(int(properties["width"]), int(properties["height"]))
	
	#instantiation point
	if properties["origin"] == "self":
		spell_instance.position = player.global_position
		particle_instance.position = player.global_position
		
		if properties["aoe"] == "rectangle":
			var offset = 100
			var direction = Vector2.RIGHT.rotated(spell_instance.rotation)
			
			spell_instance.global_position += direction * offset
			particle_instance.global_position += direction * offset
		
	if properties["origin"] == "mouse":
		spell_instance.position = get_global_mouse_position()
		particle_instance.position = get_global_mouse_position()

	if properties["duration"] <= 0.5:
		particle_emitter.duration = 0.5
	else:
		particle_emitter.duration = properties["duration"]

	if properties["element"] == "fire":
		particle_emitter.modulate = Color.RED
		spell_instance.modulate = Color(1, 0, 0, 0.05)
	if properties["element"] == "ice":
		particle_emitter.modulate = Color.BLUE
		spell_instance.modulate = Color(0, 0, 1, 0.05)
	if properties["element"] == "lightning":
		particle_emitter.modulate = Color.PURPLE
		spell_instance.modulate = Color(1, 0, 1, 0.05)

	particle_instance.scale = Vector2(int(properties["width"]), int(properties["height"]))

	add_child(spell_instance)
	add_child(particle_instance)


# Blinks the "Press F..." prompt on/off every PROMPT_FLASH_PERIOD / 2
# seconds while a level up is available, and opens the Light Government menu
# when the player presses F.
func _update_level_up_prompt() -> void:
	if pending_level_ups <= 0:
		level_up_prompt.visible = false
		return

	var phase := fmod(Time.get_ticks_msec() / 1000.0, PROMPT_FLASH_PERIOD)
	level_up_prompt.visible = phase < PROMPT_FLASH_PERIOD / 2.0

	if Input.is_action_just_pressed("ui_call_light_government"):
		_open_light_government_menu()


func _open_light_government_menu() -> void:
	level_up_prompt.visible = false
	get_tree().paused = true
	light_government_menu.open()


# Called when the Light Government menu finishes (player picked an upgrade
# option). Spends one of the queued level ups; if more are queued, the
# prompt starts blinking again on the next _process() call.
func _on_light_government_menu_resolved() -> void:
	pending_level_ups -= 1
