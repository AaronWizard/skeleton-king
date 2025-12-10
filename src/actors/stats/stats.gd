class_name Stats

signal stamina_changed(delta: int)


var stamina: int:
	get:
		return _stamina
	set(value):
		var old_stamina := _stamina

		_stamina = clampi(_stamina + value, 0, max_stamina)

		var delta := _stamina - old_stamina
		if delta != 0:
			stamina_changed.emit(delta)


var is_alive:
	get:
		return _stamina > 0


var max_stamina: int:
	get:
		return _base_stats.max_stamina


var attack: int:
	get:
		return _base_stats.attack


var _base_stats: BaseStats

var _stamina := 0


func _init(p_base_stats: BaseStats) -> void:
	_base_stats = p_base_stats
	_stamina = _base_stats.max_stamina
