extends BloqueBase

@onready var area_click: CollisionShape2D = $ConexionArgumento/AreaClickArgumento

var colores:Array =[] # Array de Objetivo (valor, x, y)
var indice_colores_actual: int = 0
var color_actual: String = "rojo"

func _ready():
	super._ready()
	
	await get_tree().process_frame
	if argumento:
		argumento.mouse_filter = Control.MOUSE_FILTER_PASS
		argumento.connect("gui_input", Callable(self, "_on_argumento_gui_input"))
	
	inicializar_colores()
	recalcula_tamano()
	# Configurar el argumento para recibir clics


#verificar si el color de la siguiente casilla es el color_actual		
func ejecutar(Token:int) -> bool:
	var siguiente_color = zona_construccion.siguiente_color()
	#print(siguiente_color, " ", color_actual)
	modulate = Color(1, 1, 1, 0.7)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1, 1)
	if siguiente_color == color_actual:
		return true
	else:
		return false

func inicializar_colores():
	if not self.esta_en_lienzo:
		set_imagen("Base")
		return
	colores = zona_construccion.get_colores()

	if colores.size() > 0:
		indice_colores_actual = 0
		color_actual = colores[indice_colores_actual]
		set_imagen(color_actual)
		#for i in range(colores.size()):
			#print("  [%d]: %s " % [i, colores[i]])
	else:
		print("No hay colores disponibles")
	
func cambiar_siguiente_color():
	if colores.size() > 1 and self.esta_en_lienzo:
		indice_colores_actual = (indice_colores_actual + 1) % colores.size()
		color_actual = colores[indice_colores_actual]
		set_imagen(color_actual)
	else:
		set_imagen("Base")
		
func set_imagen(color:String):
	var ruta_imagen = "res://Assets/Bloques/siguiente_color_"
	match color:
		"Blanco":
			ruta_imagen += "blanco.png"
		"Verde":
			ruta_imagen += "verde.png"
		"Rojo":
			ruta_imagen += "rojo.png"
		"Negro":
			ruta_imagen += "negro.png"
		"Azul":
			ruta_imagen += "azul.png"
		"Base":
			ruta_imagen += "base.png"
		_:
			print("Error: Color no reconocido: %s" % color)
			 
	# Cargar textura y configurar propiedades de escala
	var textura = ResourceLoader.load(ruta_imagen)
	if textura:
		sprite_bloque.texture = textura
	else:
		print ("Error: No se pudo cargar la textura")
	# Configurar textura
	
	
	
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
					cambiar_siguiente_color()
				# Consumir el evento para evitar que se propague
				get_viewport().set_input_as_handled()
