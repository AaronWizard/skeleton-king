class_name UseObjectAction
extends TurnAction

var _object: UseableObject
var _map: Map


func _init(p_object: UseableObject, p_map: Map) -> void:
	_object = p_object
	_map = p_map


func run() -> void:
	if _map.animations_running:
		await _map.animations_finished
	_object.use()
