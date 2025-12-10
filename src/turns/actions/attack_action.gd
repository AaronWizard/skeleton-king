class_name AttackAction
extends TurnAction

var _attacker: Actor
var _target: Actor


func _init(p_attacker: Actor, p_target: Actor) -> void:
	_attacker = p_attacker
	_target = p_target


func run() -> void:
	CombatEngine.attack_actor(_attacker, _target)
