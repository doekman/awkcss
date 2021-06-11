function _print_line(text, from_index		, pos, tab_size, terminal_line, text_overflow, text_overflow_parts) {
	terminal_line = substr(text, from_index + 1, get_property("width"));
	# insert tabs
	while (1) {
		if ((pos = index(terminal_line, "\t")) == 0)
			break;
		tab_size = get_property("tab_size");
		tab_size = tab_size - (pos - 1) % tab_size;
		#printf "%s:%s=%s]", pos, get_property("tab_size"), tab_size
		sub("\t", sprintf("%" tab_size "s", ""), terminal_line);
	}
	text_overflow = get_property("text_overflow")
	if (! _do_word_wrap[here] && text_overflow && length(terminal_line) < length) {
		if (index(text_overflow, ",") > 0) {
			split(text_overflow, text_overflow_parts, ",") # because of UTF-8
		}
		else {
			text_overflow_parts[1] = length(text_overflow)
			text_overflow_parts[2] = text_overflow
		}
		terminal_line = substr(terminal_line, 0, length(terminal_line) - text_overflow_parts[1]) text_overflow_parts[2]
	}
	printf "\033[%sm%-" (get_property("width")) "s\033[0m\n", _ansi_codes[here], terminal_line;
}

function content(text) {
	_calculate_line_properties();
	if (get_property("display") == block) {
		if (get_property("white_space") == pre_wrap) {
			_index = 0;
			while (_index == 0 || _index < length(text)) {
				#printf "[%s]", _index
				_print_line(text, _index);
				_index += get_property("width");
			}
		}
		else {
			_print_line(text, 0);
		}
	}
}
# Main render rule
{
	content($0)
}
