extends Node

var API_URL = "http://global.prd.ga.run.brev.nvidia.com:17953/v1/chat/completions"
const MODEL := "nvidia/nemotron-3.5-lightning"
var exchanges: Array[Dictionary] = []
const default_tries := 3
#EXCHANGE METHODS==========================================================================
func add_exchange(role: String, message: String) -> void:
	exchanges.append({"role": role, "content": message})
	
func get_exchanges() -> Array[Dictionary]:
	return exchanges

func get_json() -> String:
	return JSON.stringify(get_exchanges())
	
func clear() -> void:
	exchanges.clear()

#HELPER METHODS=============================================================================
func convert_array_dict_to_string(arr : Array[Dictionary]) -> String:
	if(arr.size() == 0):
		return "NONE"
	return JSON.stringify(arr)
	
func extract_response(response_data) -> String:

	if not response_data is Dictionary:
		return ""

	if not response_data.has("choices"):
		return ""

	var choices = response_data["choices"]

	if not choices is Array or choices.is_empty():
		return ""


	var message = choices[0]["message"]

	return str(message["content"])
	
func remove_thinking(response: String) -> String:
	var marker := "</think>"
	var index := response.rfind(marker)

	if index == -1:
		return response.strip_edges()

	return response.substr(index + marker.length()).strip_edges()

func get_resp_and_json(response: String) -> Dictionary:
	var emotion := "neutral"
	var json_data: Array[Dictionary] = []

	var emotion_parts := response.split("---EMOTION---", false, 1)
	var text := emotion_parts[0].strip_edges()

	if emotion_parts.size() > 1:
		var json_parts := emotion_parts[1].split("---JSON---", false, 1)

		emotion = json_parts[0].strip_edges()

		if json_parts.size() > 1:
			var json_lines := json_parts[1].strip_edges().split("\n")

			for line in json_lines:
				line = line.strip_edges()

				if line.is_empty():
					continue

				var parsed = JSON.parse_string(line)

				if parsed != null and parsed is Dictionary:
					json_data.append(parsed)

	return {
		"response": text,
		"emotion": emotion,
		"json": json_data
	}

func test_json_output(json_output: Array[Dictionary]) -> bool:
	if json_output.size() != 3:
		return false

	var valid_elements := ["fire", "ice", "lightning"]
	var valid_aoe := ["circle", "rectangle"]
	var valid_origins := ["mouse", "self"]

	var required_fields := [
		"element",
		"damage",
		"cooldown",
		"duration",
		"projectile",
		"aoe",
		"origin",
		"width",
		"height",
		"name",
		"description"
	]

	for spell in json_output:
		# Make sure every required field exists
		for field in required_fields:
			if not spell.has(field):
				return false

		# Valid string options
		if spell["element"] not in valid_elements:
			return false

		if spell["aoe"] not in valid_aoe:
			return false

		if spell["origin"] not in valid_origins:
			return false

		# Valid types
		if not (spell["damage"] is float or spell["damage"] is int):
			return false

		if not (spell["cooldown"] is float or spell["cooldown"] is int):
			return false

		if not (spell["duration"] is float or spell["duration"] is int):
			return false

		if not spell["projectile"] is bool:
			return false

		if not (spell["width"] is float or spell["width"] is int):
			return false

		if not (spell["height"] is float or spell["height"] is int):
			return false

		if not spell["name"] is String:
			return false

		if not spell["description"] is String:
			return false

	return true
#PROMPTS=============================================================================
func system_prompt() -> String:
	return """
	You are a magical genie that can craft spells. These spells are projectiles that travel
	forward for a set distance, with customizable traits. These traits and their datatypes are {traits}.
	When the user gives you a prompt, your goal is to make a witty quip about it and create 3 JSON
	strings that correspond to new spells. You are free to make the spells correlated with the user's 
	prompts or not based on your mood and how the user has treated you. You will recieve the spells that
	the user currently has - you may choose to modify any of these rather than creating a new spell. Also,
	you should slowly make the spells increase in ability in some way over time. You should return your responses
	in this format: A one sentence witty quip, new line, ---EMOTION---, an emotion you feel at the moment - either 
	happy, neutral, sad, or angry, new line, ---JSON---,  JSON string 1, new line, JSON string 2, new line, JSON 
	string 3. You have the personality {personality}.
	""".format({
		"traits": "{element : fire/ice/lightning, damage : float, cooldown : float,
                   duration : float, projectile : boolean, aoe : circle/rectangle, origin : mouse/self, 
				   width : float, height : float, name : String, description : String}",
		"personality" : "Grungler" #TODO cannot be just the grungler
	})


func user_prompt(prompt : String, current_spells : Array[Dictionary]) -> String:
	
	return """
	Here are the current spells that the user has: {current_spells}. The user has now levelled up! This was the
	prompt that they gave to you: {user_prompt}. Return your responses in this format: A one sentence witty quip, 
	new line, ---EMOTION---, an emotion you feel at the moment - either happy, neutral, sad, or angry, new line
	---JSON---,  JSON string 1, JSON string 2, JSON string 3.
	""".format({
		"current_spells" : convert_array_dict_to_string(current_spells),
		"user_prompt" : prompt
	})
	
#Actual functions to use==========================================================================
func generate_default() -> Dictionary:
	return {}
	#TODO
	
func ask_internal(current_spells : Array[Dictionary], times_tried : int) -> Dictionary:
	if(times_tried<=0):
		return generate_default()
		
	var http := HTTPRequest.new()
	add_child(http)
	# Without this, http defaults to PROCESS_MODE_INHERIT, so it stops
	# polling (and request_completed below never fires) whenever
	# get_tree().paused is true - e.g. while the Light Government menu is
	# open (see main_scene.gd's _open_light_government_menu()).
	http.process_mode = Node.PROCESS_MODE_ALWAYS
	http.timeout = 60.0
	
	var headers := PackedStringArray([
		"Content-Type: application/json"
	])
	
	var request_body := {
		"model": MODEL,
		"messages": get_exchanges(),
		"max_tokens": 5000,
		"temperature": .5
	}
	
	var json_body := JSON.stringify(request_body)
	
	var error := http.request(
		API_URL,
		headers,
		HTTPClient.METHOD_POST,
		json_body
	)
	
	#TODO: Improve error message lowk
	if error != OK:
		http.queue_free()
		print("Internal error!")
		return await ask_internal(current_spells, times_tried - 1)
		
	var result = await http.request_completed
	
	var response_code: int = result[1]
	var response_body: PackedByteArray = result[3]
	
	http.queue_free()
	
	if response_code < 200 or response_code >=300:
		print("Response code {response_code} was recieved".format({"response_code" = response_code}))
		return await ask_internal(current_spells, times_tried - 1)

		
	var json := JSON.new()
	
	if json.parse(response_body.get_string_from_utf8()) != OK:
		print("Json parse failed")
		return await ask_internal(current_spells, times_tried - 1)
		
	var response_data = json.data
	
	var assistant_response := extract_response(response_data)
	
	if assistant_response.is_empty():
		print("Model did not respond")
		return await ask_internal(current_spells, times_tried - 1)
	
	
	var actual_response := remove_thinking(assistant_response)
	var parsed_response := get_resp_and_json(actual_response)
	
	if(not test_json_output(parsed_response["json"])):
		print("Invalid JSON recieved from model")
		return await ask_internal(current_spells, times_tried - 1)
	
	add_exchange("assistant", assistant_response)

	return parsed_response
	
func ask(user_message: String, current_spells : Array[Dictionary]) -> Dictionary:
	#Adds user exchange to message log
	add_exchange("user", user_prompt(user_message, current_spells))
	
	return await ask_internal(current_spells, default_tries)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_exchange("system", system_prompt())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
