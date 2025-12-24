@abstract
class_name BehaviourTreeCondition
extends Resource

@export var invert := false


func evaulate(actor: Actor) -> bool:
	var result := _evaulate(actor)
	if invert:
		result = not result
	return result


@abstract func _evaulate(actor: Actor) -> bool
