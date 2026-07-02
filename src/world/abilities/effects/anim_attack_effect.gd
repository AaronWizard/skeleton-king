class_name AnimAttackEffect
extends AbilityEffect

@export var effects: Array[AbilityEffect]


func run(data: AbilityData) -> void:
	data.source_actor.remote_transform.update_position = false

	_setup_and_start_animation(data)
	await data.source_actor.sprite.action_frame_reached

	for e in effects:
		@warning_ignore("redundant_await")
		await e.run(data)

	if data.source_actor.sprite.animation_playing:
		await data.source_actor.sprite.animation_finished

	data.source_actor.remote_transform.update_position = true


func utility_score(data: AbilityData) -> float:
	var sum = func (accum: float, effect: AbilityEffect) -> float:
		return accum + effect.utility_score(data)
	return effects.reduce(sum, 0.0)


func _setup_and_start_animation(data: AbilityData) -> void:
	var direction: Vector2i
	if data.target_type == TargetType.Type.ACTOR:
		direction = \
				data.target_actor.origin_cell - data.source_actor.origin_cell
	else:
		direction = data.target_cell - data.source_actor.origin_cell
	data.source_actor.sprite.offset_direction = direction

	data.source_actor.sprite.play_standard_anim(
		ActorSprite.StandardAnims.ACTION_AIMED
	)
