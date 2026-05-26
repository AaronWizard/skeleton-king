class_name AbilityTargetType

## The type of target the ability uses.

enum Type {
	## The ability's target is a single cell.
	CELL,
	## The ability's target is a whole actor.[br]
	## If a cell covered by an actor is used for the target, it is converted to
	## the actor's origin cell.
	ACTOR
}
