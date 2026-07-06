extends ColorRect

export var distancia_desplazamiento = 250
export var velocidad_suave = 10.0
var posicion_objetivo_x = 0.0
var presionado = false

func _ready():
	posicion_objetivo_x = rect_position.x

func _process(delta):
	rect_position.x = lerp(rect_position.x, posicion_objetivo_x, velocidad_suave * delta)

func _on_Button_Opciones_pressed():
	if presionado!=true:
		presionado = true
		posicion_objetivo_x -= distancia_desplazamiento
	else:
		presionado = false
		posicion_objetivo_x += distancia_desplazamiento
