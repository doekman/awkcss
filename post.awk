function _handle_text_overflow(terminal_line, width		, text_overflow, text_overflow_parts) {
	if (length(terminal_line) > width) {
		text_overflow = _get_property("text_overflow")
		if (text_overflow) {
			if (index(text_overflow, ",") > 0) {
				split(text_overflow, text_overflow_parts, ",") # because of UTF-8
			}
			else {
				text_overflow_parts[1] = length(text_overflow)
				text_overflow_parts[2] = text_overflow
			}
			return substr(terminal_line, 0, width - text_overflow_parts[1]) text_overflow_parts[2]
		}
		return substr(terminal_line, 0, width); # just clip the text
	}
	return terminal_line;
}

function _print_line(text, from_index		, width, terminal_line, pos, tab_size, tab_width, nr_tabs_inserted, ansi_codes) {
	width = _get_property("width");
	tab_size = _get_property("tab_size");
	terminal_line = substr(text, from_index + 1);
	# expand tabs
	nr_tabs_inserted = 0
	while (1) {
		pos = index(terminal_line, "\t");
		if (pos == 0 || pos > width - tab_size)
			break;
		tab_width = tab_size - (pos - 1) % tab_size;
		sub("\t", sprintf("%" tab_width "s", ""), terminal_line);
		nr_tabs_inserted += 1;
	}
	terminal_line = _handle_text_overflow(terminal_line, width);
	# output the line
	printf "\033[%sm%-" (_get_property("width")) "s\033[0m\n", _append_get_property("ansi_codes"), terminal_line;
	return width - ( (tab_size - 1) * nr_tabs_inserted)
}
# TODO: convert 'content' to property (with ::before and ::after selectors)
function content(text) {
	if (_get_property("display") == block) {
		if (_get_property("white_space") == pre_wrap) {
			_index = 0;
			while (_index == 0 || _index < length(text)) {
				_index += _print_line(text, _index);
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
