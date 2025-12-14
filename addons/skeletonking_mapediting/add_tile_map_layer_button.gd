@tool
class_name AddTileMapLayerButton
extends Button

var undo_redo: EditorUndoRedoManager = null
var terrain_node: Node = null


func _on_pressed() -> void:
	if not terrain_node:
		push_error("No terrain node selected")
		return

	undo_redo.create_action("New TileMapLayer")

	var new_layer := TileMapLayer.new()

	undo_redo.add_do_method(self, "_add_layer", terrain_node, new_layer)
	undo_redo.add_undo_method(self, "_remove_layer", terrain_node, new_layer)

	undo_redo.commit_action()


static func _add_layer(node: Node, layer: TileMapLayer) -> void:
	node.add_child(layer, true)
	layer.owner = node.owner


static func _remove_layer(node: Node, layer: TileMapLayer) -> void:
	node.remove_child(layer)
