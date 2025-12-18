@tool
class_name UseableTileState
extends Resource


@export var sprite: Texture2D:
	set(value):
		sprite = value
		emit_changed()


@export var blocks_move := false
@export var blocks_sight := false
