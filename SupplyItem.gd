# SupplyItem.gd
# Script único para todos los suministros recolectables del Nivel 1.
# El nombre del ítem se configura en el Inspector de cada instancia.
extends Area2D

signal item_selected(item_name: String)

@export var item_name: String = "Suministro"

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# Dejar de ser clickeable de inmediato (evita doble disparo este frame)
		set_deferred("input_pickable", false)
		item_selected.emit(item_name)
		# queue_free es diferido por diseño; el procesamiento pesado
		# del manejo se hace también diferido en el manager.
		queue_free()
