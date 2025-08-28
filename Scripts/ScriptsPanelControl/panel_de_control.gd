extends Control

@onready var control:               Control       = find_parent("Control")
@onready var boton:                 Control       = $PanelBoton/BotonEmpezar
@onready var navegacion:            Control       = $PanelNavegacion/Navegacion
@onready var pantalla:              Control       = $PanelPantalla/Pantalla
@onready var objetivos:             Control       = $PanelObjetivosAlcanzados/ObjetivosMarco

###--------------------MÉTODOS DE BOTÓN------------------------###
func reinicia_boton() -> void:
	boton.reinicia()

func _on_boton_empezar_empezar() -> void:
	control.empieza_nivel()

func _on_boton_empezar_reinciar() -> void:
	control.reinicia_nivel()

###--------------------MÉTODOS DE NAVEGACIÓN--------------------###
func actualiza_direccion(dir: DIRECCION.tipo) -> void:
	navegacion.actualiza_direccion(dir)

func actualiza_siguiente_color(color: String) -> void:
	navegacion.actualiza_siguiente_color(color)

###--------------------MÉTODOS DE PANTALLA--------------------###
func cargar_info_nivel(nivel: Nivel) -> void: 
	pantalla.cargar_info_nivel(nivel)

func mensaje(msj: String) -> void:
	pantalla.mensaje(msj)

###--------------------MÉTODOS DE OBJETIVOS--------------------###
func actualiza_objetivos(nivel: Nivel) -> void: 
	objetivos.actualiza_objetivos(nivel)
	
func objetivo_alcanzado(obj: Objetivo) -> void:
	objetivos.objetivo_alcanzado(obj)
