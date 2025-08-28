extends Control

signal cambio_velocidad(nivel_velocidad:int)

@onready var control:        Control          = find_parent("Control")
@onready var boton:          TextureButton    = $TextureButton
@export  var texturas:       Array[Texture2D] = []
@onready var aguja:         Sprite2D         = $Aguja
var target_deg: float = -135.0

# Estado actual (0-2). Empieza en 0.
var nivel_velocidad:int = 0

func _ready() -> void:
	nivel_velocidad = 1
	actualizar_texture()
	actualizar_aguja()
	cambio_velocidad.connect(_on_pressed)
	
func _on_pressed() -> void:
	cambiar_velocidad()

func cambiar_velocidad():
	nivel_velocidad = (nivel_velocidad + 1) % 3          # rota 0→1→2→0…
	actualizar_texture()
	actualizar_aguja()
	emit_signal("cambio_velocidad", nivel_velocidad)

func actualizar_texture() -> void:
	if nivel_velocidad < texturas.size():
		boton.texture_normal = texturas[nivel_velocidad]
	else:
		boton.texture_normal = null

func actualizar_aguja() -> void:
	match nivel_velocidad:
		0:
			target_deg = -135.0
		1:
			target_deg = -45.0
		2:
			target_deg = 45.0

func _process(delta: float) -> void:
	# Rotación actual en radianes
	var current := aguja.rotation
	# Objetivo en radianes
	var target := deg_to_rad(target_deg)
	# Interpolación suave (ajusta 8.0 para más/menos rapidez)
	aguja.rotation = lerp_angle(current, target, delta * 8.0)
