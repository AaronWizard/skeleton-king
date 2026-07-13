class_name GameUI
extends Node

enum _State {
	MOVE,
	TARGET,
	TURN_RUNNING
}

const _ACTION_USE_NAME := "Use"
const _ACTION_USE_TARGETING_CONFIG := preload("uid://d0vwau5s8b80u") \
		as TargetingConfig

@onready var _targeting_grid := $TargetingGrid as TargetingGrid
@onready var _player_input := $PlayerInput as PlayerInput

@onready var _action_buttons := %ActionButtons as ActionButtons
@onready var _action_info := %ActionInfo as ActionInfo

var _player: Actor
var _controller: PlayerController

var _state := _State.TURN_RUNNING

var _use_object_target_range: TargetingData = null

var _targeted_action_factory: TargetedActionFactory = null


func _ready() -> void:
	_set_state(_State.TURN_RUNNING)


func set_player(player: Actor, controller: PlayerController) -> void:
	_player = player
	_controller = controller

	_player_input.player = _player
	_action_buttons.set_abilities(_player.abilities.all_abilities)


func set_player_input_active(use_object_target_range: TargetingData) -> void:
	_use_object_target_range = use_object_target_range
	_action_buttons.can_use_objects = _use_object_target_range \
			and not _use_object_target_range.valid_targets.is_empty()

	_set_state(_State.MOVE)


func _set_state(state: _State) -> void:
	_state = state
	match _state:
		_State.MOVE:
			_targeted_action_factory = null
			_action_buttons.visible = true
			_action_info.visible = false
			_player_input.active = true
			_targeting_grid.clear()
		_State.TARGET:
			_action_buttons.visible = false
			_action_info.visible = true
			_player_input.active = false
		_State.TURN_RUNNING:
			_targeted_action_factory = null
			_action_buttons.visible = true
			_action_info.visible = false
			_player_input.active = false
			_targeting_grid.clear()


func _start_targeting(
		action_name: String,
		targetd_action_factory: TargetedActionFactory,
		targeting_data: TargetingData) -> void:
	if _state != _State.MOVE:
		return

	Log.print("Start targeting", Color.GOLD)

	_targeted_action_factory = targetd_action_factory

	_action_info.set_action(
		action_name, targeting_data.valid_targets.is_empty()
	)
	_targeting_grid.show_targeting(_player, targeting_data)
	_set_state(_State.TARGET)


func _end_turn(action: TurnAction) -> void:
	_controller.send_player_action(action)
	_set_state(_State.TURN_RUNNING)


func _on_player_input_targeting_started(
		action_name: String,
		targeted_action_factory: TargetedActionFactory,
		targeting_data: TargetingData) -> void:
	_start_targeting(action_name, targeted_action_factory, targeting_data)


func _on_player_input_turn_action_selected(action: TurnAction) -> void:
	_end_turn(action)


func _on_action_buttons_ability_selected(ability: Ability) -> void:
	_start_targeting(
		ability.name,
		AbilityActionFactory.new(_player, ability),
		ability.targeting_config.get_targeting_data(_player)
	)


func _on_action_buttons_use_object_selected() -> void:
	_start_targeting(
		_ACTION_USE_NAME,
		UseObjectActionFactory.new(_player),
		_ACTION_USE_TARGETING_CONFIG.get_targeting_data(_player)
	)


func _on_ability_info_cancelled() -> void:
	_set_state(_State.MOVE)


func _on_targeting_grid_target_selected(target: Vector2i) -> void:
	if _state != _State.TARGET:
		return

	_end_turn(_targeted_action_factory.create_action(target))
