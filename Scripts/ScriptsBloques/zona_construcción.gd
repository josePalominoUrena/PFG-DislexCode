extends Control

@onready var menu_bloques:       VBoxContainer = $PanelBloques/MenuBloques/VBoxContainer
@onready var Lienzo:             Panel         = $PanelBloques/Lienzo
@onready var bloque_inicio:      BloqueBase    = $PanelBloques/Lienzo/BloqueInicio
@onready var bloque_en_arrastre: BloqueBase    = null
@onready var control:            Control       = find_parent("Control")
@onready var puente:             Node2D        = $puente
@export  var tiempo_espera:      float         = 2.0

func _ready():
	if not control:
		print("No se encontró nodo control")
	await get_tree().process_frame

###--------------------MÉTODOS DE INTERFAZ------------------------###
func ocultar_bloques_nivel(bloques_permitidos:Array) -> void:
	var todos:bool = false
	var panel_si: MarginContainer = $PanelBloques/MenuBloques/VBoxContainer/ContainerSI
	var panel_si_no: MarginContainer = $PanelBloques/MenuBloques/VBoxContainer/ContainerSiNo
	var panel_mientras: MarginContainer = $PanelBloques/MenuBloques/VBoxContainer/ContainerMientras
	var panel_avanzar: MarginContainer = $PanelBloques/MenuBloques/VBoxContainer/ContainerAvanzar
	var panel_girar: MarginContainer = $PanelBloques/MenuBloques/VBoxContainer/ContainerGirar
	var panel_objetivo_alcanzado: MarginContainer = $PanelBloques/MenuBloques/VBoxContainer/ContainerObjetivoAlcanzado
	var panel_siguiente_color: MarginContainer = $PanelBloques/MenuBloques/VBoxContainer/ContainerSiguienteColor

	if bloques_permitidos.size() == 0:
		todos = true #dejamos todos los bloques visibles
		
	if bloques_permitidos.has("si") or todos:
		panel_si.visible = true
	else:
		panel_si.visible = false
	
	if bloques_permitidos.has("si_no") or todos:
		panel_si_no.visible = true
	else:
		panel_si_no.visible = false
			
	if bloques_permitidos.has("mientras") or todos:
		panel_mientras.visible = true
	else:
		panel_mientras.visible = false
		
	if bloques_permitidos.has("avanzar") or todos:
		panel_avanzar.visible = true
	else:
		panel_avanzar.visible = false
	
	if bloques_permitidos.has("girar") or todos:
		panel_girar.visible = true
	else:
		panel_girar.visible = false
	
	if bloques_permitidos.has("objetivo_alcanzado") or todos:
		panel_objetivo_alcanzado.visible = true
	else:
		panel_objetivo_alcanzado.visible = false
	
	if bloques_permitidos.has("siguiente_color") or todos:
		panel_siguiente_color.visible = true
	else:
		panel_siguiente_color.visible = false

func limpiar_bloques() -> void:
	bloque_inicio.borrar_hijos()
	puente.liberar()

#Papelera
func _on_button_button_down() -> void:
	limpiar_bloques()

func salida_mensaje(msj:String) -> void:
	control.salida_mensaje(msj)
###--------------------MÉTODOS DE ACCION------------------------###
func iniciar_ejecucion (Token:int) -> void:
	bloque_inicio.ejecutar(Token)

func avanzar(Token:int) -> void:
	await control.ejecutar_movimiento_robot("Avanzar", Token)

func girar(direccion:String, Token:int) -> void:
	var giro = "Girar_" + direccion
	control.ejecutar_movimiento_robot(giro, Token)

func fin_ejecucion(Token:int) -> void:
	control.ejecutar_movimiento_robot("Fin_ejecucion", Token)

func espera(bloque:String) -> void:
	if bloque == "girar":
		await get_tree().create_timer(tiempo_espera/2).timeout
	else:
		await get_tree().create_timer(tiempo_espera).timeout

func modificar_velocidad(t: float) -> void:
	tiempo_espera = t
###--------------------MÉTODOS DE CONSULTA------------------------###
func robot_en_movimiento() -> bool:
	return control.robot_en_movimiento

func get_objetivos() -> Array:
	return control.get_objetivos()

func get_objetivos_alcanzados() -> Array:
	return control.get_objetivos_alcanzados()

func get_colores() -> Array:
	return control.get_colores_tablero()

func siguiente_color() -> String:
	return control.siguiente_color()
	
func get_bloque_puente() -> BloqueBase:
	if puente.get_child_count() > 0:
		return puente.get_child(0)
	else:
		return null
###--------------------MÉTODOS DRAG AND DROP------------------------###
# Actualiza la posición del bloque en arrastre para que siga al cursor del mouse.
# @param delta: Tiempo transcurrido desde el frame anterior
func _process(_delta: float) -> void:
	if bloque_en_arrastre != null:
		bloque_en_arrastre.global_position = get_viewport().get_mouse_position()
		
		#Si hay bloque en arrastre

# Inicia el proceso de arrastre de un bloque.
# Configura el bloque como flotante, lo añade al puente temporalmente,
# @param bloque: El bloque que se va a arrastrar
func add_bloque_puente(bloque:BloqueBase) -> void:
	if bloque.nombre == "bloque_fantasma" or bloque.nombre == "bloque_argumento_fantasma":
		return
	bloque_en_arrastre = bloque

	bloque_en_arrastre.set_as_top_level(true)  # El bloque ahora es flotante, no depende del layout de su padre
	puente.add_child(bloque_en_arrastre)  # Lo añadimos al puente temporalmente
	bloque_en_arrastre.global_position = get_viewport().get_mouse_position()
	bloque_en_arrastre.modulate = Color(1, 1, 1, 0.7)   # Semitransparente para efecto de arrastre
	bloque_en_arrastre.drag_iniciado = true

# Carga y crea una instancia de un bloque basado en su nombre.
# @param nombre: Nombre del bloque a crear
# @return: Nueva instancia del bloque o null si no existe el archivo
func crear_bloque(nombre:String) -> BloqueBase:
	var ruta = "res://Escenas/Bloques2/" + nombre + ".tscn"
	if not ResourceLoader.exists(ruta):
		push_error("No existe el bloque: %s" % ruta)
		return
	var escena = load(ruta)
	var bloque = escena.instantiate()
	return bloque

# Maneja los eventos de entrada no procesados durante el arrastre.
# - Click derecho: Cancela el arrastre y elimina el bloque
# - Soltar click izquierdo: Procesa el drop del bloque en la posición actual
# @param event: Evento de entrada a procesar
func _unhandled_input(event) -> void:
	if not bloque_en_arrastre:
		return
		
	# Cancelar arrastre con click derecho
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		bloque_en_arrastre.queue_free()
		puente.liberar()
		bloque_en_arrastre = null
		return
	
	# Procesar drop SOLO al soltar el botón izquierdo (respaldo)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		#print("soltó izq en _unhandled_input (respaldo)")
		procesar_soltar_boton()

## Procesa el evento de soltar el botón durante un drag activo
func procesar_soltar_boton() -> void:
	if not bloque_en_arrastre:
		return
	#print("Procesando soltar botón desde bloque")
	# El usuario soltó el arrastre con botón izquierdo
	var posicion_global = get_viewport().get_mouse_position()
	var resultado = await _procesar_drop_bloque(posicion_global)
	if resultado:
		#print("Bloque agregado exitosamente")
		puente.liberar()
	else:
		#print("Bloque NO agregado - descartando") 
		bloque_en_arrastre.queue_free()
		puente.liberar()
	bloque_en_arrastre = null

## Verifica si hay un bloque en el puente (para evitar duplicados)
func tiene_bloque_en_puente() -> bool:
	return bloque_en_arrastre != null

# Procesa el drop del bloque arrastrado en una posición específica.
# Restaura la apariencia del bloque, busca un destino válido y ejecuta
# la acción de conexión correspondiente.
# @param posicion_global: Posición global donde se soltó el bloque
# @return: true si el drop fue exitoso, false en caso contrario
func _procesar_drop_bloque(posicion_global: Vector2) -> bool:
	#print("Procesando drop de ", bloque_en_arrastre.nombre)
	# Restaurar apariencia del bloque
	if bloque_en_arrastre:
		bloque_en_arrastre.modulate = Color(1, 1, 1, 1)
	
	# Buscar destino válido usando la nueva lógica
	var destino_info = _buscar_destino_recursivo(bloque_inicio, posicion_global)
	
	if not destino_info:
		return false
	
	var bloque_destino = destino_info.bloque
	var tipo_conexion = destino_info.tipo
	
	#print("\n\n\nbloque_en_arrastre: ", bloque_en_arrastre.nombre)
	#print("destino: ", bloque_destino.nombre)
	#print("tipo_conexion: ", tipo_conexion)
	var resultado: bool
	var nuevo_bloque = crear_bloque(bloque_en_arrastre.nombre)
	
	# Ejecutar la acción correspondiente según el tipo de conexión
	match tipo_conexion:
		"argumento":
			resultado = await bloque_destino.add_bloque_argumento(nuevo_bloque)
		"interior":
			resultado = await bloque_destino.add_bloque_al_inicio(nuevo_bloque)
		"siguiente":
			resultado = await bloque_destino.add_bloque(nuevo_bloque)
		_:
			return false
	copiar_bloque(nuevo_bloque, bloque_en_arrastre)
	return resultado

# Busca recursivamente un destino válido para el bloque arrastrado.
# @param bloque_actual: Bloque donde se está buscando el destino
# @param pos: Posición global del mouse
# @return: Dictionary con el bloque destino y tipo de conexión, vacío si no encuentra destino
func _buscar_destino_recursivo(bloque_actual: BloqueBase, pos: Vector2) -> Dictionary:
	"""Busca recursivamente el destino válido siguiendo la nueva lógica"""
	#print("buscando destino en ", bloque_actual.nombre)
	if not bloque_actual or bloque_actual == bloque_en_arrastre:
		return {}
	
	if bloque_actual.tipo == TiposBloque.Tipo.FLUJO or bloque_actual.tipo == TiposBloque.Tipo.INICIO:
		# 1. Verificar área de conexión argumento
		if bloque_actual.conexion_argumento.visible == true:
			if _verificar_area_colision(bloque_actual, "ConexionArgumento", pos):
				return {"bloque": bloque_actual, "tipo": "argumento"}
		
		# 2. Verificar área de conexión interior
		if bloque_actual.conexion_interior.visible == true:
			if _verificar_area_colision(bloque_actual, "ConexionCodigoInterior", pos):
				return {"bloque": bloque_actual, "tipo": "interior"}
			
			# 2.1. Si tiene conexión interior, explorar hijos recursivamente
			var codigo = bloque_actual.codigo
			if codigo.get_children().size() > 0:
				for hijo in codigo.get_children():
					if hijo is BloqueBase:
						var resultado = _buscar_destino_recursivo(hijo, pos)
						if not resultado.is_empty():
							return resultado
					else:
						print ("Error: hijo de ", bloque_actual.nombre, " no es un bloque")
	# 3. Verificar área de conexión siguiente
	if bloque_en_arrastre.tipo != TiposBloque.Tipo.SENSOR: 
		if bloque_actual.conexion_siguiente.visible == true:
			if _verificar_area_colision(bloque_actual, "ConexionSiguiente", pos):
				return {"bloque": bloque_actual, "tipo": "siguiente"}
	
	# Continuar con el siguiente bloque en la cadena principal
	if bloque_actual != bloque_inicio:  # Solo seguir cadena si no es el inicio, inicio no tiene siguientes
		var siguiente = bloque_actual.get_siguiente()
		if siguiente:
			return _buscar_destino_recursivo(siguiente, pos)
	
	return {}

# Verifica si la posición del mouse colisiona con un área específica de un bloque.
# @param bloque: Bloque que contiene el área a verificar
# @param nombre_area: Nombre del nodo del área de colisión
# @param pos: Posición global a verificar
# @return: true si hay colisión, false en caso contrario
func _verificar_area_colision(bloque: BloqueBase, nombre_area: String, pos: Vector2) -> bool:
	"""Verifica si la posición está dentro del área de colisión especificada"""
	
	var area = bloque.get_node(nombre_area) as Area2D
	if not area:
		print ("ERROR: No se encontró área ", nombre_area, " del bloque ", bloque.nombre)
		return false
	
	# Convertir posición global a local del área
	var local_pos = area.to_local(pos)
	
	# Verificar colisión con cada CollisionShape2D del área
	var child = area.get_child(0)
	if child is CollisionShape2D and child.shape:
		var shape_rect = child.shape.get_rect()
		var adjusted_point = local_pos - child.position
			
		if shape_rect.has_point(adjusted_point):
			#print("¡Área encontrada en bloque: ", bloque.nombre, " - tipo: ", nombre_area)
			return true
	else:
		print("Error: el hijo del área no es un CollisionShape2D o no tiene forma")
	return false


func copiar_bloque(copia:BloqueBase, original:BloqueBase):
	#print("Nombre: ", original.nombre)
	#print("N_argumento: ", original.argumento.get_child_count())
	#print("N_bloques: ", original.codigo.get_child_count())
	if original.tipo != TiposBloque.Tipo.FLUJO:
		return
	if original.argumento != null and original.argumento.get_child_count() > 0:
		copia.add_bloque_argumento(crear_bloque(original.argumento.get_child(0).nombre))
	#if original.codigo and original.codigo.visible and original.codigo.get_child_count() > 0:
		#var primero = false
		#for hijo in original.codigo.get_children():
			#var bloque = crear_bloque(hijo.nombre)
			#if !primero and hijo is BloqueBase:
				#copia.add_bloque_al_inicio(bloque)
				##if hijo.tipo == TiposBloque.Tipo.FLUJO:
					##await get_tree().process_frame
					##copiar_bloque(copia.get_primer_bloque_cuerpo(), bloque)
				#primero = true
			#elif hijo is BloqueBase:
				#copia.add_bloque(bloque)
				##if hijo.tipo == TiposBloque.Tipo.FLUJO:
					##await get_tree().process_frame
					##copiar_bloque(copia.get_ultimo_bloque_cuerpo(), bloque)
