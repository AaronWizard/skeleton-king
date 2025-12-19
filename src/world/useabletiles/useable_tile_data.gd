@tool
class_name UseableTileData
extends Resource


@export var states: Array[UseableTileState] = []:
	set(value):
		states = value
		emit_changed()


@export var size := Vector2i.ONE:
	set(value):
		if size != value:
			size = value
			emit_changed()
