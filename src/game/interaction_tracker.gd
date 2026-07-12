class_name InteractionTracker

const _USE_OBJECT_TARGET_RANGE := \
		preload("uid://d0vwau5s8b80u") as TargetingConfig


var use_object_targeting_data: TargetingData:
	get:
		return _use_object_targeting_data


var _use_object_targeting_data: TargetingData


func update(actor: Actor) -> void:
	_use_object_targeting_data = \
			_USE_OBJECT_TARGET_RANGE.get_targeting_data(actor)
