class_name GameUI
extends Node

enum _State {
	MOVE,
	TARGET,
	TURN_RUNNING
}

@onready var _targeting_grid := $TargetingGrid as TargetingGrid
@onready var _player_input := $PlayerInput as PlayerInput

@onready var _ability_buttons := $CanvasLayer/AbilityButtons as AbilityButtons
@onready var _ability_info := $CanvasLayer/AbilityInfo as AbilityInfo

var _player: Actor
var _state := _State.TURN_RUNNING


func _ready() -> void:
	_set_state(_State.TURN_RUNNING)


func set_player(player: Actor, controller: PlayerController) -> void:
	_player = player
	_player_input.player = player
	_player_input.controller = controller
	_ability_buttons.set_abilities(_player.abilities.all_abilities)


func set_player_input_active() -> void:
	_set_state(_State.MOVE)


func _set_state(state: _State) -> void:
	_state = state
	match _state:
		_State.MOVE:
			_ability_buttons.visible = true
			_ability_info.visible = false
			_player_input.active = true
			_targeting_grid.clear()
		_State.TARGET:
			_ability_buttons.visible = false
			_ability_info.visible = true
			_player_input.active = false
		_State.TURN_RUNNING:
			_ability_buttons.visible = true
			_ability_info.visible = false
			_player_input.active = false
			_targeting_grid.clear()


func _show_target_range(targeting_data: TargetingData) -> void:
	_targeting_grid.show_targeting(targeting_data)


func _on_player_input_turn_ended() -> void:
	_set_state(_State.TURN_RUNNING)


func _on_ability_buttons_ability_selected(ability: Ability) -> void:
	if _state != _State.MOVE:
		return

	var targeting_data := ability.get_targeting_data(_player)

	_ability_info.set_ability(
		ability.name, targeting_data.valid_targets.is_empty()
	)
	_show_target_range(targeting_data)
	_set_state(_State.TARGET)


func _on_ability_info_cancelled() -> void:
	_set_state(_State.MOVE)


func _on_targeting_grid_target_selected(target: Vector2i) -> void:
	if _state != _State.TARGET:
		return

	print("Selected target: ", target)
	_set_state(_State.MOVE)
