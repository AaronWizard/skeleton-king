class_name AttackAction
extends TurnAction

var _attacker: Actor
var _target: Actor


func _init(p_attacker: Actor, p_target: Actor) -> void:
	_attacker = p_attacker
	_target = p_target


func run() -> void:
	if _attacker.map.animations_running:
		await _attacker.map.animations_finished
	await CombatEngine.attack_actor(_attacker, _target)
