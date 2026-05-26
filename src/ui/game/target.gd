@tool
extends RectTileObject

@onready var _nw := $NWSprite as Node2D
@onready var _ne := $NESprite as Node2D
@onready var _se := $SESprite as Node2D
@onready var _sw := $SWSprite as Node2D


func _ready() -> void:
	_position_corners()


func _tile_size_changed() -> void:
	_position_corners()


func _cell_size_changed() -> void:
	_position_corners()


func _position_corners() -> void:
	_nw.position = cell_rect.size * Vector2i(0, -1) * tile_size
	_ne.position = cell_rect.size * Vector2i(1, -1) * tile_size
	_se.position = cell_rect.size * Vector2i(1,  0) * tile_size
	_sw.position = Vector2.ZERO
