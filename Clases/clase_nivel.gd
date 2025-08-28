class_name Nivel
extends RefCounted

var tipo_ejercicio: String
var num_nivel: int
var tam_cuadricula: int
var posicion_inicial_robot: Vector2
var num_objetivos: int
var objetivos: Array  = [] # Array de Objetivo (valor, x, y)
var solucion_ordenada: bool
var num_soluciones: int
var soluciones: Array = []  # Array de String
var bloques_permitidos: Array = []  # Array de int (0 para todos los bloques)
var colores_seguros: Array = [] #Array de String con los colores por los que puede andar el robot(0 para todos los colores)
var colores_tablero: Array = [] # Matriz de String (colores del tablero)
var descripcion_ejercicio: String
var descripcion_corta: String
var pagina_glosario: String = "sin_glosario"

func _init(file_path: String):
	cargar_nivel_csv(file_path)

func es_solucion(obj:Objetivo) -> bool:
	if soluciones.has(obj.valor):
		return true
	else:
		return false
	

#Lee la siguiente linea de un archivo y la devuelve como Array de Strings	
func siguente_linea(archivo:FileAccess) -> Array:
	var linea = archivo.get_csv_line()[0]
	return linea.split(";")
	
func cargar_nivel_csv(file_path: String):
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		print("Error: no se puedo abrir el nivel " + file_path)
		return null
	else:
		print("OK: abierto correctamente el nivel " + file_path)
	#1ª línea: indica el tipo de ejercicio (ordenar silabas, unir palabras, tutorial...)
	tipo_ejercicio = siguente_linea(file)[1]
	#2ª línea: número de nivel	
	num_nivel = int(siguente_linea(file)[1])
	#3ª línea: tamaño de cuadrícula
	#5->5x5 6-> 6x6 7->7x7
	tam_cuadricula = int(siguente_linea(file)[1])
	#4ª línea: posición inicial del robot
	var linea_pos_ini = siguente_linea(file)
	posicion_inicial_robot = Vector2(int(linea_pos_ini[1]), int(linea_pos_ini[2]))
	#5ª línea: número de objetivos
	num_objetivos = int(siguente_linea(file)[1])
	#Cargar los objetivos en un array
	for i in range(num_objetivos):
		var linea_objetivo = siguente_linea(file)
		var tipo_objetivo = linea_objetivo[0]
		var nombre_objetivo = linea_objetivo[1]
		var pos1_objetivo = int(linea_objetivo[2])
		var pos2_objetivo = int(linea_objetivo[3])
		objetivos.append(Objetivo.new(i, tipo_objetivo, nombre_objetivo, pos1_objetivo, pos2_objetivo))
	#6ª línea: Está la solución ordenada: 0->False 1->True
	if int(siguente_linea(file)[1]) == 1:
		solucion_ordenada = true
	else:
		solucion_ordenada = false	
	#7ª línea: Cuantas objetivos son solución
	num_soluciones = int(siguente_linea(file)[1])
	#Guardar las soluciones en un Array
	for i in range(num_soluciones):
		soluciones.append(siguente_linea(file)[0])
	#8ª línea: qué bloques de código están permitidos en el nivel (0 = se pueden usar todos)
	var num_bloques_permitidos = int(siguente_linea(file)[1])
	#Guardar los bloques permitidos en un Array
	for i in range(num_bloques_permitidos):
		bloques_permitidos.append(siguente_linea(file)[0])
	#9ª línea: Colores Seguros (los colores por los que puede caminar el robot sin morir)
	var n_colores_seguros = int(siguente_linea(file)[1])
	for i in range(n_colores_seguros):
		colores_seguros.append(siguente_linea(file)[0])
	#10º línea: Guardar una representación de los colores del tablero
	file.get_csv_line() #saltarse la línea de título
	for i in range(tam_cuadricula):
		colores_tablero.append([])  # Agregar una nueva fila
		var fila_colores = siguente_linea(file)
		for j in range(0,tam_cuadricula):
			colores_tablero[i].append(fila_colores[j])
	#11º línea: String con el enunciado del ejercicio
	file.get_csv_line() #saltarse la línea de título
	descripcion_ejercicio = siguente_linea(file)[0]
	#12º línea: String con un recordatorio
	file.get_csv_line() #saltarse la línea de título
	descripcion_corta = siguente_linea(file)[0]
	#13º linea: (opcional) si viene asociado con una página del glosario
	pagina_glosario = siguente_linea(file)[0]

func mostrar_informacion() -> String:
	var info_nivel := ""
	
	# Información básica
	info_nivel += "Tipo de ejercicio: %s\n" % tipo_ejercicio
	info_nivel += "Número de nivel: %d\n" % num_nivel
	info_nivel += "Tamaño de la cuadrícula: %d\n" % tam_cuadricula
	info_nivel += "Posición inicial del robot: %s\n" % str(posicion_inicial_robot)
	info_nivel += "Número de objetivos: %d\n" % num_objetivos
	info_nivel += "Enunciado ejercicio: %s\n" % descripcion_ejercicio
	info_nivel += "Recordatorio: %s\n" % descripcion_corta
	# Objetivos
	info_nivel += "Objetivos:\n"
	for obj in objetivos:
		info_nivel += " - Tipo: %s  Nombre: %s  PosX: %d  PosY: %d\n" % [obj.tipo, obj.valor, obj.x, obj.y]
	
	# Solución
	info_nivel += "Solución ordenada: %s\n" % str(solucion_ordenada)
	info_nivel += "Soluciones:\n"
	for solucion in soluciones:
		info_nivel += " - %s\n" % solucion
	# Bloques permitidos
	info_nivel += "Bloques permitidos:\n"
	if bloques_permitidos.is_empty():
		info_nivel += "  Todos los bloques están permitidos.\n"
	else:
		for bloque in bloques_permitidos:
			info_nivel += " - %s\n" % bloque
			
	# Colores seguros
	info_nivel += "Colores seguros:\n"
	if colores_seguros.is_empty():
		info_nivel += "  Todos.\n"
	else:
		pass
		for color in colores_seguros:
			info_nivel += " - %s\n" % color
	# Colores del tablero
	info_nivel += "Colores del tablero:\n"
	for fila in colores_tablero:
		info_nivel += "%s\n" % str(fila)
	return info_nivel
