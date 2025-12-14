class_name MoveAction
extends TurnAction

var _actor: Actor
var _next_cell: Vector2i


func _init(p_actor: Actor, p_next_cell: Vector2i) -> void:
	_actor = p_actor
	_next_cell = p_next_cell


func run() -> void:
	var delta := _next_cell - _actor.origin_cell

	_actor.origin_cell = _next_cell

	_actor.sprite.offset_direction = delta
	_actor.sprite.offset_distance = -1
	_actor.sprite.play_standard_anim(ActorSprite.StandardAnims.MOVE_STEP)
