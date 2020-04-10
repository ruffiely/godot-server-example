extends Node

const PORT = 3044
const MAX_PLAYERS = 1024

const MAX_WAITING_TIME = 15.0

onready var queue_timer = find_node("queue_timer")

var connected_clients = []
var unranked_games = []
var open_games = {}
var server


enum {
	UNRANKED,
	RANKED
}


func _ready():
	get_tree().connect("network_peer_connected", self, "_on_client_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_client_disconnected")
	server = NetworkedMultiplayerENet.new()
	server.create_server(PORT, MAX_PLAYERS)
	get_tree().set_network_peer(server)


func _process_queue():
	print("process unranked queue players: " + str(unranked_games.size()))
	for player in unranked_games:
		player.waiting_time += 1
		if player.waiting_time >= MAX_WAITING_TIME:
			_match_with_ai(player)
	while unranked_games.size() > 1:
		_match_player(unranked_games.pop_front(), unranked_games.pop_front())
	queue_timer.start(1.0)


func _match_with_ai(player):
	player.client.send_init_with_ai()
	unranked_games.erase(player)


func _match_player(player_a, player_b):
	player_a.client.send_init_server(player_b.client, player_b.id)
	player_b.client.send_init_client(player_a.client, player_a.id)
	open_games[player_a.id] = player_b.id
	#player_a.client.send_init_server()
	#print("send init server player a " + server_ip + ":" + str(server_port))
	
	# wait for server response!
	#var timer = get_tree().create_timer(3)
	#yield(timer, "timeout")
	#player_b.client.send_init_client(server_ip, server_port)
	#print("send init client player b")
	#


func _on_client_connected(id):
	print('Client ' + str(id) + ' connected to Server')
	
	var client = load("res://remote_client.tscn").instance()
	client.set_name(str(id))
	client.set_client_id(id)
	client.connect("enter_queue", self, "_on_client_want_to_enter_queue")
	client.connect("result_reported", self, "_on_result_reported")
	get_tree().get_root().add_child(client)
	connected_clients.append({"id": id, "client": client})


func _on_result_reported(player_id, won):
	for game in open_games:
		if game.server.client.player_id == player_id:
			statistics.increase_stats(game.server, game.client, won)
			open_games.erase(game)
			break
	# report stats?
	pass


func _on_client_want_to_enter_queue(client, option):
	if option == UNRANKED:
		unranked_games.append({"id": client.my_id, "client": client, "waiting_time": 0.0})


func _on_client_disconnected(id):
	print('Client ' + str(id) + ' disconnected')
	var remove = null
	for i in connected_clients.size():
		if connected_clients[i].id == id:
			remove = i
			break
	if remove != null:
		connected_clients.remove(remove)
	var node = get_tree().get_root().get_node(str(id))
	node.queue_free()


func _on_queue_timer_timeout():
	_process_queue()
