extends BloqueBase

@onready var area_click: CollisionShape2D = $ConexionArgumento/AreaClickArgumento
@onready var texto_objetivo: Label = $ArgumentoContainer/Label
@onready var imagen_objetivo: TextureRect = $ArgumentoContainer/TextureRect

#Opciones del texto del Label
@export var fuente: String ="minecraft-five-bold.otf"
@export var tamano_fuente: int = 8
@export var color_texto: Color = Color.WHITE

var objetivos:Array =[] # Array de Objetivo (valor, x, y)
var indice_objetivo_actual: int = 0
var objetivo_actual = null

func _ready():

	super._ready()
	#Esperar a que estén todos los nodos inicializados
	await get_tree().process_frame
	inicializar_objetivos()
	# Configurar el argumento para recibir clics
	if argumento:
		argumento.mouse_filter = Control.MOUSE_FILTER_PASS
		argumento.connect("gui_input", Callable(self, "_on_argumento_gui_input"))
	opciones_texto(color_texto, fuente, tamano_fuente)
	recalcula_tamano()
	
#verificar si el objetivo_actual ha sido alcanzado
#Devuelve False si NO se ha alcanzado el objetivo
func ejecutar(Token:int) -> bool:
	var objetivos_alcanzados = zona_construccion.get_objetivos_alcanzados()
	modulate = Color(1, 1, 1, 0.7)
	for i in objetivos_alcanzados:
		if i.id == objetivo_actual.id:
			print ("se ha llegado al objetivo: ", objetivo_actual.valor)
			return false
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1, 1)
	return true
		
func inicializar_objetivos():
	#No se pueden cambiar los objetivos si el bloque está en menu bloques
	if not self.esta_en_lienzo:
		return
	objetivos = zona_construccion.get_objetivos()
	if objetivos.size() > 0:
		indice_objetivo_actual = 0
		objetivo_actual = objetivos[indice_objetivo_actual]
		mostrar_objetivo(objetivo_actual)
		#print("Objetivos disponibles:")
		#for i in range(objetivos.size()):
			#print("  [%d]: %s (tipo: %s)" % [i, objetivos[i].valor, objetivos[i].tipo])
	else:
		print("No hay objetivos disponibles")

func cambiar_siguiente_objetivo():
	if objetivos.size() > 1:
		indice_objetivo_actual = (indice_objetivo_actual + 1) % objetivos.size()
		objetivo_actual = objetivos[indice_objetivo_actual]
		mostrar_objetivo(objetivo_actual)
		#print("Cambiado a objetivo: %s (índice: %d)" % [objetivo_actual.valor, indice_objetivo_actual])
			
func mostrar_objetivo(objetivo:Objetivo):
	if objetivo.tipo == "texto":
		set_label(objetivo)
	elif objetivo.tipo == "imagen":
		set_imagen(objetivo)
	await recalcula_tamano()

#Función que cambiará el texto del label
func set_label(objetivo:Objetivo):
	imagen_objetivo.visible = false
	texto_objetivo.visible = true

	texto_objetivo.text = objetivo.valor
	
	opciones_texto(color_texto, fuente, tamano_fuente)


func opciones_texto(fc: Color, f: String, fs: int):
	#Aplicar al Label
	texto_objetivo.add_theme_color_override("font_color", fc)
	texto_objetivo.add_theme_font_size_override("font_size", fs)
	"theme_override_fonts/font"
	var font = texto_objetivo.get_theme_default_font()
	# Configurar el tamaño del Label basado en el texto
	var text_size = font.get_string_size(texto_objetivo.text, HORIZONTAL_ALIGNMENT_LEFT, -1, tamano_fuente)

	# Establecer el tamaño mínimo del Label con padding
	texto_objetivo.custom_minimum_size = Vector2(text_size.x + 35, text_size.y + 8)
	argumento.custom_minimum_size = Vector2(text_size.x + 35, text_size.y + 8)

	
func set_imagen(objetivo:Objetivo):
	imagen_objetivo.visible = true
	texto_objetivo.visible = false
	# Cargar textura y configurar propiedades de escala
	imagen_objetivo.texture = ResourceLoader.load(objetivo.ruta_imagen)
	# Configurar textura
	imagen_objetivo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE


#Métodos para el menú de clicks
func _input(event: InputEvent):
	if !esta_en_lienzo:
		return
		
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = get_global_mouse_position()
		
		# Verificar si el click está dentro del área del CollisionShape2D
		if area_click and area_click.shape:
			var shape_pos = area_click.global_position
			var shape_rect = area_click.shape.get_rect()
			shape_rect.position += shape_pos
			#Click detectado en el área del bloque
			if shape_rect.has_point(mouse_pos):
				#no cambiar el bloque mientras el robot esté en movimiento
				if !zona_construccion.robot_en_movimiento():
					cambiar_siguiente_objetivo()
				# Consumir el evento para evitar que se propague
				get_viewport().set_input_as_handled()




	
