class_name PlayerInput
extends Node

signal targeting_started(ability: Ability)
signal turn_action_selected(action: TurnAction)

@export var cheats_enabled := false

var player: Actor

@onready var _timer: Timer = $Timer


var active := false:
	set(value):
		active = value
		set_process(value)
		set_process_unhandled_input(value)


func _ready() -> void:
	active = false


func _unhandled_input(event: InputEvent) -> void:
	if cheats_enabled and event.is_action_pressed("click"):
		player.origin_cell = player.map.mouse_cell


func _process(_delta: float) -> void:
	if not _timer.is_stopped():
		return

	if Input.is_action_just_pressed("wait"):
		_select_action(null)
		return

	var move_vector := MovementInput.input_move_vect()
	if move_vector == Vector2i.ZERO:
		return

	if _try_bump_attack(move_vector):
		return

	var next_cell := player.origin_cell + move_vector

	var possible_actions: Array[TurnAction] = [
		MoveAction.new(player, next_cell),
		UseObjectAction.new(
			player.map.get_useable_object_on_cell(next_cell), player.map
		)
	]

	var action := CompositeTurnAction.new(
		possible_actions
	)
	action.wait_if_failed = false
	_select_action(action)


func _try_bump_attack(move_vector: Vector2i) -> bool:
	if player.abilities.attack.targeting_config.target_type \
			!= TargetType.Type.ACTOR:
		return false
	if move_vector.length_squared() != 1:
		return false

	var result := false

	var direction := Directions.dir_to_cardinal(move_vector)
	var edge_cells := TileGeometry.adjacent_edge_cells(
			player.cell_rect, direction)
	var other_actors := player.map.get_actors_on_cells(edge_cells)
	var target_actors := other_actors.filter(
		func (actor: Actor) -> bool:
			return player.abilities.attack.targeting_config.target_is_valid(
					player, actor.origin_cell)
	)

	if target_actors.size() == 1:
		var attack = player.abilities.create_attack_action(
			target_actors[0].origin_cell
		)
		_select_action(attack)
		result = true
	elif not target_actors.is_empty():
		targeting_started.emit(player.abilities.attack)
		result = true

	return result


func _select_action(action: TurnAction) -> void:
	turn_action_selected.emit(action)
	_timer.start()
