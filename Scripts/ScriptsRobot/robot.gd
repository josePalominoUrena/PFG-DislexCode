extends CharacterBody2D

@onready var textura_robot: Sprite2D = $SpriteRobot
# Configuración exportable
@export var velocidad_movimiento: float = 2.0  # Segundos por casilla

# Variables internas
var posicion_actual: Vector2
var direccion_actual: DIRECCION.tipo
var tile_map_ref: TileMap
var tablero_ref: Node2D
var nivel_ref: Nivel
var tween: Tween
var num_textura: int = 0

func _ready():
	pass
	
# Inicialización 
func configurar_robot(tablero:Node2D, tile_map: TileMap, nivel: Nivel):
	if tween: tween.kill()
	tablero_ref = tablero
	tile_map_ref = tile_map
	nivel_ref = nivel
	posicion_actual = nivel.posicion_inicial_robot
	direccion_actual = nivel.direccion_inicial_robot
	actualizar_orientacion()
	
	actualizar_escala()
	centrar_en_celda(posicion_actual)
	
###--------------------MÉTODOS DE MOVIMIENTO------------------------###	
# Mover robot a una casilla destino
func mover_a_casilla(grid_destino: Vector2):
	var nueva_direccion = calcular_direccion(grid_destino)
	actualizar_orientacion(nueva_direccion)
	
	var pos_inicio = global_position
	var pos_final = tile_map_ref.to_global(tile_map_ref.map_to_local(grid_destino))
	
	crear_tween(pos_inicio, pos_final)
	posicion_actual = grid_destino

func crear_tween(_inicio: Vector2, final: Vector2):
	if tween: tween.kill()
	
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "global_position", final, velocidad_movimiento)

func girar_derecha ():
	match direccion_actual:
		DIRECCION.tipo.ARRIBA:
			direccion_actual = DIRECCION.tipo.DERECHA
		DIRECCION.tipo.ABAJO:
			direccion_actual = DIRECCION.tipo.IZQUIERDA
		DIRECCION.tipo.DERECHA:
			direccion_actual = DIRECCION.tipo.ABAJO
		DIRECCION.tipo.IZQUIERDA:
			direccion_actual = DIRECCION.tipo.ARRIBA
		_:
			print("Error: Dirección no existe", direccion_actual)
	actualizar_orientacion()
func girar_izquierda ():
	match direccion_actual:
		DIRECCION.tipo.ARRIBA:
			direccion_actual = DIRECCION.tipo.IZQUIERDA
		DIRECCION.tipo.ABAJO:
			direccion_actual = DIRECCION.tipo.DERECHA
		DIRECCION.tipo.DERECHA:
			direccion_actual = DIRECCION.tipo.ARRIBA
		DIRECCION.tipo.IZQUIERDA:
			direccion_actual = DIRECCION.tipo.ABAJO
		_:
			print("Error: Dirección no existe", direccion_actual)
	actualizar_orientacion()
# Mover robot una casilla hacia la dirección	
func avanzar () -> int:
	var casilla = posicion_actual
	match direccion_actual:
		DIRECCION.tipo.ARRIBA:
			cambiar_sprite(num_textura, "_arriba")
			casilla.y = casilla.y - 1
		DIRECCION.tipo.ABAJO:
			cambiar_sprite(num_textura, "_abajo")
			casilla.y = casilla.y + 1
		DIRECCION.tipo.DERECHA:
			cambiar_sprite(num_textura, "_derecha")
			casilla.x = casilla.x + 1
		DIRECCION.tipo.IZQUIERDA:
			cambiar_sprite(num_textura, "_izquierda")
			casilla.x = casilla.x - 1
		_:
			print("Error: Dirección no existe", direccion_actual)
	if tablero_ref.siguiente_casilla_valida ():
		mover_a_casilla(casilla)
		return 1
	else:
		return 0	

func calcular_direccion(destino: Vector2) -> DIRECCION.tipo:
	var delta = destino - posicion_actual
	if delta.x > 0: return DIRECCION.tipo.DERECHA
	if delta.x < 0: return DIRECCION.tipo.IZQUIERDA
	if delta.y > 0: return DIRECCION.tipo.ABAJO
	return DIRECCION.tipo.ARRIBA

func actualizar_orientacion(nueva_dir: DIRECCION.tipo = direccion_actual):
	direccion_actual = nueva_dir
	match direccion_actual:
		DIRECCION.tipo.ARRIBA:
			cambiar_sprite(num_textura, "_arriba")
		DIRECCION.tipo.ABAJO:
			cambiar_sprite(num_textura, "_abajo")
		DIRECCION.tipo.DERECHA:
			cambiar_sprite(num_textura, "_derecha")
		DIRECCION.tipo.IZQUIERDA:
			cambiar_sprite(num_textura, "_izquierda")


###--------------------MÉTODOS DE LA TEXTURA------------------------###	
# Cambia el sprite del robot
func cambiar_sprite(nuevo_sprite: int, direccion_sprite:String = ""):
	var ruta_sprite = "res://Assets/Robot/SpriteRobot" + str(nuevo_sprite) + direccion_sprite + ".png"
	num_textura = nuevo_sprite
	if ResourceLoader.exists(ruta_sprite):
		# Cargar nueva textura
		textura_robot.texture = ResourceLoader.load(ruta_sprite)
		if not textura_robot:
			print("Error: no se puedo abrir la textura " + ruta_sprite)
			return null
		actualizar_escala()
		centrar_en_celda(posicion_actual)
	else:
		print("Error: No se encontró el sprite ", ruta_sprite)

# Ajusta el tamaño del sprite para que esté acorde al tamaño de la casilla
func actualizar_escala() -> void:
	var porcentaje_en_celda: float = 0.9
	var N = nivel_ref.tam_cuadricula
	var cell_px = 450.0 / float(N)
	var tex = (textura_robot as Sprite2D).texture
	var s = (cell_px * porcentaje_en_celda) / float(tex.get_width())
	textura_robot.scale = Vector2(s, s)
	textura_robot.position = Vector2.ZERO

# Posicionamiento inicial
func centrar_en_celda(grid_pos: Vector2):
	var posicion_pixel = tile_map_ref.map_to_local(grid_pos)
	global_position = tile_map_ref.to_global(posicion_pixel)

func matar():
	cambiar_sprite(num_textura, "_muerto")

func victoria():
	cambiar_sprite(num_textura, "_victoria")

func sprite_victoria() -> Texture2D:
	var ruta_sprite = "res://Assets/Robot/SpriteRobot" + str(num_textura) + "_victoria.png"
	if ResourceLoader.exists(ruta_sprite):
		# Cargar nueva textura
		var texture = ResourceLoader.load(ruta_sprite)
		if not texture:
			print("Error: no se puedo abrir la textura " + ruta_sprite)
			return null
		return texture
	else:
		print("Error: No se encontró el sprite ", ruta_sprite)
		return null
