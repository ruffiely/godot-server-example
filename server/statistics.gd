extends Node


const FILE_NAME = "user://statistics.data"
const SAVE_TIME = 30.0


var statistics_data = {}
var stats_template = { "games": 0, "won": 0, "loss": 0, "rank": 0 }
var new_entry = { "unranked": stats_template, "ranked": stats_template}
var save_timer = 0.0


func get_stats(player_id):
	if not statistics_data.has(player_id):
		return new_entry
	return statistics_data[player_id]


func _ready():
	_load_stats()


func _process(delta):
	save_timer += delta
	if save_timer > SAVE_TIME:
		save_timer = 0.0
		_save_stats()


func increase_stats(server_id, client_id, result):
	_init_stats(server_id)
	_init_stats(client_id)
	_increase_stats(server_id, result)
	_increase_stats(client_id, !result)


func _increase_stats(id, won):
	statistics_data[id].games += 1
	if won:
		statistics_data[id].won += 1
	else:
		statistics_data[id].loss +=1


func _init_stats(id):
	if not statistics_data.has(id):
		statistics_data[id] = new_entry


func _save_stats():
	var file = File.new()
	file.open(FILE_NAME, File.WRITE)
	file.store_string(to_json(statistics_data))
	file.close()


func _load_stats():
	var file = File.new()
	if file.file_exists(FILE_NAME):
		file.open(FILE_NAME, File.READ)
		var data = parse_json(file.get_as_text())
		file.close()
		if typeof(data) == TYPE_DICTIONARY:
			statistics_data = data
			print("Statistics loaded!")
		else:
			printerr("Corrupted data!")
	else:
		printerr("No saved data!")

