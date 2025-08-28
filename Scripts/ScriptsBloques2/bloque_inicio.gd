extends BloqueBase

func _ready():
	width = self.size.x
	height = self.size.y
	esta_en_lienzo = true
	recalcula_tamano()
	zona_construccion = find_parent("ZonaConstrucción")
	if not zona_construccion:
		print("No se encontró ZonaConstruccion")
	
func ejecutar(Token:int):
	# Punto de entrada, delega ejecución al siguiente bloque posterior
	siguiente = get_primer_bloque_cuerpo() 
	if siguiente != null and zona_construccion.robot_en_movimiento():
		await get_tree().process_frame
		await siguiente.ejecutar(Token)
	#Si no quedan más bloques que ejecutar
	zona_construccion.fin_ejecucion(Token)


func borrar_hijos() -> void:
	for hijo in codigo.get_children():
		hijo.queue_free()
