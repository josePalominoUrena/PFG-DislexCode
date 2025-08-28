extends Control

@onready var titulo:              RichTextLabel = $PanelTitulo/titulo
@onready var enunciado:           RichTextLabel = $PanelEnunciado/enunciado
@onready var salida:              RichTextLabel = $PanelSalida/salida

@export var color_texto:          Color         = Color.LIME_GREEN
@export var color_salida:         Color         = Color.RED
@export var fuente:               String        = "VT323-Regular.ttf"
@export var tamano_fuente_titulo: int           = 24
@export var tamano_fuente_texto:  int           = 18
# Velocidad del efecto de escritura (caracteres por segundo)
@export var cps_titulo:           float         = 20.0
@export var cps_enunciado:        float         = 35.0
@export var cps_salida:           float         = 35.0

var nivel: Nivel

func cargar_info_nivel(n: Nivel) -> void:
	nivel = n
	titulo.text = ""
	enunciado.text = ""
	salida.text = ""
	# TITULO: mayúsculas y estilo
	titulo.text = nivel.tipo_ejercicio
	titulo.text = titulo.text.to_upper()
	opciones_texto(titulo, color_texto, fuente, tamano_fuente_titulo)
	_revelar_richtext_gradual(titulo, cps_titulo)
	
	await get_tree().create_timer(1.0).timeout
	# ENUNCIADO: estilo y texto
	enunciado.text = nivel.descripcion_corta
	opciones_texto(enunciado, color_texto, fuente, tamano_fuente_texto)
	_revelar_richtext_gradual(enunciado, cps_enunciado)

func mensaje(s: String) -> void:
	salida.text = ""
	salida.text = s
	opciones_texto(salida, color_salida, fuente, tamano_fuente_texto)
	_revelar_richtext_gradual(salida, cps_salida)
	
func opciones_texto(label: RichTextLabel, fc: Color, f: String, fs: int) -> void:
	# Color de texto base (afecta al texto normal sin tags de color)
	label.add_theme_color_override("default_color", fc)
	# Fuente y tamaño por defecto
	label.add_theme_font_size_override("normal_font_size", fs)

	# (Opcional) coherencia si usas BBCode [b], [i], [code]/[mono]
	label.add_theme_font_size_override("bold_font_size", fs)
	label.add_theme_font_size_override("italics_font_size", fs)
	label.add_theme_font_size_override("mono_font_size", fs)

# Revela progresivamente el texto de un RichTextLabel usando visible_ratio.
# Calcula la duración a partir de caracteres totales y cps (caracteres/segundo).
func _revelar_richtext_gradual(r: RichTextLabel, cps: float) -> void:
	# Esperar un frame para que el texto esté procesado
	await get_tree().process_frame
	
	# Resetea visibilidad usando visible_ratio (0.0 a 1.0)
	r.visible_ratio = 0.0
	
	# get_total_character_count es preciso con y sin BBCode
	var total = max(1, r.get_total_character_count())
	var dur = clamp(total / max(1.0, cps), 0.01, 60.0)
	
	# Tween suave lineal
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(r, "visible_ratio", 1.0, dur)
	
