extends CharacterBody2D

@export var velocidade: float = 40.0
@export var vida: int = 1
@export var distancia_ataque: float = 10.0

var atacando := false

@onready var agente: NavigationAgent2D = $NavigationAgent2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(_delta: float) -> void:
	var jogador := get_tree().get_first_node_in_group("player") as Node2D
	if jogador == null:
		anim.stop()
		return

	# Enquanto estiver golpeando, espera a animação terminar
	if atacando:
		return

	# Se chegou perto do jogador, vira para ele e dispara a animação de ataque
	if global_position.distance_to(jogador.global_position) <= distancia_ataque:
		var lado_x := jogador.global_position.x - global_position.x
		if lado_x != 0:
			anim.flip_h = lado_x > 0
		atacar()
		return

	# Caso contrário, continua perseguindo com a animação walking
	agente.target_position = jogador.global_position
	var proximo := agente.get_next_path_position()
	var direcao := global_position.direction_to(proximo)
	
	velocity = direcao * velocidade
	move_and_slide()
	
	if direcao != Vector2.ZERO:
		anim.play("walking")
		if direcao.x != 0:
			anim.flip_h = direcao.x > 0
	else:
		anim.stop()

func atacar() -> void:
	atacando = true
	velocity = Vector2.ZERO
	anim.play("attack")
	await anim.animation_finished
	atacando = false

func levar_golpe() -> void:
	vida -= 1
	if vida <= 0:
		get_tree().current_scene.inimigo_morreu(self)
		queue_free()
