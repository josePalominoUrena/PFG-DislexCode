class_name GestorDeNiveles

class RegistroNivel:
	var nombre: String
	var tipo: String
	var nivel: Nivel
	var completado: bool
	func _init(n: Nivel, completado: bool = false) -> void:
		self.tipo = n.tipo_ejercicio
		self.nombre = n.nombre
		self.nivel = n
		self.completado = completado

var lista_niveles: Array[RegistroNivel] =[]
var indice_nivel_actual: int 
#cargar niveles
#llevar indice del nivel actural
#llevar cuenta de niveles completado
#mostrar paginas del glosrario
func _ready() -> void:
	indice_nivel_actual = 0
	registrar_niveles()
	
func buscar_niveles() -> Array:
	var archivos_csv: Array = []
	var carpeta_niveles = "res://Niveles/"
	
	var dir = DirAccess.open(carpeta_niveles)
	if dir == null:
		print("Error: No se pudo abrir la carpeta ", carpeta_niveles)
		return archivos_csv
	
	dir.list_dir_begin()
	var nombre_archivo = dir.get_next()
	
	while nombre_archivo != "":
		if not dir.current_is_dir() and nombre_archivo.ends_with(".csv"):
			# Agrega la ruta completa
			archivos_csv.append(carpeta_niveles + nombre_archivo)
		nombre_archivo = dir.get_next()
	dir.list_dir_end()
	return archivos_csv

func registrar_niveles():
	lista_niveles = []
	var lista_csv:Array = buscar_niveles()
	var num:int = 0
	for n in lista_csv:
		var nivel:Nivel = Nivel.new(n, num)
		lista_niveles.append(RegistroNivel.new(nivel, false))
		num += 1

func get_lista_niveles() ->  Array:
	return lista_niveles

func get_lista_nombres_niveles() ->  Array:
	var nombres:Array[String] =[]
	for nivel in lista_niveles:
		# Convierte "Nivel0" a "Nivel 0"
		var nombre = str(nivel.nivel.num_nivel) + " " + nivel.tipo + " " + nivel.nombre
		nombres.append(nombre)
	return nombres
	
func nivel_actual() -> Nivel:
	if lista_niveles[indice_nivel_actual].nivel:
		return lista_niveles[indice_nivel_actual].nivel
	else:
		print ("Error: GestorDeNivel, nivel_actual()")
		return null

func siguiente_nivel() -> Nivel:
	indice_nivel_actual = (indice_nivel_actual + 1) %  lista_niveles.size()
	if lista_niveles[indice_nivel_actual].nivel:
		return lista_niveles[indice_nivel_actual].nivel
	else:
		print ("Error: GestorDeNivel, siguiente_nivel(), ", indice_nivel_actual )
		return null

func get_nivel(indice:int) -> Nivel:
	indice_nivel_actual = indice
	if lista_niveles[indice_nivel_actual].nivel:
		return lista_niveles[indice_nivel_actual].nivel
	else:
		print ("Error: GestorDeNivel, get_nivel()")
		return null
	
func nivel_completado():
	lista_niveles[indice_nivel_actual].completado = true
