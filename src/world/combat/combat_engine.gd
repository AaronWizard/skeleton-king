class_name CombatEngine


static func attack_actor(attacker: Actor, target: Actor) -> void:
	var direction := target.origin_cell - attacker.origin_cell
	attacker.sprite.offset_direction = direction
	target.sprite.offset_direction = direction

	attacker.sprite.play_standard_anim(
			ActorSprite.StandardAnims.ACTION_AIMED)
	await attacker.sprite.action_frame_reached
	await target.sprite.play_standard_anim(ActorSprite.StandardAnims.HIT_AIMED)
	if attacker.sprite.animation_playing:
		await attacker.sprite.animation_finished

	target.stats.stamina -= attacker.stats.attack
	if not target.stats.is_alive:
		target.map.remove_actor(target)
