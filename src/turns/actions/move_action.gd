class_name MoveAction
extends TurnAction

var _actor: Actor
var _next_cell: Vector2i


func _init(p_actor: Actor, p_next_cell: Vector2i) -> void:
	_actor = p_actor
	_next_cell = p_next_cell


func run() -> void:
	_actor.origin_cell = _next_cell
