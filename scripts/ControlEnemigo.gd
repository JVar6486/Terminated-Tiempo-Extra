extends KinematicBody

var EcurHp : int = 28
var damage : int = 1
var vidas : int = 3
var attackDist : float = 2.0
var attackRate : float = 1.0
var Modo = 1
var velocidad : float = 4
var Eposicion = Vector3(0,0,0)
export(NodePath) var ruta_jugador
var jugador : KinematicBody
var timer_ia : Timer
var immunity_timer : Timer

var golpeando : bool = false
var bloqueando : bool = false
var en_blockstun : bool = false
var inmunidad : bool = false
var muerto : bool = false

var direccion_ia : float = 0.0
var estado_defensivo : bool = false

func _ready():
	$"../../CanvasLayer2/ColorRect/Label4".visible = false
	$"../../CanvasLayer2/ColorRect/Label5".visible = false
	
	EnemyMode()
	
	$Spatial/AbelJefe/AnimationPlayer.play("Idle_Animation")
	
	timer_ia = Timer.new()
	timer_ia.wait_time = 0.4
	timer_ia.autostart = true
	add_child(timer_ia)
	timer_ia.connect("timeout", self, "_on_TimerIA_timeout")
	
	immunity_timer = Timer.new()
	immunity_timer.wait_time = 0.3
	immunity_timer.one_shot = true
	add_child(immunity_timer)
	immunity_timer.connect("timeout", self, "_on_ImmunityTimer_timeout")
	
	if ruta_jugador:
		jugador = get_node(ruta_jugador) as KinematicBody

func _physics_process(delta):
	
	$"../../CanvasLayer/Control/TextureRect/ProgressBarEnemy".value = EcurHp
	
	if muerto or en_blockstun:
		return
		
	var hitbox = $Spatial/AbelJefe/Armature/Skeleton/BoneAttachment_MDer/Hitbox_ManoDer/CollisionShape
	if hitbox:
		hitbox.disabled = !golpeando
	
	if estado_defensivo and not golpeando:
		ejecutar_bloqueo_ia()
	
	elif direccion_ia > 0 and not golpeando:
		Eposicion.x = velocidad
		rotation_degrees.y = 90
		$Spatial/AbelJefe/AnimationPlayer.play("Walk_Animation")
		move_and_slide(Eposicion)
		
	elif direccion_ia < 0 and not golpeando:
		Eposicion.x = -velocidad
		rotation_degrees.y = -90
		$Spatial/AbelJefe/AnimationPlayer.play("Walk_Animation")
		move_and_slide(Eposicion)
		
	else:
		Eposicion.x = 0
		move_and_slide(Eposicion)
		if not golpeando and not bloqueando:
			$Spatial/AbelJefe/AnimationPlayer.play("Idle_Animation")

func EnemyMode():
	if vidas == 1:
		$"../../CanvasLayer/Control/TextureRect2".visible = false
		$"../../CanvasLayer/Control/TextureRect3".visible = false
		$"../../CanvasLayer/Control/TextureRect4".visible = true
		$"../../CanvasLayer2/ColorRect/Label".visible = false
		$"../../CanvasLayer2/ColorRect/Label2".visible = false
		$"../../CanvasLayer2/ColorRect/Label3".visible = true
		$"../../AudioStreamPlayer4".play(0.0)
		$"../../CanvasLayer2/AnimationPlayer".play("Round3")
		$"../../AudioStreamPlayer2".stop()
		$"../../AudioStreamPlayer3".play(0.0)
	elif vidas == 2:
		$"../../CanvasLayer/Control/TextureRect2".visible = false
		$"../../CanvasLayer/Control/TextureRect3".visible = true
		$"../../CanvasLayer/Control/TextureRect4".visible = false
		$"../../CanvasLayer2/ColorRect/Label".visible = false
		$"../../CanvasLayer2/ColorRect/Label2".visible = true
		$"../../CanvasLayer2/ColorRect/Label3".visible = false
		$"../../AudioStreamPlayer4".play(0.0)
		$"../../CanvasLayer2/AnimationPlayer".play("Round2")
		$"../../AudioStreamPlayer".stop()
		$"../../AudioStreamPlayer2".play(0.0)
	elif vidas == 3:
		$"../../CanvasLayer/Control/TextureRect2".visible = true
		$"../../CanvasLayer/Control/TextureRect3".visible = false
		$"../../CanvasLayer/Control/TextureRect4".visible = false
		$"../../CanvasLayer2/ColorRect/Label".visible = true
		$"../../CanvasLayer2/ColorRect/Label2".visible = false
		$"../../CanvasLayer2/ColorRect/Label3".visible = false
		$"../../AudioStreamPlayer4".play(0.0)
		$"../../CanvasLayer2/AnimationPlayer".play("Round1")
		$"../../AudioStreamPlayer".play(0.0)

func _on_TimerIA_timeout():
	if muerto or en_blockstun or golpeando or not jugador:
		return
		
	var vector_distancia = jugador.global_transform.origin.x - global_transform.origin.x
	var distancia_absoluta = abs(vector_distancia)
	
	if distancia_absoluta <= attackDist:
		direccion_ia = 0.0
		
		var azar = randf()
		if azar < 0.4:
			atacar()
		elif azar < 0.7:
			atacarPatada()
		elif azar < 0.9:
			estado_defensivo = true
		else:
			backdash()
	else:
		direccion_ia = sign(vector_distancia)
func atacar():
	golpeando = true
	$Spatial/AbelJefe/AnimationPlayer.play("Punch_Animation")
	yield(get_tree().create_timer(attackRate), "timeout")
	golpeando = false

func atacarPatada():
	golpeando = true
	$Spatial/AbelJefe/AnimationPlayer.play("Kick_Animation")
	yield(get_tree().create_timer(attackRate), "timeout")
	golpeando = false

func backdash():
	golpeando = true
	$Spatial/AbelJefe/AnimationPlayer.play("JumpSide_Animation")
	var dir_dash : float = -1.0 if rotation_degrees.y > 0 else 1.0	
	var t = 0.0
	while t < 0.15:
		move_and_slide(Vector3(dir_dash * 25.0, 0, 0), Vector3.UP)
		t += get_physics_process_delta_time()
		yield(get_tree(), "idle_frame")
		
	yield(get_tree().create_timer(0.5), "timeout")
	golpeando = false

func ejecutar_bloqueo_ia():
	bloqueando = true
	golpeando = true
	$Spatial/AbelJefe/AnimationPlayer.play("Block_Animation")
	yield(get_tree().create_timer(0.9), "timeout")
	golpeando = false
	bloqueando = false
	estado_defensivo = false

func take_damage(damage):
	if inmunidad or muerto:
		return
		
	if bloqueando:
		recibir_impacto_bloqueo()
		return

	EcurHp -= damage
	$"../../CanvasLayer/Control/TextureRect/ProgressBarEnemy".value = EcurHp
	print("Enemigo herido, HP restante: ", EcurHp)
	
	if EcurHp <= 0:
		die()
	else:
		activar_inmunidad()

func die():
	if vidas == 1:
		muerto = true
		print("Jefe tieso XD")
		$Spatial/AbelJefe/AnimationPlayer.play("Death_Animation")
		$"../../CanvasLayer2/ColorRect/Label3".visible = false
		$"../../AudioStreamPlayer5".play(0.0)
		$"../../CanvasLayer2/AnimationPlayer".play("Nueva Animación")
		$"../../CanvasLayer2/ColorRect/Label4".visible = true
		$"../../CanvasLayer3".visible = true
		yield(get_tree().create_timer(8.0), "timeout")
		queue_free()
	else:
		vidas -= 1
		EcurHp = 28
		EnemyMode()
		backdash()

func activar_inmunidad():
	inmunidad = true
	immunity_timer.start()
	while inmunidad:
		if $Spatial/AbelJefe:
			$Spatial/AbelJefe.visible = !$Spatial/AbelJefe.visible
		yield(get_tree().create_timer(0.04), "timeout")

func _on_ImmunityTimer_timeout():
	inmunidad = false
	if $Spatial/AbelJefe:
		$Spatial/AbelJefe.visible = true

func recibir_impacto_bloqueo():
	en_blockstun = true
	var dir_push = 1.0 if name == "Player" else -1.0
	var t = 0.0
	while t < 0.2:
		move_and_slide(Vector3(dir_push * 15.0, 0, 0), Vector3.UP)
		t += get_physics_process_delta_time()
		yield(get_tree(), "idle_frame")
	en_blockstun = false
	bloqueando = false

func _on_Hurtbox_PechoE_area_entered(area):
	if golpeando or bloqueando or en_blockstun or inmunidad or muerto:
		return
	if "damage_golpe" in area:
		take_damage(area.damage_golpe)
