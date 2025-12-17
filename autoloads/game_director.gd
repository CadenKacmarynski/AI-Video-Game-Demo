class_name GameDirector
extends Node
## The "Game Director" - handles API calls and orchestrates state changes.

signal command_completed(success: bool, data: Dictionary)
signal command_failed(error: String)

const API_URL: String = "https://api.openai.com/v1/chat/completions"
const MODEL: String = "gpt-4o-mini"
const SYSTEM_PROMPT: String = """You are a Godot Game Engine API. Translate user requests into JSON.
Output keys: { "action": "spawn"|"physics"|"sky", "parameters": {...} }.

For "spawn" actions, parameters should include: { "object": "<keyword>", "position": [x, y, z], "count": <int> }
For "physics" actions, parameters should include: { "gravity": <float>, "jump_force": <float>, "speed": <float> }
For "sky" actions, parameters should include: { "color": "<hex or name>", "energy": <float> }

Respond ONLY with valid JSON. No explanations or markdown."""

var _http_request: HTTPRequest
var _api_key: String = ""


func _ready() -> void:
	_setup_http_request()
	_load_api_key()


func _setup_http_request() -> void:
	_http_request = HTTPRequest.new()
	_http_request.timeout = 30.0
	add_child(_http_request)
	_http_request.request_completed.connect(_on_request_completed)


func _load_api_key() -> void:
	# Try loading from environment variable first
	_api_key = OS.get_environment("OPENAI_API_KEY")
	
	if _api_key.is_empty():
		# Fallback: try loading from a local config file (not committed to git)
		var config_path: String = "user://openai_config.cfg"
		var config := ConfigFile.new()
		if config.load(config_path) == OK:
			_api_key = config.get_value("api", "key", "")
	
	if _api_key.is_empty():
		push_warning("GameDirector: No OpenAI API key found. Set OPENAI_API_KEY env var or create user://openai_config.cfg")


func submit_command(user_input: String) -> void:
	if _api_key.is_empty():
		push_error("GameDirector: Cannot submit command - no API key configured")
		command_failed.emit("No API key configured")
		_apply_fallback()
		return
	
	if _http_request.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		push_warning("GameDirector: Request already in progress")
		return
	
	var request_body: Dictionary = {
		"model": MODEL,
		"messages": [
			{"role": "system", "content": SYSTEM_PROMPT},
			{"role": "user", "content": user_input}
		],
		"temperature": 0.3,
		"max_tokens": 256,
		"response_format": {"type": "json_object"}
	}
	
	var json_body: String = JSON.stringify(request_body)
	var headers: PackedStringArray = [
		"Content-Type: application/json",
		"Authorization: Bearer " + _api_key
	]
	
	print("[GameDirector] Sending command: ", user_input)
	
	var error: int = _http_request.request(API_URL, headers, HTTPClient.METHOD_POST, json_body)
	if error != OK:
		push_error("GameDirector: HTTP request failed with error: ", error)
		command_failed.emit("HTTP request failed")
		_apply_fallback()


func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("GameDirector: Request failed with result: ", result)
		command_failed.emit("Request failed: " + str(result))
		_apply_fallback()
		return
	
	if response_code != 200:
		var error_text: String = body.get_string_from_utf8()
		push_error("GameDirector: API returned code ", response_code, ": ", error_text)
		command_failed.emit("API error: " + str(response_code))
		_apply_fallback()
		return
	
	var response_text: String = body.get_string_from_utf8()
	var parsed_data: Dictionary = _parse_response(response_text)
	
	if parsed_data.is_empty():
		command_failed.emit("Failed to parse response")
		_apply_fallback()
		return
	
	print("[GameDirector] Parsed response: ", JSON.stringify(parsed_data, "\t"))
	_apply_changes(parsed_data)
	command_completed.emit(true, parsed_data)


func _parse_response(response_text: String) -> Dictionary:
	var json := JSON.new()
	var parse_result: int = json.parse(response_text)
	
	if parse_result != OK:
		push_error("GameDirector: Failed to parse API response JSON")
		return {}
	
	var response: Dictionary = json.data
	
	# Extract the actual content from OpenAI's response structure
	if response.has("choices") and response["choices"].size() > 0:
		var message: Dictionary = response["choices"][0].get("message", {})
		var content: String = message.get("content", "")
		
		# Parse the inner JSON from the assistant's message
		return _parse_json(content)
	
	push_error("GameDirector: Unexpected response structure")
	return {}


func _parse_json(json_string: String) -> Dictionary:
	var json := JSON.new()
	var parse_result: int = json.parse(json_string)
	
	if parse_result != OK:
		push_error("GameDirector: Failed to parse LLM JSON content: ", json.get_error_message())
		return {}
	
	var data: Variant = json.data
	if data is Dictionary:
		return data
	
	push_error("GameDirector: LLM response is not a Dictionary")
	return {}


func _apply_changes(data: Dictionary) -> void:
	var action: String = data.get("action", "")
	var parameters: Dictionary = data.get("parameters", {})
	
	print("[GameDirector] Applying action: ", action)
	print("[GameDirector] Parameters: ", JSON.stringify(parameters, "\t"))
	
	match action:
		"spawn":
			_handle_spawn(parameters)
		"physics":
			_handle_physics(parameters)
		"sky":
			_handle_sky(parameters)
		_:
			push_warning("GameDirector: Unknown action type: ", action)


func _handle_spawn(params: Dictionary) -> void:
	# TODO: Integrate with AssetManager to instantiate objects
	print("[GameDirector] SPAWN requested:")
	print("  Object: ", params.get("object", "unknown"))
	print("  Position: ", params.get("position", [0, 0, 0]))
	print("  Count: ", params.get("count", 1))


func _handle_physics(params: Dictionary) -> void:
	# TODO: Integrate with Player and PhysicsServer
	print("[GameDirector] PHYSICS change requested:")
	if params.has("gravity"):
		print("  Gravity: ", params["gravity"])
	if params.has("jump_force"):
		print("  Jump Force: ", params["jump_force"])
	if params.has("speed"):
		print("  Speed: ", params["speed"])


func _handle_sky(params: Dictionary) -> void:
	# TODO: Integrate with EnvironmentController
	print("[GameDirector] SKY change requested:")
	if params.has("color"):
		print("  Color: ", params["color"])
	if params.has("energy"):
		print("  Energy: ", params["energy"])


func _apply_fallback() -> void:
	## Chaos Mode - apply a random pre-set change when API fails
	print("[GameDirector] API failed - activating Chaos Mode fallback!")
	
	var chaos_actions: Array[Dictionary] = [
		{"action": "physics", "parameters": {"gravity": -20.0}},
		{"action": "physics", "parameters": {"gravity": 5.0, "jump_force": 50.0}},
		{"action": "sky", "parameters": {"color": "#ff0066", "energy": 2.0}},
		{"action": "sky", "parameters": {"color": "#00ffaa", "energy": 0.5}},
	]
	
	var random_action: Dictionary = chaos_actions[randi() % chaos_actions.size()]
	print("[GameDirector] Chaos Mode selected: ", JSON.stringify(random_action))
	_apply_changes(random_action)
	command_completed.emit(false, random_action)
