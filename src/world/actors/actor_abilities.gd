class_name ActorAbilities

const _ATTACK_ABILITY := preload("uid://dr0s6kvi2j80t") as Ability


var _actor: Actor


func _init(p_actor: Actor) -> void:
	_actor = p_actor


var attack: Ability:
	get:
		return _ATTACK_ABILITY


var all_abilities: Array[Ability]:
	get:
		return [attack]


func can_attack(target: Vector2i) -> bool:
	return attack.target_valid(_actor, target)


func create_attack_action(target: Vector2i) -> TurnAction:
	return attack.create_turn_action(_actor, target)
