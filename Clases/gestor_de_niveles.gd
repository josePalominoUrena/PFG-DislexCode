class_name GestorDeNiveles

class RegistroNivel:
	var nombre: String
	var nivel: Nivel
	var completado: bool
	func _init(n: Nivel, completado: bool = false) -> void:
		self.nombre = n.tipo_ejercicio
		self.nivel = n
		self.completado = completado

var lista_niveles: Array[RegistroNivel] =[]

#cargar niveles
#llevar indice del nivel actural
#llevar cuenta de niveles completado
#mostrar paginas del glosrario
func _ready() -> void:
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
	var lista_csv:Array[String] = buscar_niveles()
	for n in lista_csv:
		var nivel:Nivel = Nivel.new(n)
		lista_niveles.append(RegistroNivel.new(nivel, false))

func get_lista_niveles() ->  Array:
	return []
