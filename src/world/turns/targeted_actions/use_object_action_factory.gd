class_name UseObjectActionFactory
extends TargetedActionFactory

var _actor: Actor


func _init(p_actor: Actor) -> void:
	_actor = p_actor


func create_action(target: Vector2i) -> TurnAction:
	if not _actor:
		push_error("No actor set")
		return null
	if not _actor.map:
		push_error("Actor not on a map")
		return null

	var object := _actor.map.get_useable_object_on_cell(target)
	return UseObjectAction.new(object, _actor.map)
