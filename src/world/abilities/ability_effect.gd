@abstract
@icon("uid://bsynj7bxhunni")
class_name AbilityEffect
extends Resource

## An effect of an [Ability].

## Applies the effect.
@abstract func run(data: AbilityData) -> void


## Gets a utility score for the effect.
@abstract func utility_score(data: AbilityData) -> float
