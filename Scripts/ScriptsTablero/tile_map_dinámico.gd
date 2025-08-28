extends TileMap

var nivel: Nivel # Almacenamos el objeto nivel
var tamano_total: int = 450  # Tamaño fijo del tablero
var cell_size: float
var tile_map_id: int = 0
# Mapeo de colores a coordenadas en el atlas
var color_atlas = {
	"Negro": Vector2i(0, 0),
	"Blanco": Vector2i(1, 0),
	"Rojo": Vector2i(2, 0),
	"Azul": Vector2i(3, 0),
	"Verde": Vector2i(4, 0),
	"Amarillo": Vector2i(5, 0)
}
func cambiar_tile_set(index:int)-> void:
	tile_map_id = index	
	pintar_celdas()
	
func cargar_nivel(nuevo_nivel:Nivel) -> void:
	nivel = nuevo_nivel
	#Limpia todas las celdas
	clear()
	#Eliminamos los objetivos anteriores
	limpiar_objetivos()
	#Ajustar el tamaño de la casilla dependiendo del número de columnas
	ajustar_escala()
	#pintamos cada casilla de su color correspondiente
	pintar_celdas()
	#añadimos los objetivos a las celdas
	agregar_objetivos()

func ajustar_escala():
	var factor_escala = 5.0 / nivel.tam_cuadricula
	scale = Vector2(factor_escala, factor_escala)

func pintar_celdas():
	for y in nivel.tam_cuadricula:
		for x in nivel.tam_cuadricula:
			var color = nivel.colores_tablero[y][x]
			if color_atlas.has(color):
				var coord = color_atlas.get(color, Vector2i(1, 0))  # Blanco si no existe
				set_cell(0, Vector2i(x, y), tile_map_id, coord)
			else:
				push_error("Color desconocido en el nivel: '%s'" % color)		

func limpiar_objetivos():
	for child in get_children():
		if child is ObjetivoNode:
			remove_child(child)
			child.queue_free()

func agregar_objetivos():
	for y in nivel.tam_cuadricula:
		for x in nivel.tam_cuadricula:
			for objetivo in nivel.objetivos:
				if objetivo.x == x && objetivo.y == y:
					anadir_objetivo(objetivo, Vector2i(x, y))
					
func anadir_objetivo( objetivo: Objetivo, grid_pos: Vector2i):
	var objetivo_scene = preload("res://Escenas/Tablero/ObjetivoNode.tscn")
	var objetivo_node = objetivo_scene.instantiate()
	# 1. Calcular tamaño real del tile
	var cell_pixel_size = (tamano_total / nivel.tam_cuadricula) * scale.x
	
	# 2. Posicionar en esquina superior izquierda del tile
	var tile_position = map_to_local(grid_pos)
	objetivo_node.position = tile_position
	
	# 3. Configuración visual
	objetivo_node.configurar_contenido(objetivo.id, objetivo, cell_pixel_size, scale.x)
	add_child(objetivo_node)

func quitar_objetivo (id:int) -> ObjetivoNode:
	for child in get_children():
		if child is ObjetivoNode:
			if (child.id == id):
				
				remove_child(child)
				return child
	return
			
