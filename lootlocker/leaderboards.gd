extends Node


var session_token = ""
var score = 0

# HTTP Request node can only handle one call per node
var auth_http = HTTPRequest.new()
var leaderboard_http = HTTPRequest.new()
var submit_score_http = HTTPRequest.new()
var set_name_http = HTTPRequest.new()
var get_name_http = HTTPRequest.new()


var player_id := 0
var player_name := ""
var current_high_score := 0
var current_rank := 0

signal leaderboard_updated(new_board)
signal personal_score_updated(new_score)


func _ready():
	_authentication_request()


func _authentication_request():
	# Check if a player session has been saved
	var player_session_exists = false
	var file = FileAccess.open("res://Lootlocker/LootLocker.data", FileAccess.READ)

	var player_identifier = file.get_as_text()
	file.close()
	if(player_identifier.length() > 1):
		player_session_exists = true
		
	## Convert data to json string:
	var data = { "game_key": CustomConfig.GAME_API_KEY, "game_version": "0.0.0.1", "development_mode": CustomConfig.DEV_MODE }
	
	# If a player session already exists, send with the player identifier
	if(player_session_exists == true):
		data = { "game_key": CustomConfig.GAME_API_KEY, "player_identifier":player_identifier, "game_version": "0.0.0.1", "development_mode": CustomConfig.DEV_MODE }
	
	# Add 'Content-Type' header:
	var headers = ["Content-Type: application/json"]
	
	
	# Create a HTTPRequest node for authentication
	auth_http = HTTPRequest.new()
	add_child(auth_http)
	auth_http.request_completed.connect(_on_authentication_request_completed)
	# Send request
	auth_http.request("https://api.lootlocker.io/game/v2/session/guest", headers, HTTPClient.METHOD_POST, JSON.stringify(data))



func _on_authentication_request_completed(result, response_code, headers, body):
	var res = JSON.parse_string(body.get_string_from_utf8())
	
#	print(res)
	# Save player_identifier to file
	var file = FileAccess.open("res://Lootlocker/LootLocker.data", FileAccess.WRITE)
	file.store_string(res.player_identifier)
	file.close()
	
	# Save session_token to memory
	session_token = res.session_token
	
	player_id = res.player_id
	
	
	# Clear node
	auth_http.queue_free()
	# Get leaderboards
	_get_player_name()
	_get_leaderboards()
	# signal lootlocker connection
	Events.lootlocker_connection_established.emit()
	Events.is_lootlocker_connection_established = true
	


func _get_leaderboards():
	
	var url = "https://api.lootlocker.io/game/leaderboards/"+CustomConfig.LEADERBOARD_KEY+"/list?count=10"
	var headers = ["Content-Type: application/json", "x-session-token:"+session_token]
	
	# Create a request node for getting the highscore
	leaderboard_http = HTTPRequest.new()
	add_child(leaderboard_http)
	leaderboard_http.request_completed.connect(_on_leaderboard_request_completed)
	# Send request
	leaderboard_http.request(url, headers, HTTPClient.METHOD_GET, "")


func _on_leaderboard_request_completed(result, response_code, headers, body):
	var res = JSON.parse_string(body.get_string_from_utf8())
	
	
	# Clear node
	leaderboard_http.queue_free()
	
	
	var data = []
	for item in res.items:
		var entry = {}
		entry.rank = item.rank
		entry.id = item.member_id
		entry.name = item.player.name
		entry.score = item.score
		data.append(entry)
		if data.size() == 10:
			continue

	for item in res.items:
		if item.player.name == player_name:
			current_high_score = item.score
			current_rank = item.rank
			personal_score_updated.emit({"score":item.score, "rank": item.rank})
			continue

	leaderboard_updated.emit(data)
	
	
	


func _upload_score(score):
	var data = { "score": str(score) }
	var headers = ["Content-Type: application/json", "x-session-token:"+session_token]
	submit_score_http = HTTPRequest.new()
	add_child(submit_score_http)
	submit_score_http.request_completed.connect(_on_upload_score_request_completed)
	# Send request
	submit_score_http.request("https://api.lootlocker.io/game/leaderboards/"+CustomConfig.LEADERBOARD_KEY+"/submit", headers, HTTPClient.METHOD_POST, JSON.stringify(data))


func _on_upload_score_request_completed(result, response_code, headers, body) :
	var json = JSON.parse_string(body.get_string_from_utf8())
	
#	print("score uploaded")
	# Clear node
	Events.score_uploaded_successfully.emit()
	submit_score_http.queue_free()

func _change_player_name(new_name : String):
	
	
	# use this variable for setting the name of the player
	var player_name = new_name
	
	var data = { "name": str(player_name) }
	var url =  "https://api.lootlocker.io/game/player/name"
	var headers = ["Content-Type: application/json", "x-session-token:"+session_token]
	
	# Create a request node for getting the highscore
	set_name_http = HTTPRequest.new()
	add_child(set_name_http)
	set_name_http.request_completed.connect(_on_player_set_name_request_completed)
	# Send request
	set_name_http.request(url, headers, HTTPClient.METHOD_PATCH, JSON.stringify(data))

func _on_player_set_name_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())

	set_name_http.queue_free()

func _get_player_name():
	
	var url = "https://api.lootlocker.io/game/player/name"
	#var url = "https://api.lootlocker.io/admin/v1/game/{game_id}/players?query=" + player_id
	var headers = ["Content-Type: application/json", "x-session-token:"+session_token]
	

	# Create a request node for getting the highscore
	get_name_http = HTTPRequest.new()
	add_child(get_name_http)
	get_name_http.request_completed.connect(_on_player_get_name_request_completed)
	# Send request
	get_name_http.request(url, headers, HTTPClient.METHOD_GET, "")
	
	
func _on_player_get_name_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
#	print(json)
	player_name = json.name
