extends CanvasLayer

func _ready():
	$".".visible = false

func _on_Button_pressed():
	get_tree().change_scene("res://Escena1.tscn")

func _on_Button2_pressed():
	get_tree().change_scene("res://Inicio.tscn")

func _on_Button3_pressed():
	get_tree().quit()
