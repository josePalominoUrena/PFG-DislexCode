extends Control

@onready var contenedorObjetivos:  HBoxContainer = $HBoxContainer
@onready var PanelObjetivo:        PanelContainer = $HBoxContainer/PanelContainer

var nivel: Nivel = null
var obj: Objetivo
var n_objetivos: int

func _ready() -> void:
	n_objetivos = 0
	reiniciar_marcos()

func actualiza_objetivos(n: Nivel) -> void:
	nivel = n
	n_objetivos = 0
	reiniciar_marcos()
	for i in nivel.num_soluciones:
		duplicar_contenedores(i)
		
func reiniciar_marcos() -> void:
	for panel in contenedorObjetivos.get_children():
		if panel.visible == true:
			panel.queue_free()

		
func duplicar_contenedores(i: int) -> void:
	var flags := Node.DUPLICATE_USE_INSTANTIATION | Node.DUPLICATE_SIGNALS
	var copia = PanelObjetivo.duplicate(flags)
	copia.name = PanelObjetivo.name + "_copia_" + str(i)
	copia.visible = true
	contenedorObjetivos.add_child(copia)

func objetivo_alcanzado(objetivo:Objetivo) -> void:
	n_objetivos += 1
	var panel = contenedorObjetivos.get_child(n_objetivos)
	if objetivo.tipo == "texto":
		var label = panel.get_child(1)
		if !label:
			print("Error: no se ha encontrado nodo label")
			return
		var texto = objetivo.valor
		var font_size = calcular_tamaño_fuente(texto.length())
		print(texto.length(), " ", font_size)
		# Aplicar el tamaño usando BBCode
		label.add_theme_font_size_override("normal_font_size", font_size)
		label.text = "[center]" + texto + "[/center]"
		
	else:
		var texture = panel.get_child(2) as TextureRect
		if !texture:
			print("Error: no se ha encontrado nodo textura")
			return
		# Cargar textura y configurar visibilidad
		var imagen = ResourceLoader.load(objetivo.ruta_imagen)
				
		# Verificar que la textura se cargó correctamente
		if imagen == null:
			push_warning("No se pudo cargar la textura: " + objetivo.ruta_imagen)
			return
		
		texture.texture = imagen

func calcular_tamaño_fuente(longitud_texto: int) -> int:
	# Tamaños de fuente según rangos de longitud
	if longitud_texto <= 2:
		return 14  # Texto corto = fuente grande
	elif longitud_texto <= 3:
		return 11  # Texto medio = fuente media
	elif longitud_texto <= 4:
		return 8  # Texto largo = fuente pequeña
	elif longitud_texto <= 5:
		return 7  # Texto largo = fuente pequeña
	else:
		return 6  # Texto muy largo = fuente muy pequeña
	
