class_name Stamina

signal stamina_changed(delta: int)


var max_stamina: int:
	get:
		return _max_stamina


var current_stamina: int:
	set(value):
		var old_stamina := _curent_stamina
		_curent_stamina = clamp(_curent_stamina + value, 0, _max_stamina)
		var delta := _curent_stamina - old_stamina
		if delta != 0:
			stamina_changed.emit(delta)


var is_alive: bool:
	get:
		return _curent_stamina > 0


var _max_stamina: int
var _curent_stamina: int


func init(p_max_stamina: int) -> void:
	_max_stamina = p_max_stamina
	_curent_stamina = p_max_stamina
