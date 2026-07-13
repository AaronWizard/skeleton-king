@tool
class_name Target
extends RectTileObject

signal moved

@onready var _nw := $NWSprite as Node2D
@onready var _ne := $NESprite as Node2D
@onready var _se := $SESprite as Node2D
@onready var _sw := $SWSprite as Node2D

var _actor: Actor = null
var _targeting_data: TargetingData = null

var _send_move_events := false


func _ready() -> void:
	_position_corners()


func _unhandled_input(event: InputEvent) -> void:
	if not visible or not _actor or _targeting_data.valid_targets.is_empty():
		return

	_try_move_target(event)


func show_with_target_range(actor: Actor, targeting_data: TargetingData) \
		-> void:
	_actor = actor
	_targeting_data = targeting_data

	var new_target := Vector2i.ZERO
	var dist_sqr := -1
	for target in _targeting_data.valid_targets:
		if target == origin_cell:
			new_target = target
			break
		var new_dist_sqr := target.distance_squared_to(origin_cell)
		if (dist_sqr < 0) or (new_dist_sqr < dist_sqr):
			new_target = target
			dist_sqr = new_dist_sqr

	origin_cell = new_target

	match _targeting_data.target_type:
		TargetType.Type.ACTOR:
			var other_actor := _actor.map.get_actor_on_cell(origin_cell)
			assert(other_actor)
			cell_dimensions = Vector2i(
				other_actor.cell_length, other_actor.cell_length
			)
		TargetType.Type.OBJECT:
			var object := _actor.map.get_useable_object_on_cell(origin_cell)
			assert(object)
			cell_dimensions = object.cell_dimensions
		_:
			cell_dimensions = Vector2i.ONE

	_send_move_events = not _targeting_data.valid_targets.is_empty()
	visible = not _targeting_data.valid_targets.is_empty()
	set_process_unhandled_input(visible)


func clear_and_hide() -> void:
	_actor = null
	_targeting_data = null
	_send_move_events = false
	visible = false
	set_process_unhandled_input(false)


func try_assign_cell(cell: Vector2i) -> void:
	if not _targeting_data or _targeting_data.valid_targets.is_empty():
		return

	var final_cell := cell
	var final_size := Vector2i.ONE
	if _targeting_data.target_type == TargetType.Type.ACTOR:
		var other_actor := _actor.map.get_actor_on_cell(cell)
		if other_actor:
			final_cell = other_actor.origin_cell
			final_size *= other_actor.cell_length

	if final_cell in _targeting_data.valid_targets:
		origin_cell = final_cell
		cell_dimensions = final_size


func _try_move_target(event: InputEvent) -> void:
	var move_vect := MovementInput.event_move_vect(event)
	if move_vect == Vector2i.ZERO:
		return

	var next_cell: Vector2i
	var dist_sqr := -1
	for target in _targeting_data.valid_targets:
		var target_delta := target - origin_cell
		var can_move_horizontal := (move_vect.y == 0) \
				and (signi(target_delta.x) == signi(move_vect.x))
		var can_move_vertical := (move_vect.x == 0) \
				and (signi(target_delta.y) == signi(move_vect.y))
		if can_move_horizontal or can_move_vertical:
			var new_dist_sqr := target_delta.length_squared()
			if (dist_sqr < 0) or (new_dist_sqr < dist_sqr):
				next_cell = target
				dist_sqr = new_dist_sqr

	if dist_sqr >= 0:
		origin_cell = next_cell


func _origin_cell_changed(_old_cell: Vector2i) -> void:
	if _send_move_events:
		moved.emit()


func _tile_size_changed() -> void:
	_position_corners()


func _cell_size_changed() -> void:
	_position_corners()


func _position_corners() -> void:
	_nw.position = cell_rect.size * Vector2i(0, -1) * tile_size
	_ne.position = cell_rect.size * Vector2i(1, -1) * tile_size
	_se.position = cell_rect.size * Vector2i(1,  0) * tile_size
	_sw.position = Vector2.ZERO
