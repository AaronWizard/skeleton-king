class_name ActionInfo
extends Control

signal cancelled

@onready var _label := %Label as Label
@onready var _no_valid_targets_panel := %NoValidTargetsPanel as Control


func set_action(action_name: String, no_valid_targets: bool) -> void:
	_label.text = action_name
	_no_valid_targets_panel.visible = no_valid_targets


func _on_cancel_pressed() -> void:
	cancelled.emit()
