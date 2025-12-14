@tool
extends EditorPlugin

const _ADD_TILEMAPLAYER_BUTTON_SCENE = preload("uid://bvmv0pclmuw08")
const _LAYER_NAME_TERRAIN := "Terrain"

var _button: AddTileMapLayerButton = null


func _enter_tree() -> void:
	_create_button()
	EditorInterface.get_selection().selection_changed.connect(
			_selection_changed)


func _exit_tree() -> void:
	remove_control_from_container(
			EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU, _button)
	_button.queue_free()
	_button = null


func _create_button() -> void:
	_button = _ADD_TILEMAPLAYER_BUTTON_SCENE.instantiate() \
			as AddTileMapLayerButton
	_button.undo_redo = get_undo_redo()
	add_control_to_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU, _button)
	_button.hide()


func _selection_changed() -> void:
	if not _button:
		return

	var selected_nodes := EditorInterface.get_selection().get_selected_nodes()

	if selected_nodes.size() == 0:
		_button.terrain_node = null
		_button.hide()
		return

	var selected_node := selected_nodes[0]
	if (selected_node is Node2D) \
			and (selected_node.get_parent() is MapDesign) \
			and (selected_node.name == _LAYER_NAME_TERRAIN):
		_button.terrain_node = selected_node as Node2D
		_button.show()
	else:
		_button.terrain_node = null
		_button.hide()
