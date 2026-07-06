extends Button

onready var master_bus = AudioServer.get_bus_index("Master")

func _ready():
	pass


func _on_OptionsA_Button_pressed():
	var esta_mutiado = AudioServer.is_bus_mute(master_bus)
	AudioServer.set_bus_mute(master_bus, !esta_mutiado)

func _on_OptionsA_HSlider_value_changed(value):
	if value <= -40:
		AudioServer.set_bus_mute(master_bus, true)
	else:
		AudioServer.set_bus_mute(master_bus, false)
		AudioServer.set_bus_volume_db(master_bus, value)
