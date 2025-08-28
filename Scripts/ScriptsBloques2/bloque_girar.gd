extends BloqueBase
@onready var area_click: CollisionShape2D = $ConexionArgumento/AreaArgumento
@export  var imagen_izquierda: Texture2D
@export  var imagen_derecha: Texture2D
var girando_izquierda: bool = false

func _ready():
	super._ready() 
	# Configuración inicial
	actualizar_visual()
	# Configurar el argumento para recibir clics
	if argumento:
		argumento.mouse_filter = Control.MOUSE_FILTER_PASS
		argumento.connect("gui_input", Callable(self, "_on_argumento_gui_input"))

func ejecutar(Token:int):
	zona_construccion.girar(get_direccion(), Token)
	modulate = Color(1, 1, 1, 0.7)
	await zona_construccion.espera("girar")
	modulate = Color(1, 1, 1, 1)
	# Ejecuta el siguiente bloque conectado por debajo:
	siguiente = get_siguiente()
	if siguiente != null and zona_construccion.robot_en_movimiento():
		if siguiente.has_method("ejecutar"):
			await siguiente.ejecutar(Token)
				
func _input(event: InputEvent):
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
					cambiar_direccion()
				# Consumir el evento para evitar que se propague
				get_viewport().set_input_as_handled()
				
func cambiar_direccion():
	girando_izquierda = !girando_izquierda
	actualizar_visual()

func actualizar_visual():
	if girando_izquierda:
		sprite_bloque.texture = imagen_izquierda
	else:
		sprite_bloque.texture = imagen_derecha

	
func get_direccion() -> String:
	return "Izquierda" if girando_izquierda else "Derecha"
	
