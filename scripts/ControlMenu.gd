extends Control

export var distancia_desplazamiento = 800
export var velocidad_suave = 10.0
var posicion_objetivo_x = 0.0

func _ready():
	posicion_objetivo_x = rect_position.x

func _process(delta):
	rect_position.x = lerp(rect_position.x, posicion_objetivo_x, velocidad_suave * delta)

func _on_Button_Opciones_pressed():
	posicion_objetivo_x -= distancia_desplazamiento
