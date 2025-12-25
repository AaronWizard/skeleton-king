class_name PathfinderDebugDrawer
extends Node2D

@export var actor_size := Vector2i.ONE
@export var tile_size := Vector2i(12, 12)


@export var active := false:
	set(value):
		active = value
		set_process(active)
		queue_redraw()


var pathfinder: Pathfinder


func _ready() -> void:
	set_process(active)


func _process(_delta: float) -> void:
	if active:
		queue_redraw()


func _draw() -> void:
	if active:
		pathfinder.debug_draw(self, actor_size, tile_size)
