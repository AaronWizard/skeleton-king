class_name AnimationTracker

signal animation_started
signal animations_finished


var animations_running: bool:
	get:
		return _anim_count > 0


var _anim_count := 0


func observe_actor(actor: Actor) -> void:
	actor.sprite.animation_started.connect(_on_animation_added)
	actor.sprite.animation_finished.connect(_on_animation_finished)


func unobserve_actor(actor: Actor) -> void:
	actor.sprite.animation_started.disconnect(_on_animation_added)
	actor.sprite.animation_finished.disconnect(_on_animation_finished)

	if actor.sprite.animation_playing:
		_on_animation_finished()


func _on_animation_added() -> void:
	_anim_count += 1
	if _anim_count == 1:
		animation_started.emit()


func _on_animation_finished() -> void:
	if _anim_count == 0:
		push_error("Animations not running")
		return
	_anim_count -= 1
	if _anim_count == 0:
		animations_finished.emit()
