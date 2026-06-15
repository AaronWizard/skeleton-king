class_name AbilityAction
extends TurnAction

var _actor: Actor
var _ability: Ability
var _target: Vector2i


func _init(p_actor: Actor, p_ability: Ability, p_target: Vector2i) -> void:
	_actor = p_actor
	_ability = p_ability
	_target = p_target


func run() -> bool:
	if not _ability.target_is_valid(_actor, _target):
		Log.print(
			"%s failed to use ability %s at %.v" \
				% [_actor.name, _ability.name, _target]
		)
		return false

	await _ability.run(_actor, _target)
	return true
