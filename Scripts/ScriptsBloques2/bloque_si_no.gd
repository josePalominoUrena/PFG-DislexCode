extends "res://Scripts/ScriptsBloques2/bloque_si.gd"

func ejecutar(Token:int):
	var arg = null
	if argumento.get_child_count() > 0:
		arg = argumento.get_child(0)
	else:
		print ("Error: bloque si sin argumento")
	#Objetivo_alcanzado devuelve true si se ha llegado a ese objetivo
	var bloque_actual = get_primer_bloque_cuerpo()
	if arg != null and !await arg.ejecutar(Token) and zona_construccion.robot_en_movimiento():
		if bloque_actual != null:
			if bloque_actual.has_method("ejecutar") and zona_construccion.robot_en_movimiento():
				await bloque_actual.ejecutar(Token)
				
	siguiente = get_siguiente()
	if siguiente != null and zona_construccion.robot_en_movimiento():
		if siguiente.has_method("ejecutar"):
			await siguiente.ejecutar(Token)
