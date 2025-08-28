extends Control

signal empezar
signal reinciar

@onready var boton:              TextureButton     = $TextureButton
@export var empezar_up:          Texture2D
@export var empezar_down:        Texture2D
@export var reinicia_up:         Texture2D
@export var reinicia_down:       Texture2D

var usando_empezar: bool = true

func _ready() -> void:
	reinicia()

func reinicia() -> void:
	usando_empezar = true
	_aplicar_texturas_empezar()
	
func _on_texture_button_button_up() -> void:
	# Al terminar el ciclo down→up, alterna el set
	usando_empezar = not usando_empezar
	if usando_empezar:
		_aplicar_texturas_empezar()
	else:
		_aplicar_texturas_reinicia()

func _on_texture_button_pressed() -> void:
	if usando_empezar:
		emit_signal("empezar")
	else:
		emit_signal("reinciar")

func _aplicar_texturas_empezar() -> void:
	boton.texture_normal = empezar_up
	boton.texture_pressed = empezar_down

func _aplicar_texturas_reinicia() -> void:
	boton.texture_normal = reinicia_up
	boton.texture_pressed = reinicia_down
