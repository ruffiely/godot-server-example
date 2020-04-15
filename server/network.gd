extends Node


const MY_SERVER_PORT = 3044


var my_info
var player_info
var team
var opponent_id
var network_game = false
var results_to_report = [{"won": false}]


func set_ai_game():
	network_game = false


func set_network_game():
	network_game = true


func set_network_info(my_team):
	team = my_team


func is_network_game():
	return network_game


func get_unique_id():
	return get_tree().get_network_unique_id()


func is_server():
	return team == 0

func _get_connection():
	return get_tree().get_network_peer()

func _terminate_network():
	get_tree().set_network_peer(null)

