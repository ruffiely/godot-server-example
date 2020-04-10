extends Node2D


var my_id
var opponent
var player_id


signal enter_queue
signal result_reported


func set_client_id(id):
	my_id = id


func send_init_with_ai():
	rpc_id(my_id, "init_ai_game")


func send_init_server(client, client_id):
	opponent = client
	rpc_id(my_id, "init_server", client_id)


func send_init_client(server, server_id):
	opponent = server
	rpc_id(my_id, "init_client", server_id)


remote func send_statistics():
	rpc_id(my_id, "retrieve_statistics", statistics.get_stats(player_id))


remote func register_player(instance_id):
	print('Client registered with ' + instance_id)
	player_id = instance_id


remote func leave_queue(option):
	pass


remote func enter_queue(option):
	emit_signal("enter_queue", self, option)


remote func report_result(won):
	emit_signal("result_reported", player_id, won)


master func relay_register_player(info):
	opponent.join_opponent(info)


func join_opponent(info):
	rpc_id(my_id, "register_player", info)
