class_name TargetType

## The type of cells an ability targets.

enum Type {
	## The ability's target is a single cell.[br]
	## All cells in the targets base target range are valid targets.
	CELL,
	## The ability's target is a whole actor.[br]
	## The valid targets of an ability with a target type of [enum ACTOR] are
	## the origin cells of all actors overlapping the ability's base target
	## range.
	ACTOR
}
