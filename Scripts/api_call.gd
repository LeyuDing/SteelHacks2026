extends Node

var API_URL = "http://global.prd.ga.run.brev.nvidia.com:17953/v1/chat/completions"
const MODEL := "nvidia/nemotron-3.5-lightning"


var exchanges: Array[Dictionary] = []
var default_tries : int = 5

func add_exchange(role: String, message: String) -> void:
	exchanges.append({"role": role, "content": message})
	
func get_exchanges() -> Array[Dictionary]:
	return exchanges

func get_json() -> String:
	return JSON.stringify(get_exchanges())
	
func clear() -> void:
	exchanges.clear()

func system_prompt() -> String:
	return """
	You are a magical genie that can craft spells. These spells are projectiles that travel
	forward for a set distance, with customizable traits. These traits and their datatypes are {traits}.
	When the user gives you a prompt, your goal is to make a witty quip about it and create 3 JSON
	strings that correspond to new spells. You are free to make the spells correlated with the user's 
	prompts or not based on your mood and how the user has treated you. You will recieve the spells that
	the user currently has - you may choose to modify any of these rather than creating a new spell. Also,
	you should slowly make the spells increase in ability in some way over time. You should return your responses
	in this format: A one sentence witty quip, new line, ---JSON---,  JSON string 1, new line, JSON string 2,
	new line, JSON string 3. You have the personality of a {personality}.
	""".format({
		"traits": "damage : int, range : int",
		"personality":"Grungler"
	})

#TODO: ADD
func user_prompt(s : String) -> String:
	
	return """
	Here are the 4 current spells that the user has: {current_spells}. The user has now levelled up! This was the
	prompt that they gave to you: {user_prompt}. Return your responses in this format: A one sentence witty quip, 
	new line, ---JSON---,  JSON string 1, JSON string 2, JSON string 3.
	""".format({
		"current_spells" : "NONE",
		"user_prompt" : s
	})
	
#TODO
func backup_default():
	return {"role": "FAILED FAILED FAILED", "response": "FAILED FAILED FAILED"}


func ask_internal(user_message: String, tries : int) -> Dictionary:
	if(tries <= 0):
		return {"role": "FAILED FAILED FAILED", "response": "FAILED FAILED FAILED"}
	
	#Adds user exchange to message log
	if(tries == 5):
		add_exchange("user", user_prompt(user_message))
	
	var http := HTTPRequest.new()
	add_child(http)
	http.timeout = 30.0
	
	var headers := PackedStringArray([
		"Content-Type: application/json"
	])
	
	var request_body := {
		"model": MODEL,
		"messages": get_exchanges(),
		"max_tokens": 10000,
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
		return {"response": "Crap the request failed"}
		
	var result = await http.request_completed
	
	var response_code: int = result[1]
	var response_body: PackedByteArray = result[3]
	
	http.queue_free()
	
	if response_code < 200 or response_code >=300:
		return {"response": "Crap the return failed {response_code}".format({"response_code" : response_code})}
		
	var json := JSON.new()
	
	if json.parse(response_body.get_string_from_utf8()) != OK:
		return {"response": "Crap the json parse failed"}
		
	var response_data = json.data
	
	var assistant_response := extract_response(response_data)
	
	if assistant_response.is_empty():
		return {"response": "Crap model did not respond"}
		
	add_exchange("assistant", assistant_response)
	var actual_response := remove_thinking(assistant_response)
	var parsed_response := get_resp_and_json(actual_response)
	
	return parsed_response
	
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
	var parts := response.split("---JSON---", false, 1)
	
	var text := parts[0].strip_edges()
	var json_data: Array[Dictionary] = []
	if parts.size() > 1:
		var json_lines := parts[1].strip_edges().split("\n")
		for line in json_lines:
			line = line.strip_edges()
			if line.is_empty():
				continue
			var parsed = JSON.parse_string(line)
			if parsed != null and parsed is Dictionary:
				json_data.append(parsed)
				
	return {"response": text, "json": json_data}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_exchange("system", system_prompt())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
