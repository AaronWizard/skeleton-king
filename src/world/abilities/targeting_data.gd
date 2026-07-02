class_name TargetingData

## The targeting data for an ability and an actor at its current position.
##
## The targeting data for an ability and an actor at its current position.
## Describes the valid targets and AOEs for each target. Also describes what
## cells to highlight on the screen, and what targets cells map to when
## selected.

## The type of cells the ability targets.
var target_type: TargetType.Type:
	get:
		return _target_type


## The cells that may be selected as targets when using the ability.
var valid_targets: Array[Vector2i]:
	get:
		return _valid_targets


## The cells to highlight when displaying the ability's target range on-screen.
var ui_target_range: Array[Vector2i]:
	get:
		return _ui_target_range


var _target_type: TargetType.Type

var _valid_targets: Array[Vector2i]
var _ui_target_range: Array[Vector2i]

# Values are of type Array[Vector2i].
var _aoes: Dictionary[Vector2i, Array]
var _ui_aoes: Dictionary[Vector2i, Array]


func _init(
		p_target_type: TargetType.Type,
		p_valid_targets: Array[Vector2i],
		p_ui_target_range: Array[Vector2i],
		p_aoes: Dictionary[Vector2i, Array],
		p_ui_aoes: Dictionary[Vector2i, Array]) -> void:
	_target_type = p_target_type
	_valid_targets = p_valid_targets
	_ui_target_range = p_ui_target_range
	_aoes = p_aoes
	_ui_aoes = p_ui_aoes


## Get the AOE for [param target].[br]
## Returns an empty array if [param target] is not a valid target.
func get_aoe(target: Vector2i) -> Array[Vector2i]:
	return _get_value_from_cell_dict(_aoes, target)


## Get the AOE that is displayed on-screen for [param target].[br]
## Returns an empty array if [param target] is not a valid target.
func get_ui_aoe(target: Vector2i) -> Array[Vector2i]:
	return _get_value_from_cell_dict(_ui_aoes, target)


static func _get_value_from_cell_dict(
		dict: Dictionary[Vector2i, Array], key: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	if dict.has(key):
		result.assign(dict[key])
	return result
