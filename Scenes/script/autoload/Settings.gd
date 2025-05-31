extends Node

var bgm_volume: float = 10.0
var se_volume: float = 10.0

func save():
	var config = ConfigFile.new()
	config.set_value("audio", "bgm_volume", bgm_volume)
	config.set_value("audio", "se_volume", se_volume)
	config.save("user://settings.cfg")

func load():
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		bgm_volume = config.get_value("audio", "bgm_volume", 10.0)
		se_volume = config.get_value("audio", "se_volume", 10.0)
