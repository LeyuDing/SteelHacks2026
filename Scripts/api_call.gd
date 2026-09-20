extends Node

var API_URL = "https://global.prd.ga.run.brev.nvidia.com:17953/v1/chat/completions"
const MODEL := "nvidia/nemotron-3.5-lightning"


var exchanges: Array[Dictionary] = []


func add_exchange(role: String, message: String) -> void:
	exchanges.append({"role": role, "content": message})
	
func get_exchanges() -> Array[Dictionary]:
	return exchanges

func get_json() -> String:
	return JSON.stringify(get_exchanges())
	
func clear() -> void:
	exchanges.clear()

#TODO: ADD
func system_prompt() -> String:
	return "Oogity boogity"

#TODO: ADD
func user_prompt(s : String) -> String:
	
	return "Oogity boogity"

func ask(user_message: String) -> Dictionary:
	#Adds user exchange to message log
	add_exchange("user", user_prompt(user_message))
	
	var http := HTTPRequest.new()
	add_child(http)
	
	var headers := PackedStringArray([
		"Content-Type: application/json"
	])
	
	var request_body := {
		"model": MODEL,
		"messages": get_exchanges(),
		"max_tokens": 2000,
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
		return {"response": "Crap the return failed"}
		
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
	
func remove_thinking(response : String) -> String:
	var regex = RegEx.new()
	regex.compile("(?s)<think>.*?</think>")
	return regex.sub(response, "").strip_edges()

func get_resp_and_json(response: String) -> Dictionary:
	var parts := response.split("---JSON---", false, 1)
	
	var text := parts[0].strip_edges()
	var json_data = null
	
	if parts.size() > 1:
		var json_text := parts[1].strip_edges()
		json_data = JSON.parse_string(json_text)
	return {"response": text, "json": json_data}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_exchange("system", system_prompt())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
