class_name MovementInput


static func input_move_vect() -> Vector2i:
	return Vector2i(Input.get_vector(
		"move_west", "move_east",
		"move_north", "move_south"
	))


static func event_move_vect(event: InputEvent) -> Vector2i:
	var result := Vector2i.ZERO

	if event.is_action_pressed("move_north"):
		result += Directions.cardinal_to_dir(Directions.Cardinal.NORTH)
	if event.is_action_pressed("move_east"):
		result += Directions.cardinal_to_dir(Directions.Cardinal.EAST)
	if event.is_action_pressed("move_south"):
		result += Directions.cardinal_to_dir(Directions.Cardinal.SOUTH)
	if event.is_action_pressed("move_west"):
		result += Directions.cardinal_to_dir(Directions.Cardinal.WEST)

	if result.length_squared() > 1:
		result = Vector2i.ZERO

	return result
