class_name ActionButtons
extends HBoxContainer

signal ability_selected(ability: Ability)
signal use_object_selected

@onready var _ability_buttons := %AbilityButtons as AbilityButtons
@onready var _other_actions := %OtherActions as Control


var can_use_objects: bool:
	get:
		return _other_actions.visible
	set(value):
		_other_actions.visible = value


func set_abilities(abilities: Array[Ability]) -> void:
	_ability_buttons.set_abilities(abilities)


func _on_ability_buttons_ability_selected(ability: Ability) -> void:
	ability_selected.emit(ability)


func _on_use_button_pressed() -> void:
	use_object_selected.emit()
