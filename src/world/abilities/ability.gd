@icon("uid://bsynj7bxhunni")
class_name Ability
extends Resource

## An actor's ability.

## The name of the ability.
@export var name: String
## The ability's icon.
@export var icon: Texture2D

## The ability's targeting and AOE config.
@export var targeting_config: TargetingConfig

## The effects applied when the ability is run for a given actor and target.
@export var effects: Array[AbilityEffect]


## Runs the ability with a given source actor and target.[br]
## Assumes [param target] is a valid target.
func run(actor: Actor, target: Vector2i) -> void:
	if not actor:
		push_error("No actor set")
		return
	if not actor.map:
		push_error("Actor not on a map")
		return

	if actor.map.animations_running:
		await actor.map.animations_finished

	var aoe := targeting_config.get_aoe(actor, target)

	var data := AbilityData.new(
			actor, actor.origin_cell, target, targeting_config.target_type, aoe)

	for e in effects:
		@warning_ignore("redundant_await")
		await e.run(data)


## Creates an [AbilityAction] that makes [param actor] use this ability at
## [param target].
func create_turn_action(actor: Actor, target: Vector2i) -> TurnAction:
	return AbilityAction.new(actor, self, target)
