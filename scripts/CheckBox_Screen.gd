extends CheckBox

func _ready():
	pass

func _on_CheckBox_Screen_toggled(button_pressed):
	OS.window_fullscreen = button_pressed
