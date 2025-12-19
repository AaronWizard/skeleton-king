@tool
class_name ActorData
extends Resource

@export var name: String


@export var sprite: Texture2D:
	set(value):
		if sprite != value:
			sprite = value
			emit_changed()


@export_range(1, 1, 1, "or_greater") var size := 1:
	set(value):
		if size != value:
			size = value
			emit_changed()


@export var faction: StringName

@export var base_stats: BaseStats
