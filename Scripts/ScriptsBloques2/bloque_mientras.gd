extends BloqueBase

func _ready():
	super._ready()
	if _esta_en_menu():
		argumento.visible = false 
		
func _process(delta: float) -> void:
	super._process(delta)
	await get_tree().process_frame
	if zona_construccion.bloque_en_arrastre == null:
		conexion_siguiente.visible = false
		conexion_argumento.visible = false
		conexion_interior.visible = false
	else:
		conexion_siguiente.visible = true
		conexion_argumento.visible = true
		conexion_interior.visible = true

func ejecutar(Token:int):
	var arg = null
	if argumento.get_child_count() > 0:
		arg = argumento.get_child(0)
	else:
		salida_mensaje("bloque mientras sin condinción (bloque verde)")
	#Objetivo_alcanzado devuelve true si NO se ha llegado a ese objetivo
	var bloque_actual = get_primer_bloque_cuerpo()
	if bloque_actual == null and arg != null:
		salida_mensaje("bucle infinito")
	while arg != null and await arg.ejecutar(Token) and await zona_construccion.robot_en_movimiento():
		#await get_tree().create_timer(0.2).timeout
		if bloque_actual != null:
			if bloque_actual.has_method("ejecutar") and zona_construccion.robot_en_movimiento():
				await bloque_actual.ejecutar(Token)
				await get_tree().process_frame
	siguiente = get_siguiente()
	if siguiente != null and zona_construccion.robot_en_movimiento():
		if siguiente.has_method("ejecutar"):
			await get_tree().process_frame
			await siguiente.ejecutar(Token)
