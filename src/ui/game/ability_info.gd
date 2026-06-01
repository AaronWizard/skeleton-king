class_name AbilityInfo
extends HBoxContainer

signal cancelled

@onready var _label := $PanelContainer/Label as Label


func set_ability(ability: Ability) -> void:
	_label.text = ability.name


func _on_cancel_pressed() -> void:
	cancelled.emit()
