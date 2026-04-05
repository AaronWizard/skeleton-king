class_name PriorityQueue

var _heap: Array[_PriorityQueueItem] = []


## Add an item with a given priority.[br]
## Items with lower [param priority] values are at the front of the queue.
func push(item: Variant, priority: float) -> void:
	var entry := _PriorityQueueItem.new(item, priority)
	_heap.append(entry)
	_bubble_up(_heap.size() - 1)


## Remove and return the highest priority item.[br]
## Returns null if the queue is empty.
func pop() -> Variant:
	if is_empty():
		return null

	var result = _heap[0].item
	var last_index := _heap.size() - 1

	if last_index > 0:
		_heap[0] = _heap[last_index]
		_heap.remove_at(last_index)
		_bubble_down(0)
	else:
		_heap.clear()

	return result


## Check if the queue is empty.
func is_empty() -> bool:
	return _heap.is_empty()


## Clears the queue.
func clear() -> void:
	_heap.clear()


# Move an item up the heap
func _bubble_up(index: int) -> void:
	while index > 0:
		@warning_ignore("integer_division")
		var parent_index := (index - 1) / 2
		if _heap[index].priority < _heap[parent_index].priority:
			var temp := _heap[index]
			_heap[index] = _heap[parent_index]
			_heap[parent_index] = temp
			index = parent_index
		else:
			break


# Move an item down the heap
func _bubble_down(index: int) -> void:
	var size := _heap.size()

	while true:
		var highest_index := index
		var left_index := (2 * index) + 1
		var right_index := (2 * index) + 2

		if (left_index < size) \
				and (_heap[left_index].priority \
					< _heap[highest_index].priority):
			highest_index = left_index

		if (right_index < size) \
				and (_heap[right_index].priority \
					< _heap[highest_index].priority):
			highest_index = right_index

		if highest_index != index:
			var temp := _heap[index]
			_heap[index] = _heap[highest_index]
			_heap[highest_index] = temp
			index = highest_index
		else:
			break


class _PriorityQueueItem:
	var item: Variant
	var priority: float

	func _init(p_item: Variant, p_priority: float) -> void:
		item = p_item
		priority = p_priority
