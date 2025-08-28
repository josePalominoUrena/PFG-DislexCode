extends Resource
class_name TiposBloque

enum Tipo {
	INICIO,
	FLUJO,
	ACCION,
	SENSOR,
	LOGICO
}

static func compatibles_con(tipo: Tipo) -> Array[Tipo]:
	match tipo:
		Tipo.INICIO:
			return [Tipo.FLUJO, Tipo.ACCION]
		Tipo.FLUJO, Tipo.ACCION:
			return [Tipo.FLUJO, Tipo.ACCION]
		_:
			return []
