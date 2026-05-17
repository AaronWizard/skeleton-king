extends Node2D

@export var active := true

@export var game: Game

@onready var _mouse_info := $MouseInfo as Node2D

@onready var _actor_name := %ActorName as Label
@onready var _mouse_cell := %MouseCell as Label


func _ready() -> void:
	visible = active
	set_process(active)

	if active:
		_update_mouse_info()


func _process(_delta: float) -> void:
	_update_mouse_info()


func _update_mouse_info() -> void:
	if not game or not game.map:
		_mouse_info.visible = false
		return

	_mouse_info.visible = true
	_mouse_info.position = get_local_mouse_position()

	_mouse_cell.text = "%d,%d" \
			% [game.map.mouse_cell.x, game.map.mouse_cell.y]

	var actor := game.map.get_actor_on_cell(game.map.mouse_cell)
	_actor_name.visible = actor != null
	if actor:
		_actor_name.text = actor.name
	else:
		_actor_name.text = ""
