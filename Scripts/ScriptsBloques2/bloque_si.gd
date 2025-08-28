extends BloqueBase
const width_si :float = 205
const height_si :float = 66
const sprite_width_si :float = 205
const sprite_height_si :float = 72

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
		print ("Error: bloque si sin argumento")
	#Objetivo_alcanzado devuelve true si se ha llegado a ese objetivo
	var bloque_actual = get_primer_bloque_cuerpo()
	if arg != null and await arg.ejecutar(Token) and zona_construccion.robot_en_movimiento():
		if bloque_actual != null:
			if bloque_actual.has_method("ejecutar") and zona_construccion.robot_en_movimiento():
				await bloque_actual.ejecutar(Token)
				
	siguiente = get_siguiente()
	if siguiente != null and zona_construccion.robot_en_movimiento():
		if siguiente.has_method("ejecutar"):
			await siguiente.ejecutar(Token)
