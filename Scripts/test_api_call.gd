extends Node

# Called when the node enters the scene tree for the first time.
func _ready()->void:
	var result: Dictionary = await ApiCall.ask("Wow! You're so cool.", [])

	print("RESPONSE:")
	print(result["response"])
	print("EMOTION:")
	print(result["emotion"])
	print("\nJSON:")
	print(result["json"])
	
	result = await ApiCall.ask("Wow! You're so cool.", result["json"])

	print("RESPONSE:")
	print(result["response"])
	print("EMOTION:")
	print(result["emotion"])
	print("\nJSON:")
	print(result["json"])
	
	
	get_tree().quit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
