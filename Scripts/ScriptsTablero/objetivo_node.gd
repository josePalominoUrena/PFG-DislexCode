class_name ObjetivoNode
extends Node2D
var id: int
@export var tipo_objetivo: String = "texto" 
@export var valor: String = "hola"  # Ruta de imagen o valor del texto
@export var color_texto: Color = Color.WHITE
#@export var fuente: String ="Roboto-Black.ttf"
#@export var tamano_fuente: int = 24
@export var fuente: String ="minecraft-five-bold.otf"
#@export var fuente: String ="OpenDyslexic-Regular.otf"
@export var tamano_fuente: int = 15
#@export var fuente: String ="x12y16pxSolidLinker.ttf"
#@export var tamano_fuente: int = 20
var tam_tablero = 5

func _ready():
 	# Ajustar tamaño de los elementos hijos
	$TextureRect.custom_minimum_size = Vector2(100, 100) # Tamaño base de referencia
	$Label.add_theme_font_size_override("font_size", 20 * (scale.x / 1.0)) # Escalar tamaño de fuente
	
	ajustar_tamano()
	centrar_elementos()
	opciones_texto(color_texto, fuente, tamano_fuente)

func centrar_elementos():
	$TextureRect.position = -$TextureRect.size / 1.3
	$Label.position = -$Label.size / 2
	
func ajustar_tamano():

	var base_size = 70 # Tamaño base de referencia
	var textura = $TextureRect.texture
	if textura:
		var ratio = textura.get_width() / textura.get_height()
		$TextureRect.custom_minimum_size = Vector2(base_size * ratio, base_size)
	
	$Label.add_theme_font_size_override("font_size", base_size * 0.5)

func configurar_contenido(id_nuevo: int, objetivo: Objetivo, tam_cuadricula: int, _escala_padre: float):
	id = id_nuevo
	tam_tablero = tam_cuadricula
	
	if objetivo.tipo == "texto":
		tipo_objetivo = "texto"
		$Label.text =objetivo.valor 
		get_node("TextureRect").visible = false
		
	else:
		tipo_objetivo = "imagen"
		var texture_rect = get_node("TextureRect")
		var label = get_node("Label")
		
		# Cargar textura y configurar visibilidad
		texture_rect.texture = ResourceLoader.load(objetivo.ruta_imagen)
		texture_rect.visible = true
		label.visible = false
		
		# Verificar que la textura se cargó correctamente
		if texture_rect.texture == null:
			push_warning("No se pudo cargar la textura: " + objetivo.ruta_imagen)
			return
				
		# Obtener dimensiones de la textura
		var tex_size = texture_rect.texture.get_size()
		if tex_size.x <= 0.0 or tex_size.y <= 0.0:
			push_warning("Textura con dimensiones inválidas")
			return
		
		# Aplicar configuración al TextureRect
		texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED




func opciones_texto(fc: Color, f: String, fs: int):
	var font_size = calcular_tamaño_fuente($Label.text.length())
	
	#Aplicar al Label
	$Label.add_theme_color_override("font_color", fc)
	$Label.add_theme_font_size_override("font_size", font_size)
	
	# Agregar sombra
	$Label.add_theme_color_override("font_shadow_color", Color.BLACK)
	$Label.add_theme_constant_override("shadow_offset_x", 2)
	$Label.add_theme_constant_override("shadow_offset_y", 2)
	# Agregar contorno
	$Label.add_theme_color_override("font_outline_color", Color.BLACK)
	$Label.add_theme_constant_override("outline_size", 12)


func mostrar_objetivo():
	print("Tipo de objetivo: ", tipo_objetivo)
	print("Valor: ", valor)
	print("Posición: ","(", position.x, ", ", position.y, ")")

func calcular_tamaño_fuente(longitud_texto: int) -> int:
	# Tamaños de fuente según rangos de longitud
	if longitud_texto <= 2:
		return 19  # Texto corto = fuente grande
	elif longitud_texto <= 3:
		return 17  # Texto medio = fuente media
	elif longitud_texto <= 4:
		return 15  # Texto largo = fuente pequeña
	elif longitud_texto <= 5:
		return 13  # Texto largo = fuente pequeña
	else:
		return 11  # Texto muy largo = fuente muy pequeña
