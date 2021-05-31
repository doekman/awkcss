function _print_line(text, from_index		, pos, tab_size, terminal_line, text_overflow_parts) {
	terminal_line = substr(text, from_index + 1, _width[here]);
	# insert tabs
	while (1) {
		if ((pos = index(terminal_line, "\t")) == 0)
			break;
		tab_size = _tab_size[here] - (pos - 1) % _tab_size[here]
		#printf "%s:%s=%s]", pos, _tab_size[here], tab_size
		sub("\t", sprintf("%" tab_size "s", ""), terminal_line)
	}
	if (! _do_word_wrap[here] && _text_overflow[here] && length(terminal_line) < length) {
		if (index(_text_overflow[here], ",") > 0) {
			split(_text_overflow[here], text_overflow_parts, ",") # because of UTF-8
		}
		else {
			text_overflow_parts[1] = length(_text_overflow[here])
			text_overflow_parts[2] = _text_overflow[here]
		}
		terminal_line = substr(terminal_line, 0, length(terminal_line) - text_overflow_parts[1]) text_overflow_parts[2]
	}
	printf "\033[%sm%-" (_width[here]) "s\033[0m\n", _ansi_codes[here], terminal_line;
}

function content(text) {
	_calculate_line_properties();
	if (_display[here] == block) {
		if (_white_space[here] == pre_wrap) {
			_index = 0;
			while (_index == 0 || _index < length(text)) {
				#printf "[%s]", _index
				_print_line(text, _index);
				_index += _width[here];
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
