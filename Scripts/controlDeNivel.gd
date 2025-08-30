extends Control

# Referencias a los nodos

@onready var tablero:             Node2D          = $"Columna Izq/ContenedorTablero/TableroTileMap"
@onready var ZonaConstruccion:    Control         = $"Columna derecha/ZonaConstrucción"
@onready var panelControl:        Control         = $"Columna Izq/PanelDeControl"
@onready var menuNivel:           OptionButton    = $"Encabezado/SeleccionarNivel"
@onready var menuNivelCompletado: Control         = $MenuNivelCompletado
@onready var mensajeInicioNivel:  Control         = $MensajeInicioNivel
@onready var confirmacionSalir:   Control         = $confirmarcionSalir
@onready var glosario:            Control         = $Glosario

var GestorNivel:         GestorDeNiveles         = GestorDeNiveles.new()
var token_cancelacion:int = 0
var robot_en_movimiento:bool = false
var tiempo_espera = 1.0

func _ready() -> void:
	GestorNivel.registrar_niveles()
	cargar_nivel(GestorNivel.nivel_actual())
	cargar_opciones_nivel()
	_on_boton_velocidad_cambio_velocidad(1)

###--------------------MÉTODOS DE INTERFAZ------------------------###
func inicializar_panelControl() -> void:
	panelControl.actualiza_direccion(tablero.get_direccion_robot())
	panelControl.actualiza_siguiente_color(tablero.siguiente_color())
	panelControl.cargar_info_nivel(GestorNivel.nivel_actual())
	panelControl.actualiza_objetivos(GestorNivel.nivel_actual())

func actualizar_panelControl() -> void:
	panelControl.actualiza_direccion(tablero.get_direccion_robot())
	panelControl.actualiza_siguiente_color(tablero.siguiente_color())
	
func salida_mensaje(msj: String) -> void:
	panelControl.mensaje(msj)

func objetivo_alcanzado(obj:Objetivo) -> void:
	panelControl.objetivo_alcanzado(obj)

func cambiar_velocidad(tiempo:float, vel:float) -> void:
	ZonaConstruccion.modificar_velocidad(tiempo)
	tablero.cambiar_velocidad_robot(vel)

func _on_boton_velocidad_cambio_velocidad(nivel_velocidad: int) -> void:
	match nivel_velocidad:
		0:
			cambiar_velocidad(2.0, 1.0)
		1:
			cambiar_velocidad(1.0, 0.5)
		2:
			cambiar_velocidad(0.35, 0.1)

func _on_seleccionar_nivel_item_selected(index: int) -> void:
	cargar_nivel(GestorNivel.get_nivel(index))

func _on_seleccionar_robot_item_selected(index: int) -> void:
	tablero.cambiar_skin_robot(index)

func _on_seleccionar_tile_set_item_selected(index: int) -> void:
	tablero.cambiar_tile_set(index)

func _on_menu_nivel_completado_restart_requested() -> void:
	reinicia_nivel()

func _on_menu_nivel_completado_next_level_requested() -> void:
	cargar_nivel(GestorNivel.siguiente_nivel())

func _on_instrucciones_pressed() -> void:
	if mensajeInicioNivel.visible:
		mensajeInicioNivel.hide()
	else:
		mensajeInicioNivel.mostrar()

func _on_boton_salir_pressed() -> void:
	confirmacionSalir.mostrar_menu()

func _on_glosario_pressed() -> void:
	glosario.mostrar()
###--------------------MÉTODOS DE NIVELES------------------------###	
func cargar_opciones_nivel() -> void:
	menuNivel.clear()
	var lista_niveles = GestorNivel.get_lista_nombres_niveles()
	for nivel in lista_niveles:
		menuNivel.add_item(nivel)

func cargar_nivel(nuevo_nivel:Nivel) -> void:
	token_cancelacion += 1  	# Invalida cualquier ejecución anterior
	GestorNivel.registrar_niveles()
	#Si estamos cargando un nuevo nivel
	if nuevo_nivel != null:
		ZonaConstruccion.limpiar_bloques()
		panelControl.reinicia_boton()
		mensajeInicioNivel.mostrar_mensaje(nuevo_nivel.descripcion_ejercicio)
		glosario.mostrar_pagina_nombre(nuevo_nivel.pagina_glosario)
	
	tablero.configurar_nivel(nuevo_nivel)
	ZonaConstruccion.ocultar_bloques_nivel(tablero.get_bloques_permitidos())
	inicializar_panelControl()
	#liberar bloque arrastre si lo hubiera

func reinicia_nivel() -> void:
	robot_en_movimiento = false
	token_cancelacion += 1  	# Invalida cualquier ejecución anterior
	GestorNivel.registrar_niveles()
	tablero.configurar_nivel(GestorNivel.nivel_actual())
	ZonaConstruccion.ocultar_bloques_nivel(tablero.get_bloques_permitidos())
	inicializar_panelControl()

func empieza_nivel() -> void:
	token_cancelacion += 1  	# Invalida cualquier ejecución anterior
	robot_en_movimiento = true
	ZonaConstruccion.iniciar_ejecucion(token_cancelacion)

###--------------------MÉTODOS DE COMUNICACIÓN TABLERO <-> BLOQUES ------------------------###
func ejecutar_movimiento_robot (accion:String, token:int) -> void:
	
	await get_tree().process_frame
	if token != token_cancelacion or !robot_en_movimiento:
		return #cancelar ejecución
	salida_mensaje(accion)
	match accion:
		"Avanzar":
			if not tablero.siguiente_casilla_valida():
				matar_robot("Por salirse del tablero")
				return
			tablero.avanzar_robot()
			await get_tree().create_timer(tiempo_espera).timeout
		"Girar_Izquierda":
			tablero.girar_robot_izquierda()
		"Girar_Derecha":
			tablero.girar_robot_derecha()
		"Fin_ejecucion":
			if tablero.nivel_completado():
				await get_tree().process_frame
				nivel_completado()
				return
			#Si no se ha completado el nivel y nos hemos quedado sin movimientos el jugador ha perdido
			if !tablero.nivel_completado():
				matar_robot("Por agotar movimientos")
		_:
			print("Error: Movimiento no reconocido: %s" % accion)
	actualizar_panelControl()
	
	if not tablero.casilla_segura():
		matar_robot("Por entrar a una casilla no segura")
		return

	var casilla = tablero.get_casilla_actual()
	if casilla.tiene_objetivo:
		var id_obj = casilla.objetivo.id
		if tablero.es_solucion(id_obj):
			if tablero.solucion_ordenada() and !tablero.esta_objetivo_en_orden(id_obj):
				matar_robot("Por llegar a un objetivo solución en el orden incorrecto")
				return
			tablero.objetivo_alcanzado(id_obj)
			objetivo_alcanzado(tablero.get_ultimo_objetivo_alcanzado())
			salida_mensaje("objetivo alcanzado")	
		else:
			matar_robot("Por llegar a un objetivo erróneo")
			return
	if tablero.nivel_completado():
		await get_tree().process_frame
		nivel_completado()
		return
	await get_tree().create_timer(tiempo_espera).timeout

func nivel_completado() -> void:
	token_cancelacion += 1  	# Invalida cualquier ejecución anterior
	robot_en_movimiento = false
	GestorNivel.nivel_completado()
	
	salida_mensaje("ENHORABUENA: Nivel completado")	
	await get_tree().process_frame
	menuNivelCompletado.mostrar_menu("¡Nivel Completado!")
	
func matar_robot(mensaje: String) -> void:
	if not tablero.nivel_completado():
		token_cancelacion += 1  	# Invalida cualquier ejecución anterior
		tablero.matar_robot()
		robot_en_movimiento = false
		#print(mensaje)
		salida_mensaje("NIVEL FALLIDO: " + mensaje)

func get_objetivos() -> Array:
	# Si tablero es null, intentar inicializarlo
	if tablero == null:
		tablero = find_parent("Tablero")
	
	if tablero == null:
		push_error("Tablero no encontrado")
		return []
	
	return tablero.get_objetivos()

func get_objetivos_alcanzados() -> Array:
	# Si tablero es null, intentar inicializarlo
	if tablero == null:
		tablero = find_parent("Tablero")
	
	if tablero == null:
		push_error("Tablero no encontrado")
		return []
	
	return tablero.get_objetivos_alcanzados()

func get_colores_tablero() -> Array:
	if tablero == null:
		tablero = find_parent("Tablero")
	if tablero == null:
		push_error("Tablero no encontrado")
		return []
	
	return tablero.get_colores_posibles()

func siguiente_color() -> String:
	return tablero.siguiente_color()
