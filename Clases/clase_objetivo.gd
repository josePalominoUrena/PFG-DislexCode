class_name Objetivo
extends RefCounted

var id: int
var tipo:String
var valor:String = ""
var ruta_imagen:String = "res://Assets/Objetivos/"
var x:int
var y:int

func _init(i:int, t: String, v: String, p1: int, p2: int):
	id = i
	tipo = t
	if tipo == "texto":
		valor = v
	else:
		valor = v
		ruta_imagen = ruta_imagen + v
	x = p1
	y = p2
