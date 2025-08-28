extends Control
class_name MenuNivelCompletado

signal restart_requested
signal next_level_requested

@onready var message_label: RichTextLabel = $Panel/Mensaje
@onready var restart_button: TextureButton = $Panel/Reiniciar
@onready var next_button: TextureButton = $Panel/SiguienteNivel

func _ready():
	# Ocultar el menú inicialmente
	visible = false

func mostrar_menu(message: String = "¡Nivel Completado!"):
	message_label.text = message
	visible = true
	
	# animación de aparición
	#var tween = create_tween()
	#modulate.a = 0.0
	#tween.tween_property(self, "modulate:a", 1.0, 0.3)

func hide_menu():
	visible = false
	get_tree().paused = false

func _on_restart_pressed():
	restart_requested.emit()
	hide_menu()

func _on_next_level_pressed():
	next_level_requested.emit()
	hide_menu()


func _on_cerrar_pressed() -> void:
	hide_menu()
