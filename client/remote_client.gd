extends Node2D


signal stats_received


var stats


func cancel_search(option):
	rpc_id(1, "leave_queue", option)


func retrievie_statistics():
	rpc_id(1, "send_statistics")


func search_game(option):
	rpc_id(1, "enter_queue", option)


func _ready():
	rpc_id(1, "register_player", OS.get_unique_id())
	#for report in network.results_to_report:
	#	rpc_id(1, "report_result", report.won)
	#network.results_to_report.clear()

remote func receive_leaving_queue():
	pass


remote func retrieve_statistics(stats):
	self.stats = stats
	emit_signal("stats_received", stats)


remote func init_ai_game():
	print("no opponent found start with cpu!")
	network.set_ai_game()
	_load_game() 

remote func init_server(client_id):
	print("network init server")
	network.set_network_game()
	network.set_network_info(0)
	_init_opponent(client_id)


remote func init_client(server_id):
	print("network init client")
	network.set_network_game()
	network.set_network_info(1)
	_init_opponent(server_id)


remote func _disconnect_from_lobby():
	get_tree().set_network_peer(null)


func _init_opponent(peer_id):
	print("Client connected")
	network.opponent_id = peer_id
	rpc_id(1, "relay_register_player", network.my_info)

slave func register_player(info):
	info["id"] = network.opponent_id
	network.player_info = info
	print("register player " + str(network.player_info.id) + " " + network.player_info.name + " " + str(network.player_info.main_skin))
	print("start game")
	_load_game()


func _load_game():
	get_tree().get_root().get_node("LoadingScreen").load_game()

