class_name AttackAction
extends TurnAction

var _attacker: Actor
var _target: Actor


func _init(p_attacker: Actor, p_target: Actor) -> void:
	_attacker = p_attacker
	_target = p_target


func run() -> bool:
	if not _attacker or not _attacker.stats.is_alive:
		return false
	if not _target or not _target.stats.is_alive \
			or not Actor.are_enemies(_attacker, _target):
		return false

	if _attacker.map.animations_running:
		await _attacker.map.animations_finished

	_attacker.remote_transform.update_position = false
	_target.remote_transform.update_position = false

	await CombatEngine.attack_actor(_attacker, _target)

	_attacker.remote_transform.update_position = true
	_target.remote_transform.update_position = true

	return true
