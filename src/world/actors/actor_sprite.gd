@tool
class_name ActorSprite
extends Node2D

signal animation_started
signal animation_finished

signal action_frame_reached

enum Facing { EAST, WEST }

enum StandardAnims {
	MOVE_STEP,
	ACTION_AIMED,
	HIT_AIMED
}

const _STANDARD_ANIMS: Dictionary[StandardAnims, StringName] = {
	StandardAnims.MOVE_STEP: &"move_step",
	StandardAnims.ACTION_AIMED: &"action_aimed",
	StandardAnims.HIT_AIMED: &"hit_aimed"
}


@export var texture: Texture2D:
	get:
		if not is_node_ready():
			await ready
		return _sprite.texture
	set(value):
		if not is_node_ready():
			await ready
		_sprite.texture = value


@export var facing: Facing:
	get:
		if not is_node_ready():
			await ready
		var result := Facing.EAST
		if _sprite.flip_h:
			result = Facing.WEST
		return result
	set(value):
		if not is_node_ready():
			await ready
		_sprite.flip_h = value == Facing.WEST


@export var tile_size := Vector2i(12, 12):
	set(value):
		tile_size = value
		if not is_node_ready():
			await ready
		_set_cell_offset()


@export var cell_offset: Vector2:
	get:
		return _offset_direction * _offset_distance
	set(value):
		_offset_direction = value.normalized()
		_offset_distance = value.length()
		_set_cell_offset()


@export var offset_direction: Vector2:
	get:
		return _offset_direction
	set(value):
		_offset_direction = value.normalized()
		_set_cell_offset()


@export var offset_distance: float:
	get:
		return _offset_distance
	set(value):
		_offset_distance = value
		_set_cell_offset()


var animation_playing: bool:
	get:
		return _animation_playing


var _offset_direction := Vector2.ZERO
var _offset_distance := 0.0
var _animation_playing := false

@onready var _sprite := $Sprite as Sprite2D
@onready var _animation_player := $AnimationPlayer as AnimationPlayer


func reset_offset() -> void:
	_offset_direction = Vector2.ZERO
	_offset_distance = 0.0
	_set_cell_offset()


func play_standard_anim(anim: StandardAnims) -> void:
	_signal_anim_start()

	_animation_player.play(_STANDARD_ANIMS[anim])
	if _animation_player.is_playing():
		await _animation_player.animation_finished

	_signal_anim_end()


func _set_cell_offset() -> void:
	if not is_node_ready():
		await ready
	_sprite.position = offset_direction * offset_distance * Vector2(tile_size)


func _set_facing_from_offset_direction() -> void:
	if offset_direction.x < 0:
		facing = Facing.WEST
	elif offset_direction.x > 0:
		facing = Facing.EAST


func _signal_anim_start() -> void:
	_animation_playing = true
	animation_started.emit()


func _signal_anim_end() -> void:
	_animation_playing = false
	animation_finished.emit()


func _signal_action_frame() -> void:
	action_frame_reached.emit()


func _tile_size_changed() -> void:
	_set_cell_offset()


func _cell_size_changed() -> void:
	_set_cell_offset()
