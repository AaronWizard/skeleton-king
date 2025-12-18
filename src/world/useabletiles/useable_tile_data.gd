class_name UseableTileData
extends Resource

@export var states: Array[UseableTileState]


var state_count: int:
	get:
		return states.size()
