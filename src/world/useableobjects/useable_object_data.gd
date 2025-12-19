@tool
class_name UseableObjectData
extends Resource


@export var states: Array[UseableObjectState] = []:
	set(value):
		states = value
		emit_changed()


@export var size := Vector2i.ONE:
	set(value):
		if size != value:
			size = value
			emit_changed()
