class_name Log


static func print(message: String, colour := Color.WHITE) -> void:
	if not OS.is_debug_build():
		return

	var stack := get_stack()
	var latest_call := stack[1] as Dictionary
	var source := latest_call.source as String
	var line := latest_call.line as int

	print_rich(
		"[color=#%s]%s:%d[/color]" % [Color.WHITE.to_html(), source, line],
		'\t\t',
		"[color=#%s]%s[/color]" % [colour.to_html(), message]
	)
