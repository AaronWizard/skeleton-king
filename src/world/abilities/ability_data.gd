class_name AbilityData

## The data for an [AbilityEffect].

## The source actor.
var source_actor: Actor:
	get:
		return _source_actor


## The source cell.
var source_cell: Vector2i:
	get:
		return _source_cell


## The target cell.
var target_cell: Vector2i:
	get:
		return _target_cell


## The target type.
var target_type: AbilityTargetType.Type:
	get:
		return _target_type


## The AOE around the target cell.
var aoe: Array[Vector2i]:
	get:
		return _aoe


## The actor at the target cell if any.
var target_actor: Actor:
	get:
		return source_actor.map.get_actor_on_cell(target_cell)


var _source_actor: Actor
var _source_cell: Vector2i
var _target_cell: Vector2i
var _target_type: AbilityTargetType.Type
var _aoe: Array[Vector2i]


func _init(p_actor: Actor, p_source: Vector2i, p_target: Vector2,
		p_target_type: AbilityTargetType.Type, p_aoe: Array[Vector2i]) -> void:
	_source_actor = p_actor
	_source_cell = p_source
	_target_cell = p_target
	_target_type = p_target_type
	_aoe = p_aoe
