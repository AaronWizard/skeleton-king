class_name CombatEngine


static func attack_actor(attacker: Actor, target: Actor) -> void:
	target.stats.stamina -= attacker.stats.attack
	if not target.stats.is_alive:
		target.map.remove_actor(target)
