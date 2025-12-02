@tool
class_name ActorData
extends Resource

@export var name: String
@export var sprite: Texture2D
@export var faction: StringName

@export_range(1, 1, 1, "or_greater") var attack := 1
@export_range(1, 1, 1, "or_greater") var stamina := 1
