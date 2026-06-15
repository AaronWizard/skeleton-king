class_name DamageEffect
extends AbilityEffect


func run(data: AbilityData) -> void:
	data.target_actor.stats.stamina -= data.source_actor.stats.attack

	data.target_actor.remote_transform.update_position = false
	await _setup_and_play_animation(data)
	data.target_actor.remote_transform.update_position = true

	if not data.target_actor.stats.is_alive:
		data.target_actor.map.remove_actor(data.target_actor)


func utility_score(data: AbilityData) -> float:
	var initial_stamina := data.target_actor.stats.stamina
	var final_stamina := maxi(
			0, initial_stamina - data.source_actor.stats.attack)
	return 1.0 - (float(final_stamina) / float(initial_stamina))


func _setup_and_play_animation(data: AbilityData) -> void:
	var direction: Vector2i
	if data.target_type == TargetType.Type.ACTOR:
		direction = \
				data.target_actor.origin_cell - data.source_actor.origin_cell
	else:
		direction = data.target_cell - data.source_actor.origin_cell
	data.target_actor.sprite.offset_direction = direction

	data.source_actor.sprite.play_standard_anim(
		ActorSprite.StandardAnims.ACTION_AIMED
	)
	await data.target_actor.sprite.play_standard_anim(
			ActorSprite.StandardAnims.HIT_AIMED)
