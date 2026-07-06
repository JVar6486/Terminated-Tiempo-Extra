extends KinematicBody

var posicion = Vector3(0,0,0)
var velocidad = 4
var golpeando = false
var currHP : float = 28
var damage : int = 1
var muerto = false
var inmunidad = false
var bloqueando : bool = false
var en_blockstun : bool = false
var vidas : int = 3
onready var immunity_timer = $ImmunityTimer
onready var hitbox_shape = $Spatial/ModeloA/Armature/Skeleton/BoneAttachment_MDer/Hitbox_MDer/CollisionShape
onready var modelo_3d = $Spatial/ModeloA

func _ready():
	$"../../CanvasLayer2/ColorRect/Label4".visible = false
	$"../../CanvasLayer2/ColorRect/Label5".visible = false
	
	immunity_timer.connect("timeout", self, "_on_ImmunityTimer_timeout")
	$"../../ControlArnol/TextureRect2".visible = true
	$"../../ControlArnol/TextureRect3".visible = false
	$"../../ControlArnol/TextureRect4".visible = false
	$"../../ControlArnol/TextureRect5".visible = false
	pass

func _physics_process(delta):
	$"../../ControlArnol/TextureRect/ProgressBarPlayer".value = currHP
	if golpeando == true:
		hitbox_shape.disabled = false
		return
	else: 

		hitbox_shape.disabled = true
	
	if muerto or en_blockstun:
		return
	
	if Input.is_action_pressed("ui_left") and Input.is_action_pressed("ui_right"):
		posicion.x = 0
		move_and_slide(posicion)
	elif Input.is_action_pressed("ui_right"):
		posicion.x = velocidad
		rotation_degrees.y = 90
		$Spatial/ModeloA/AnimationPlayer.play("Walk_Animation")
		move_and_slide(posicion)
	elif Input.is_action_pressed("ui_left"):
		posicion.x = -velocidad
		rotation_degrees.y = -90
		$Spatial/ModeloA/AnimationPlayer.play("Walk_Animation")
		move_and_slide(posicion)
	elif Input.is_action_just_pressed("ui_x"):
		atacar()
	elif Input.is_action_just_pressed("ui_c"):
		atacarPatada()
	elif Input.is_action_just_pressed("ui_z"):
		bloqueando = true
		golpeando = true
		$Spatial/ModeloA/AnimationPlayer.play("Block_Animation")
		yield(get_tree().create_timer(0.9), "timeout")
		golpeando = false
		if muerto:
			return
		else: $Spatial/ModeloA/AnimationPlayer.play("Idle_Animation")
	elif Input.is_action_just_pressed("ui_v"):
		backdash()
	else:
		posicion.x = 0
		move_and_slide(posicion)
		$Spatial/ModeloA/AnimationPlayer.play("Idle_Animation")

func atacar():
	$Spatial/ModeloA/AnimationPlayer.play("Punch_Animation")
	$"../../AudioStreamATK1".play(0.3)
	golpeando = true
	yield(get_tree().create_timer(0.9), "timeout")
	golpeando = false
	if muerto:
			return
	else: $Spatial/ModeloA/AnimationPlayer.play("Idle_Animation")

func atacarPatada():
	$Spatial/ModeloA/AnimationPlayer.play("Kick_Animation")
	$"../../AudioStreamATK2".play(0.0)
	golpeando = true
	yield(get_tree().create_timer(0.9), "timeout")
	golpeando = false
	if muerto:
			return
	else: $Spatial/ModeloA/AnimationPlayer.play("Idle_Animation")

func backdash():
	golpeando = true
	$Spatial/ModeloA/AnimationPlayer.play("JumpSide_Animation")
	var dir_dash : float = -2.0 if rotation_degrees.y > 0 else 2.0
	var t = 0.0
	while t < 0.15:
		move_and_slide(Vector3(dir_dash * 25.0, 0, 0), Vector3.UP)
		t += get_physics_process_delta_time()
		yield(get_tree(), "idle_frame")
		
	yield(get_tree().create_timer(0.5), "timeout")
	golpeando = false
	
func take_damage(damage):
	if bloqueando:
		recibir_impacto_bloqueo()
		return
	
	if inmunidad:
		return
	currHP -= damage
	$"../../ControlArnol/TextureRect/ProgressBarPlayer".value = currHP
	print("Jugador herido, HP restante: ", currHP)
	
	if currHP <= 0:
		die()
	else: activar_inmunidad()

func die():
	if vidas == 0:
		muerto = true
		print("Arnol tieso XD")
		$Spatial/ModeloA/AnimationPlayer.play("Death_Animation")
		$"../../CanvasLayer2/ColorRect/Label".visible = false
		$"../../CanvasLayer2/ColorRect/Label2".visible = false
		$"../../CanvasLayer2/ColorRect/Label3".visible = false
		$"../../AudioStreamPlayer5".play(0.0)
		$"../../CanvasLayer2/AnimationPlayer".play("Nueva Animación (2)")
		$"../../CanvasLayer2/ColorRect/Label5".visible = true
		$"../../CanvasLayer3".visible = true
		yield(get_tree().create_timer(8.0), "timeout")
		queue_free()
	else:
		vidas -= 1
		currHP = 28	
		PlayerLifes()

func PlayerLifes():
	if vidas == 0:
		$"../../ControlArnol/TextureRect2".visible = false
		$"../../ControlArnol/TextureRect3".visible = false
		$"../../ControlArnol/TextureRect4".visible = false
		$"../../ControlArnol/TextureRect5".visible = true
	elif vidas == 1:
		$"../../ControlArnol/TextureRect2".visible = false
		$"../../ControlArnol/TextureRect3".visible = false
		$"../../ControlArnol/TextureRect4".visible = true
		$"../../ControlArnol/TextureRect5".visible = false
		backdash()
	elif vidas == 2:
		$"../../ControlArnol/TextureRect2".visible = false
		$"../../ControlArnol/TextureRect3".visible = true
		$"../../ControlArnol/TextureRect4".visible = false
		$"../../ControlArnol/TextureRect5".visible = false
		backdash()
	elif vidas == 3:
		$"../../ControlArnol/TextureRect2".visible = true
		$"../../ControlArnol/TextureRect3".visible = false
		$"../../ControlArnol/TextureRect4".visible = false
		$"../../ControlArnol/TextureRect5".visible = false
		backdash()

func _on_Hurtbox_Pecho_area_entered(area):
	if inmunidad:
		return
	if "damage_golpe" in area:
		take_damage(area.damage_golpe)

func activar_inmunidad():
	en_blockstun = false
	bloqueando = false
	inmunidad = true
	immunity_timer.start()
	while inmunidad:
		if modelo_3d:
			modelo_3d.visible = !modelo_3d.visible
		yield(get_tree().create_timer(0.03), "timeout")

func _on_ImmunityTimer_timeout():
	inmunidad = false
	if modelo_3d:
		modelo_3d.visible = true

func recibir_impacto_bloqueo():
	en_blockstun = true
	
	var direccion_retroceso = -1.0 if name == "Player" else 1.0
	
	var fuerza_retroceso = 15.0
	var tiempo_retroceso = 0.2
	
	var tiempo_pasado = 0.0
	while tiempo_pasado < tiempo_retroceso:
		move_and_slide(Vector3(direccion_retroceso * fuerza_retroceso, 0, 0), Vector3.UP)
		tiempo_pasado += get_physics_process_delta_time()
		yield(get_tree(), "idle_frame") 
	en_blockstun = false
	bloqueando = false
