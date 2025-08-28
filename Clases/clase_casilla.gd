class_name Casilla
extends RefCounted

var posicion:Vector2
var color: String
var tiene_objetivo:bool
var objetivo:Objetivo

func _init(x:int, y:int, c: String):
	posicion = Vector2(x, y)
	color = c

func agregar_objetivo(o:Objetivo):
	tiene_objetivo = true
	objetivo = o
	
func quitar_objetivo():
	tiene_objetivo = false
