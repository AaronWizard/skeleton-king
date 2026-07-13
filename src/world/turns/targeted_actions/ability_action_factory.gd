class_name AbilityActionFactory
extends TargetedActionFactory

var _actor: Actor
var _ability: Ability


func _init(p_actor: Actor, p_ability: Ability) -> void:
	_actor = p_actor
	_ability = p_ability


func create_action(target: Vector2i) -> TurnAction:
	return AbilityAction.new(_actor, _ability, target)
