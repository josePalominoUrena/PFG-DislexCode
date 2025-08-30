extends Control
@export var paginas: Array[Panel]
var indice:int = 0

func _ready() -> void:
	indice = 0
	ocultar_todas_paginas()
	mostrar_pagina(indice)
	
func mostrar():
	if visible == false:
		visible = true
	else:
		visible = false

func mostrar_pagina(i:int):
	ocultar_todas_paginas()
	indice = i % paginas.size()
	paginas[indice].visible = true
	ajustes_texto()
	
func mostrar_pagina_nombre(nombre:String):
	var i:int = 0
	for pagina in paginas:
		if is_instance_valid(pagina):
			if pagina.name == nombre:
				mostrar()
				mostrar_pagina(i)
				return
		i += 1
			
func ocultar_todas_paginas():
	for pagina in paginas:
		if is_instance_valid(pagina):
			pagina.visible = false
		
func hide_book():
	visible = false
	
func _on_cerrar_pressed() -> void:
	hide_book()


func _on_anterior_pagina_pressed() -> void:
	if paginas.is_empty():
		return
	indice = (indice - 1 + paginas.size()) % paginas.size()
	mostrar_pagina(indice)

func _on_siguiente_pagina_pressed() -> void:
	if paginas.is_empty():
		return
	indice = (indice + 1) % paginas.size()
	mostrar_pagina(indice)

func ajustes_texto():
	var label = paginas[indice].find_child("explicacion") as RichTextLabel
	if is_instance_valid(label):
		var texto = label.text
		texto = centrar_texto(texto)
		label.text =  colorear_texto(texto)

	else:
		print("no es valida")

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

func centrar_texto(texto: String) -> String:
	texto ="[center]" + texto + "[/center]"
	return texto
