extends KinematicBody2D
const CHAO = Vector2(0,-1)
const VELOCIDADE = 250
const GRAVIDADE = 1200
var player
var vidas
var contador_subir = 100
var pontuacao = 0
var position_subir = 0
var parar = false;

var posicao_inicial

var paradaTeto = false

var atacando = false

var item_capturado

func _ready():
	player = Vector2()
	item_capturado = false
	posicao_inicial = global_position
	
func _physics_process(delta):
	if(get_parent().jogando):
		player = move_and_slide(player, CHAO)		
		if($parar.is_colliding()):
			var collider = $parar.get_collider()
			if(collider.name == 'parede'):
				parar = true
		else:
			parar = false;
		if($identificaTeto.is_colliding()):
			if(paradaTeto == false):
				paradaTeto = true;
				player.x = 0
				player.y = 0;
				$player.playing = false
				$player.play("parado");
				if($player.flip_h):
					$player.position.x = -25
				else:
					$player.position.x = 25
			elif(atacando):
				ataque()
			else:
				if Input.is_action_pressed("atacar"):
					 atacando = true;
				elif Input.is_action_pressed("ui_right"):
					andar()
					andar_direita()
				elif Input.is_action_pressed("ui_left"):
					andar()
					andar_esquerda()
				elif $identificaTeto.get_collider().name == "troco_subir" && Input.is_action_pressed("ui_up"):
					$identificaTeto.enabled = false;
					if(position_subir != 0):
						global_position.x = position_subir
					paradaTeto = false
					contador_subir = 0
					pontuacao += 10
				else:
					player.x = 0
					player.y = 0;
					$player.playing = false
					$player.play("parado");
					if($player.flip_h):
						$player.position.x = -25
					else:
						$player.position.x = 25
		else:
			subindo()
	else:
		$player.playing = false

func perder_vida():
	contador_subir = 150
	vidas = vidas - 1
	voltar_inicio()
		
func itemCapturado():
	pontuacao += 1000
	item_capturado = true
	
func _on_Area2D_body_entered(body):
	if(body.is_in_group('Item')):
		body.capturado = true
		itemCapturado()


func _on_matarInimigo_body_entered(body):
	if(body.is_in_group('Inimigo')):
		if(atacando):
			pontuacao += 50
			body.morreu = true
		else:
			perder_vida()

func andar():
	if(!parar):
		$player.playing = true
		$player.play("andar");
	else:
		$player.playing = false
		$player.play("parado");

func andar_direita():
	player.x = 175
	$player.flip_h = false
	$player.position.x = 25
	$parar.cast_to.x = 50
	
func andar_esquerda():
	player.x = -175
	$player.flip_h = true
	$player.position.x = -25
	$parar.cast_to.x = -50
	
func ataque():
	$player.playing = true
	$player.play("atacar")
	if($player.frame ==10):
		atacando = false;
	player.x = 0
	player.y = 0;
	if($player.flip_h):
		$player.position.x = 4
	else:
		$player.position.x = -4

func subindo():
	if(position_subir != 0):
		global_position.x = position_subir
	if(contador_subir > 150):
		$identificaTeto.enabled = true
	contador_subir += 5
	$player.playing = true
	$player.play("subir");
	player.x = 0
	player.y = -VELOCIDADE
	$player.position.x = 0

func _on_Area2D_area_entered(area):
	if(area.is_in_group('subida')):
		position_subir = get_parent().positions_cipos[int(area.name)]
		
func _on_Area2D_area_exited():
	position_subir = 0
	
func voltar_inicio():
	global_position.x = posicao_inicial.x
	global_position.y = posicao_inicial.y
	position_subir = 0
