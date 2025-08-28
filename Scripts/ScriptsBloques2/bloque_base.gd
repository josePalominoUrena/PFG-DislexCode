extends Control
class_name BloqueBase

@export  var tipo:               TiposBloque.Tipo
@export  var nombre:             String
@onready var sprite_bloque:      NinePatchRect = $Fondo
@onready var argumento:          Control       = $ArgumentoContainer
@onready var codigo_container:   Control       = $CodigoInteriorContainer
@onready var codigo:             Control       = $CodigoInteriorContainer/BloquesCodigo
@onready var siguiente:          Control       = $Siguiente
@onready var conexion_siguiente: Area2D        = $ConexionSiguiente
@onready var conexion_argumento: Area2D        = $ConexionArgumento
@onready var conexion_interior:  Area2D        = $ConexionCodigoInterior
@onready var zona_construccion:  Control       = find_parent("ZonaConstrucción")
@onready var bloque_codigo:      VBoxContainer = find_parent("BloquesCodigo")
@onready var bloque_padre:       BloqueBase    = buscar_padre()

var drag_iniciado := false
var esta_en_lienzo: bool = false
var width :float = 212
var height :float = 42
var sprite_width :float = 212
var sprite_height :float = 42

func _ready():
	width = self.size.x
	height = self.size.y
	sprite_width = sprite_bloque.size.x
	sprite_height = sprite_bloque.size.y
	recalcula_tamano()
	zona_construccion = find_parent("ZonaConstrucción")
	bloque_codigo = find_parent("BloquesCodigo")
	bloque_padre = buscar_padre()
	
	await get_tree().process_frame
	if not zona_construccion:
		print("No se encontró ZonaConstruccion en ", nombre)
	if !esta_en_lienzo:
		return 
	if not bloque_codigo:
		print("No se encontró el bloque de código padre en ", nombre)
	if not bloque_padre:
		print("No se encontró el bloque padre en ", nombre)
	
func ejecutar(_Token:int):
	# Acción específica del bloque
	pass

func salida_mensaje(msj:String):
	if zona_construccion:
		zona_construccion.salida_mensaje(msj)

###--------------------MÉTODOS DE CONSULTA------------------------###
func buscar_padre() -> BloqueBase:
	var nodo_actual = get_parent()
	while nodo_actual != null:
		if nodo_actual is BloqueBase:
			# Verificar que sea bloque_inicio o tipo FLUJO
			if nodo_actual.tipo == TiposBloque.Tipo.INICIO or nodo_actual.tipo == TiposBloque.Tipo.FLUJO:
				return nodo_actual
		# Continuar subiendo en el árbol
		nodo_actual = nodo_actual.get_parent()
	return null

func get_siguiente() -> BloqueBase:
	if not bloque_codigo:
		#print ("No encontrado bloque_codigo en ", nombre)
		return null
	
	# Obtener la posición actual de este bloque en el container
	var mi_posicion = get_index()
	var siguiente_posicion = mi_posicion + 1
	
	# Verificar que la siguiente posición existe
	var total_hijos = bloque_codigo.get_child_count()
	if siguiente_posicion >= total_hijos:
		return null
	
	# Obtener el bloque en la siguiente posición
	var siguiente_bloque = bloque_codigo.get_child(siguiente_posicion)
	
	# Verificar que sea de tipo BloqueBase
	if siguiente_bloque is BloqueBase:
		return siguiente_bloque
	return null
	
func get_anterior() -> BloqueBase:
	if not bloque_codigo:
		return null
	
	var mi_posicion = get_index()
	var anterior_posicion = mi_posicion - 1
	
	# Verificar que no estamos en la primera posición
	if anterior_posicion < 0:
		return null
	
	var anterior_bloque = bloque_codigo.get_child(anterior_posicion)
	
	if anterior_bloque is BloqueBase:
		return anterior_bloque
	return null		
	
func get_primer_bloque_cuerpo() -> BloqueBase:
	if codigo.get_child_count() == 0:
		return null
	else:
		return codigo.get_child(0)		
		
func get_ultimo_bloque_cuerpo() -> BloqueBase:
	if codigo.get_child_count() == 0:
		return null
	else:
		return codigo.get_child(codigo.get_child_count()-1)		

func _esta_en_menu() -> bool:
	var menu_ancestor = find_parent("MenuBloques")
	return menu_ancestor != null
	
###--------------------MÉTODOS DRAG AND DROP-------------------------###

# Este método procesa eventos de mouse para detectar y ejecutar operaciones de arrastrar y soltar
# bloques desde el menú hacia el lienzo de construcción o para duplicar bloques existentes en el lienzo.
# @param event: InputEvent - El evento de entrada a procesar (mouse button o motion)
func _gui_input(event):
	if tipo == TiposBloque.Tipo.INICIO:
		return
	# Validar que zona_construccion esté disponible
	if not zona_construccion or not is_instance_valid(zona_construccion):
		push_warning("zona_construccion no está disponible en " + name)
		return
	
	# Bloquear interacciones si el robot está ejecutando código
	if zona_construccion.robot_en_movimiento():
		return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			drag_iniciado = true
			# Ejecutar operación de drag and drop al mover el mouse
			if drag_iniciado:
				#print("DRAG creando bloque")
				var bloque_copia = zona_construccion.crear_bloque(nombre)
				if not bloque_copia:
					push_warning("No se pudo crear copia del bloque: " + nombre)
					drag_iniciado = false
					pass
				else:
					# Solo crear el bloque una vez, no en cada movimiento
					if not zona_construccion.tiene_bloque_en_puente():
						# Caso 1: Bloque desde menú - añadir al lienzo
						if _esta_en_menu():
							zona_construccion.add_bloque_puente(bloque_copia)
							
						# Caso 2: Bloque en lienzo - duplicar y mover  
						elif esta_en_lienzo:
							zona_construccion.add_bloque_puente(bloque_copia)
							var bloque_puente = zona_construccion.get_bloque_puente()
							if bloque_puente:
								zona_construccion.copiar_bloque(bloque_puente, self)
							# Eliminar bloque original después de la duplicación
							eliminar_bloque(self)
						else:
							# Caso no manejado - limpiar el bloque copia creado
							push_warning("Bloque no está ni en menú ni en lienzo: " + name)
							bloque_copia.queue_free()
		if not event.pressed:
			if drag_iniciado:
				# Si había un drag activo, notificar que se soltó el botón
				drag_iniciado = false
				#print("Botón soltado - notificando a zona_construccion")
				zona_construccion.procesar_soltar_boton()	
	
###--------------------MÉTODOS AÑADIR/ELIMINAR BLOQUES----------------###
#Añade un bloque en la posición siguiente a este bloque
func add_bloque(bloque: BloqueBase) -> bool:
	if bloque != null and  bloque_codigo != null and (bloque.tipo == TiposBloque.Tipo.ACCION or bloque.tipo == TiposBloque.Tipo.FLUJO):
		bloque.esta_en_lienzo = true
		
		# Obtener la posición actual de este bloque en el container
		var mi_posicion = get_index()
		var nueva_posicion = mi_posicion + 1
		
		# Añadir el bloque al container
		bloque_codigo.add_child(bloque)
		
		# Mover a la posición correcta (reorganiza automáticamente los demás)
		bloque_codigo.move_child(bloque, nueva_posicion)
		
		# Configurar referencias del nuevo bloque
		bloque.bloque_codigo = bloque_codigo
		bloque.bloque_padre = bloque_padre
		
		if bloque.nombre != "bloque_fantasma":
			recalcula_tamano()
			bloque_padre.recalcula_tamano()
		return true
	#salida_mensaje("Suelta los bloques verdes en el argumento de un MIENTRAS o un SI")
	return false

# Método exclusivo para bloques de INICIO o FLUJO que añaden un bloque en primera posición del VboxContainer
func add_bloque_al_inicio(bloque: BloqueBase) -> bool:
	if bloque != null and (bloque.tipo == TiposBloque.Tipo.ACCION or bloque.tipo == TiposBloque.Tipo.FLUJO):
		if codigo:
			bloque.esta_en_lienzo = true
			codigo.add_child(bloque)
			codigo.move_child(bloque, 0)

			if bloque.nombre != "bloque_fantasma":
				recalcula_tamano()
			return true
	salida_mensaje("Suelta los bloques verdes sobre un MIENTRAS o un SI")
	return false

# Agregar argumento (solo si es de tipo SENSOR), 
func add_bloque_argumento(bloque: BloqueBase) -> bool:
	if self.tipo != TiposBloque.Tipo.FLUJO or argumento == null:
		return false
	if bloque.tipo == TiposBloque.Tipo.SENSOR:
		#si había un argumento lo sustituimos
		if argumento.get_child_count() > 0:
			argumento.get_child(0).queue_free()
			
		bloque.esta_en_lienzo = true
		argumento.add_child(bloque)

		if bloque.nombre != "bloque_fantasma":
			recalcula_tamano()
		return true
	salida_mensaje(bloque.nombre + " no es de tipo sensor")
	return false

func eliminar_bloque(bloque: BloqueBase):
	if is_instance_valid(bloque):
		var padre = bloque.buscar_padre()
		if padre:
			padre.padre_elimina_hijo_y_reduce(bloque)
		bloque.queue_free()
	else:
		print ("Error: en ", nombre, " no es válido el bloque")

func padre_elimina_hijo_y_reduce(hijo: BloqueBase):
	if is_instance_valid(hijo):
		# Forzar recálculo inmediato del contenedor
		codigo.remove_child(hijo)
		if hijo.nombre != "bloque_fantasma":
			recalcular_toda_jerarquia()

###--------------------MÉTODOS CAMBIO TAMAÑO--------------------------###
func recalcula_tamano():
	if self.tipo == TiposBloque.Tipo.ACCION or self.tipo == TiposBloque.Tipo.INICIO or !esta_en_lienzo:
		return
	await get_tree().process_frame

	var nuevo_ancho = width
	if argumento.visible and argumento.get_child_count() > 0:
		#print("\n\n\nCalculo de anchura en ", nombre)
		#print("Ancho original: ", nuevo_ancho, "; argumento ", argumento.get_child(0), " ancho: ", argumento.get_child(0).size.x)
		if argumento.get_child(0) is BloqueBase and self.tipo == TiposBloque.Tipo.FLUJO:
			nuevo_ancho += argumento.get_child(0).size.x
			nuevo_ancho -= 63
		else:
			nuevo_ancho += argumento.get_child(0).size.x - 35
			sprite_bloque.size.x = nuevo_ancho
			size.x = nuevo_ancho
		#print ("Nuevo ancho: ", nuevo_ancho)

	#print("\n\n\nCalculo tamaño en ", nombre)
	var nuevo_alto_sprite = 72
	var nuevo_alto_bloque = 66
	var nueva_y_siguiente = 66

	codigo.queue_sort()

	if codigo and codigo.visible and self.tipo == TiposBloque.Tipo.FLUJO:
		
		#print("Height sprite: ", size.y, "Height bloque: ", nuevo_alto_bloque, "; Código height: ", codigo_alto)
		#print("\tAltura custom: \ty->", custom_minimum_size.y)
		#print("\tAltura bloque: \to->", size.y, " \tc->", 66 )
		#print("\tAltura sprite: \to->", sprite_bloque.size.y, " \tc->", 72 )
		var codigo_alto = get_tam_codigo()
		codigo.size.y = codigo_alto 
		codigo.queue_sort()

		if self.tipo == TiposBloque.Tipo.FLUJO: 
			# Usar la altura base del bloque + altura del código como referencia fija
			nueva_y_siguiente += codigo_alto
			conexion_siguiente.position = Vector2(conexion_siguiente.position.x, nueva_y_siguiente)	
		nuevo_alto_sprite = 72 + codigo_alto -15
		nuevo_alto_bloque = 66 + codigo_alto -15
		await get_tree().process_frame
		#print("\tNuevo height_sprite: ", nuevo_alto_sprite, "\tNuevo height_bloque: ", nuevo_alto_bloque)
		
		# Aplicar el nuevo tamaño al sprite y al nodo
		if sprite_bloque:
			sprite_bloque.size = Vector2(nuevo_ancho, nuevo_alto_sprite)
			size = Vector2(nuevo_ancho, nuevo_alto_bloque)
			size.y = nuevo_alto_bloque
			custom_minimum_size = size
			# Resetear escala para evitar distorsiones
			scale = Vector2(1, 1)

		#print("\tNueva Altura custom: \ty:", custom_minimum_size.y)
		#print("\tNueva Altura bloque: \to->", size.y)
		#print("\tNueva Altura sprite: \to->", sprite_bloque.size.y)
	# Emite la señal y notifica a cascada
	call_deferred("cambio_tamano_padre")

func recalcular_toda_jerarquia():
	if fantasma_codigo != null:
		return
	# 2. Forzar recálculo del VBoxContainer
	codigo.queue_sort()
	
	# 3. Resetear y recalcular PanelContainer
	codigo_container.custom_minimum_size = Vector2.ZERO
	codigo_container.queue_sort()
	
	# 4. Resetear y recalcular BloquePadre
	custom_minimum_size = Vector2.ZERO
	
	# 5. Recalcular de nuevo después del frame
	call_deferred("recalcula_tamano")
	
func cambio_tamano_padre():
	var padre = buscar_padre()
	if padre:
		padre.call_deferred("recalcular_toda_jerarquia")
	
func get_tam_codigo() -> float:
	var codigo_alto = 0
	var _s = "Altura cod:\n     tamaños hijos de "+ nombre +": "
	for hijo in codigo.get_children():
			if hijo is BloqueBase and is_instance_valid(hijo) and hijo.nombre != "bloque_fantasma":
				#Ajustes para cada tipo de bloque
				if hijo.tipo == TiposBloque.Tipo.FLUJO:
					codigo_alto += 66 #tam flujo base
					var h_cod = hijo.get_tam_codigo()
					codigo_alto += h_cod
					_s += "66 + " + str(h_cod)  
				if hijo.tipo == TiposBloque.Tipo.ACCION:
					codigo_alto += 37 #tam accion base
					_s += " + "  + str(36)  
	codigo.size.y = codigo_alto
	_s += " = " + str(codigo_alto)
	#print (_s)
	return codigo_alto

###--------------------MÉTODOS BLOQUE FANTASMA------------------------###
#var fantasma: BloqueBase = null
var fantasma_siguente: BloqueBase = null
var fantasma_argumento: BloqueBase = null
var fantasma_codigo: BloqueBase = null

# Variables para controlar el estado
var raton_dentro_conexion = false

func _process(delta):
	if nombre == "bloque_fantasma" or !esta_en_lienzo:
		return
	var bloque_en_arrastre = false
	if zona_construccion.bloque_en_arrastre != null:
		bloque_en_arrastre = true
	
	if bloque_en_arrastre and esta_raton_en_area(conexion_siguiente):
		conexion_siguiente_mouse_entered()
		return
	else:
		await eliminar_fantasma("siguiente")
		
	if tipo == TiposBloque.Tipo.ACCION or tipo == TiposBloque.Tipo.SENSOR:
		return

	if bloque_en_arrastre and esta_raton_en_area(conexion_argumento):
		conexion_argumento_mouse_entered()
		return
	else:
		await eliminar_fantasma("argumento")
		
	if bloque_en_arrastre and esta_raton_en_area(conexion_interior):
		conexion_codigo_interior_mouse_entered()
	else:
		await eliminar_fantasma("codigo")

func esta_raton_en_area(area: Area2D) -> bool:
	if not is_instance_valid(area):
		print ("Error: area no valida")
		return false
	# Obtener el estado del espacio de física
	var space_state = get_world_2d().direct_space_state
	var mouse_pos = get_global_mouse_position()
	
	# Configurar parámetros para la consulta
	var query = PhysicsPointQueryParameters2D.new()
	query.position = mouse_pos
	query.collide_with_areas = true
	query.collide_with_bodies = false
	
	# Verificar si el mouse está sobre el área específica
	var intersections = space_state.intersect_point(query)
	var mouse_sobre_area = false
	
	for intersection in intersections:
		if intersection.collider == area:
			mouse_sobre_area = true
			break
	
	# Detectar cambios de estado
	if mouse_sobre_area and not raton_dentro_conexion:
		# Mouse ENTRÓ al área
		raton_dentro_conexion = true
		
	elif not mouse_sobre_area and raton_dentro_conexion:
		# Mouse SALIÓ del área
		raton_dentro_conexion = false

	return raton_dentro_conexion

func conexion_siguiente_mouse_entered() -> void:
	var bloque_arrastre = zona_construccion.bloque_en_arrastre
	if esta_en_lienzo and bloque_arrastre != null and bloque_arrastre.tipo != TiposBloque.Tipo.SENSOR:
		await eliminar_fantasma("siguiente")
		fantasma_siguente = zona_construccion.crear_bloque("bloque_fantasma")
		add_bloque(fantasma_siguente)

func conexion_codigo_interior_mouse_entered() -> void:
	var bloque_arrastre = zona_construccion.bloque_en_arrastre
	if esta_en_lienzo and bloque_arrastre != null and bloque_arrastre.tipo != TiposBloque.Tipo.SENSOR:
		await eliminar_fantasma("codigo")
		fantasma_codigo = zona_construccion.crear_bloque("bloque_fantasma")
		add_bloque_al_inicio(fantasma_codigo)

func conexion_argumento_mouse_entered() -> void:
	if self.tipo == TiposBloque.Tipo.SENSOR or argumento == null or argumento.get_child_count() == 1:
		return
	var bloque_arrastre = zona_construccion.bloque_en_arrastre
	if esta_en_lienzo and bloque_arrastre != null and bloque_arrastre.tipo == TiposBloque.Tipo.SENSOR:
		await eliminar_fantasma("argumento")
		fantasma_argumento = zona_construccion.crear_bloque("bloque_argumento_fantasma")
		add_bloque_argumento(fantasma_argumento)

func eliminar_fantasma(tipo:String):
	var fantasma:BloqueBase = null
	match tipo:
		"siguiente":
			if fantasma_siguente and is_instance_valid(fantasma_siguente):
				fantasma = fantasma_siguente
		"argumento":
			if fantasma_argumento and is_instance_valid(fantasma_argumento):
				fantasma = fantasma_argumento
		"codigo":
			if fantasma_codigo and is_instance_valid(fantasma_codigo):
				fantasma = fantasma_codigo
	
	if fantasma and is_instance_valid(fantasma):
		await eliminar_bloque(fantasma)
