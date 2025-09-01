extends Control

@onready var label: RichTextLabel = $Panel/Mensaje
var drag_iniciado = false

func _ready():
	# Ocultar el menú inicialmente
	visible = false
	resetear_posicion()
func resetear_posicion():
	self.position = Vector2(729,295)

func mostrar_mensaje(message: String = "descripción del nivel "):
	#print (message.length())
	resetear_posicion()
	var font_size = calcular_tamaño_fuente(message.length())
	label.add_theme_font_size_override("normal_font_size", font_size)
	message = colorear_texto(message)
	label.text = "[center]" + message + "[/center]"
	visible = true
	
	#animación de aparición
	var tween = create_tween()
	modulate.a = 0.0
	tween.tween_property(self, "modulate:a", 1.0, 0.6)

func mostrar():
	visible = true
func hide_menu():
	visible = false
	get_tree().paused = false
	
func colorear_texto(texto: String) -> String:
	var colored := texto.replace("MIENTRAS", "[color=dark_orange]MIENTRAS[/color]")
	colored = colored.replace("AVANZAR", "[color=purple]AVANZAR[/color]")
	colored = colored.replace("AVANZA", "[color=purple]AVANZA[/color]")
	colored = colored.replace("GIRAR", "[color=purple]GIRAR[/color]")
	colored = colored.replace("GIRA", "[color=purple]GIRA[/color]")
	colored = colored.replace("SIGUIENTE COLOR", "[color=dark_green]SIGUIENTE COLOR[/color]")
	colored = colored.replace("siguiente color", "[color=dark_green]siguiente color[/color]")
	colored = colored.replace("SI NO", "[color=orange]SI NO[/color]")
	colored = colored.replace("SI ", "[color=orange]SI[/color]")
	colored = colored.replace("objetivo alcanzado", "[color=dark_green]objetivo alcanzado[/color]")
	colored = colored.replace("OBJETIVO ALCANZADO", "[color=dark_green]OBJETIVO ALCANZADO[/color]")
	colored = colored.replace("color siguiente", "[color=dark_green]color siguiente[/color]")
	return colored
func _on_cerrar_pressed() -> void:
	hide_menu()
	

func calcular_tamaño_fuente(longitud_texto: int) -> int:
	# Tamaños de fuente según rangos de longitud
	if longitud_texto <= 100:
		return 16  # Texto corto = fuente grande
	elif longitud_texto <= 125:
		return 15 # Texto medio = fuente media
	elif longitud_texto <= 150:
		return 14 # Texto medio = fuente media
	elif longitud_texto <= 180:
		return 14  # Texto largo = fuente pequeña
	elif longitud_texto <= 200:
		return 13  # Texto largo = fuente pequeña
	else:
		return 11  
	
var drag_offset := Vector2.ZERO

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			drag_iniciado = true
			drag_offset = global_position - get_global_mouse_position()			
		if not event.pressed:
			if drag_iniciado:
				# Si había un drag activo, notificar que se soltó el botón
				drag_iniciado = false

func _process(_delta: float) -> void:
	if drag_iniciado:
		self.position = get_global_mouse_position()	+ drag_offset			
