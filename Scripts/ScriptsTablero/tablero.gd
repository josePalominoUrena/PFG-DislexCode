extends Node2D

@onready var tile_map: TileMap         = $TileMap
@onready var robot:    CharacterBody2D = $Robot
var nivel_actual:Nivel

#Guardamos la representación interna del tablero en una matriz de casillas
var tablero: Array = []
var objetivos_por_alcanzar: Array = []
var objetivos_alcanzados: Array = []

func configurar_nivel(nivel:Nivel) -> void:
	nivel_actual = nivel
	tablero =[]
	objetivos_por_alcanzar = []
	objetivos_alcanzados = []
	tile_map.cargar_nivel(nivel)
	configurar_tablero()
	configurar_objetivos()
	configurar_robot()

###--------------------MÉTODOS DE TABLERO------------------------###
func configurar_tablero()-> void:
	for y in nivel_actual.tam_cuadricula:
		var fila: Array = []
		for x in nivel_actual.tam_cuadricula:
			var casilla = Casilla.new(x, y, nivel_actual.colores_tablero[x][y])
			fila.append(casilla)
		tablero.append(fila)

func cambiar_tile_set (i:int) -> void:
	tile_map.cambiar_tile_set(i)

func get_color_casilla (x:int, y:int) -> String:
	return tablero[x][y].color

func get_casilla_actual() -> Casilla:
	return tablero[robot.posicion_actual.x][robot.posicion_actual.y]

func get_tam_tablero () -> int:
	return nivel_actual.tam_cuadricula

func get_bloques_permitidos() -> Array:
	return nivel_actual.bloques_permitidos

func get_colores() -> Array:
	return nivel_actual.colores_tablero

#Devuelve los distintos colores que aparezcan en el tablero
func get_colores_posibles() -> Array:
	var colores_unicos: Array = []

	for fila in tablero:
		for casilla in fila:
			if casilla != null and casilla is Casilla:
				# Verificar si el color ya existe en el array
				if not colores_unicos.has(casilla.color):
					colores_unicos.append(casilla.color)

	return colores_unicos

#Devuelve el color de la casilla siguiente
func siguiente_color() -> String:
	if not siguiente_casilla_valida():
		return "no valida"

	var sig_casilla = siguiente_casilla(robot.direccion_actual)
	return get_color_casilla(sig_casilla.x, sig_casilla.y)

func siguiente_casilla (dir:DIRECCION.tipo) -> Vector2:
	var x = robot.posicion_actual.x
	var y = robot.posicion_actual.y
	match dir:
		DIRECCION.tipo.ARRIBA:
			y = y - 1
		DIRECCION.tipo.ABAJO:
			y = y + 1
		DIRECCION.tipo.DERECHA:
			x = x + 1
		DIRECCION.tipo.IZQUIERDA:
			x = x - 1
		_:
			print("Error: Dirección no existe", dir)
	return Vector2(x,y)

#devuelve true si la casilla siguiente no se sale de los límites del tablero
func siguiente_casilla_valida () -> bool:
	var nueva_direccion = siguiente_casilla(robot.direccion_actual)
	var tam = nivel_actual.tam_cuadricula
	if nueva_direccion.x < tam && nueva_direccion.x >= 0 && nueva_direccion.y < tam && nueva_direccion.y >= 0:
		return true
	else:
		return false

#Devuel false si la casilla en la que está el robot es eliminatioria (en el caso de que las hubiera)
func casilla_segura()->bool:
	var color_casilla_actual = get_color_casilla(robot.posicion_actual.x, robot.posicion_actual.y)
	if nivel_actual.colores_seguros.has(color_casilla_actual) || nivel_actual.colores_seguros.is_empty():
		return true
	else:
		print("%s no es un color seguro." % color_casilla_actual)
		return false

###--------------------MÉTODOS DE OBJETIVOS------------------------###
func configurar_objetivos() -> void:
	for i in nivel_actual.objetivos.size():
		var obj: Objetivo = nivel_actual.objetivos[i]
		if nivel_actual.es_solucion(obj):
			objetivos_por_alcanzar.append(obj)
		tablero[obj.x][obj.y].agregar_objetivo(obj)

func get_ultimo_objetivo_alcanzado() -> Objetivo:
	var tam = objetivos_alcanzados.size()
	if tam > 0:
		return objetivos_alcanzados[tam -1]
	return null

func get_objetivos() -> Array:
	return nivel_actual.objetivos

func get_objetivos_alcanzados() -> Array:
	return objetivos_alcanzados

func es_solucion(id:int) -> bool:
	for objetivo in objetivos_por_alcanzar:
		if objetivo.id == id:
			return true
	return false

func solucion_ordenada() -> bool:
	return nivel_actual.solucion_ordenada

func esta_objetivo_en_orden(id:int) -> bool:
	if objetivos_por_alcanzar.size() > 0 && objetivos_por_alcanzar[0].id == id:
		return true
	else:
		return false

func objetivo_alcanzado(id:int):
	tile_map.quitar_objetivo(id)
	for objetivo in objetivos_por_alcanzar:
		if objetivo.id == id:
			tablero[robot.posicion_actual.x][robot.posicion_actual.y].quitar_objetivo()
			objetivos_por_alcanzar.erase(objetivo)
			objetivos_alcanzados.append(objetivo)
			return

func nivel_completado() -> bool:
	if (objetivos_por_alcanzar.size()==0):
		robot.victoria()
		return true
	else:
		return false

###--------------------MÉTODOS DE ROBOT------------------------###
func configurar_robot() -> void:
	robot.configurar_robot(self, tile_map, nivel_actual)

#devolver si el robot ha salido del tablero o si ha encontrado un objetivo
func avanzar_robot ():
	robot.avanzar()

func girar_robot_izquierda ():
	robot.girar_izquierda()

func girar_robot_derecha ():
	robot.girar_derecha()

func cambiar_velocidad_robot (vel:float):
	robot.velocidad_movimiento = vel

func matar_robot():
	print ("Robot muerto")
	robot.matar()

func cambiar_skin_robot(n_skin:int):
	robot.cambiar_sprite(n_skin)

func posicion_robot() -> Vector2:
	return robot.posicion_actual

func get_direccion_robot() -> DIRECCION.tipo:
	return robot.direccion_actual
