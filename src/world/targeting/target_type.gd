class_name TargetType

## The type of cells an action targets.

enum Type {
	## The action's target is a single cell.[br]
	## All cells in the targets base target range are valid targets.
	CELL,
	## The action's target is a whole actor.[br]
	## The valid targets of an action with a target type of [enum ACTOR] are
	## the origin cells of all actors overlapping the action's base target
	## range.
	ACTOR,
	## The action's target is a useable object.[br]
	## Like [enum ACTOR], the valid targets of an action with a target type of
	## [enum OBJECT] are the origin cells of all useable objects overlapping the
	## action's base target range.
	OBJECT
}
