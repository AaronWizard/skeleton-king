@tool
class_name ActorData
extends Resource

@export var name: String

@export var sprite: Texture2D
@export_range(1, 1, 1, "or_greater") var size := 1

@export var faction: StringName

@export var base_stats: BaseStats
