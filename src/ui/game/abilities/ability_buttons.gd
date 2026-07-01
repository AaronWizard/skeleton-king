class_name AbilityButtons
extends HBoxContainer

signal ability_selected(ability: Ability)


func set_abilities(abilities: Array[Ability]) -> void:
	clear()
	for ability in abilities:
		var button := Button.new()
		button.icon = ability.icon
		button.pressed.connect(ability_selected.emit.bind(ability))
		add_child(button)


func clear() -> void:
	while get_child_count() > 0:
		var button := get_child(0)
		remove_child(button)
		button.free()
