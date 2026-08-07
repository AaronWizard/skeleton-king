class_name ParentMapTracker

## Keeps track of a node's parent map

var _self_node: Node

var _map: Map = null


func _init(self_node: Node) -> void:
	_self_node = self_node


func get_map() -> Map:
	return _map


func set_map(new_map: Map) -> bool:
	if _map == new_map:
		return false

	if _map and _map.is_ancestor_of(_self_node):
		push_error("Cannot change map for '%s' while it is still a child of " \
				+ "its current map" % _self_node.name)
		return false

	if new_map and not new_map.is_ancestor_of(_self_node):
		push_error("Cannot change map for '%s' to a map it is not a child of" \
				% _self_node.name)
		return false

	var result := _map != new_map
	_map = new_map
	return result
