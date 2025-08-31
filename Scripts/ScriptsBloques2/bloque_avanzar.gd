extends BloqueBase

func ejecutar(Token:int):
	zona_construccion.avanzar(Token)
	modulate = Color(1, 1, 1, 0.7)
	await zona_construccion.espera("avanzar")
	modulate = Color(1, 1, 1, 1)
	# Ejecuta el siguiente bloque conectado por debajo:

	siguiente = get_siguiente()
	if siguiente != null and zona_construccion.robot_en_movimiento():
		if siguiente.has_method("ejecutar"):
			await get_tree().process_frame
			await siguiente.ejecutar(Token)
			
	
