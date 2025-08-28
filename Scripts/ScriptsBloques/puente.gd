#puente es un nodo que usaremos para instanciar la escena mientra tengamos presionado el ratón (efecto de arrastrar imagen)
extends Node2D

func _process(_delta: float) -> void:
	self.position = get_global_mouse_position()
	if get_child_count() > 1:
		get_child(1).queue_free()

func liberar():
	for hijo in get_children():
		hijo.queue_free()
