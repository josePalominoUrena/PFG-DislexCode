extends Control
@onready var message_label: RichTextLabel = $Panel/Mensaje
@onready var si_button:     Button        = $Panel/SI
@onready var no_button:     Button        = $Panel/NO

func _ready():
	# Ocultar el menú inicialmente
	visible = false
	pass
func mostrar_menu(message: String = "¿quieres salir del juego?"):
	message_label.text = message
	visible = true

func hide_menu():
	visible = false
	get_tree().paused = false


func _on_cerrar_pressed() -> void:
	hide_menu()


func _on_si_pressed() -> void:
	get_tree().quit()


func _on_no_pressed() -> void:
	hide_menu()
