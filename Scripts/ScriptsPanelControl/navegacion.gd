extends Control

@onready var arrow:                  Sprite2D          = $Brujula/Flecha 
var target_deg: float = 90.0   # objetivo en grados (90=Ese)

@onready var sprite_siguiente_color: Sprite2D          = $PanelContainer/NavegacionSiguienteColorBase
var colores:Array =[] # Array de Objetivo (valor, x, y)
var indice_colores_actual: int = 0
var color_actual: String = "rojo"

func actualiza_direccion(dir: DIRECCION.tipo):
	match dir:
		DIRECCION.tipo.ARRIBA:
			set_bearing_degrees(0.0)
		DIRECCION.tipo.ABAJO:
			set_bearing_degrees(180.0)
		DIRECCION.tipo.IZQUIERDA:
			set_bearing_degrees(270.0)
		DIRECCION.tipo.DERECHA:
			set_bearing_degrees(90.0)
		_:
			set_bearing_degrees(90.0)
			
# Configura un objetivo (Este=90°)
func set_bearing_degrees(deg: float) -> void:
	target_deg = deg

func _process(delta: float) -> void:
	# Rotación actual en radianes
	var current := arrow.rotation
	# Objetivo en radianes
	var target := deg_to_rad(target_deg)
	# Interpolación suave (ajusta 8.0 para más/menos rapidez)
	arrow.rotation = lerp_angle(current, target, delta * 8.0)


func actualiza_siguiente_color(color: String) -> void:
	set_imagen(color)

		
func set_imagen(color:String):
	var ruta_imagen = "res://Assets/PanelDeControl/navegacion/navegacion_siguiente_color_"
	match color:
		"Blanco":
			ruta_imagen += "blanco.png"
		"Verde":
			ruta_imagen += "verde.png"
		"Rojo":
			ruta_imagen += "rojo.png"
		"Negro":
			ruta_imagen += "negro.png"
		"Azul":
			ruta_imagen += "azul.png"
		"Base":
			ruta_imagen += "base.png"
		_:
			print("Error: Color no reconocido: %s" % color)
			 
	# Cargar textura y configurar propiedades de escala
	var textura = load(ruta_imagen)
	if textura:
		sprite_siguiente_color.texture = textura
	else:
		print ("Error: No se pudo cargar la textura")
