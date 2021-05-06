function _print_line(text, from_index		, line, text_overflow_parts) {
	line = substr(text, from_index + 1, _content_width);
	if (! _do_word_wrap[here] && _text_overflow && length(line) < length(text)) {
		split(_text_overflow, text_overflow_parts, ",")
		line = substr(line, 0, length(line) - text_overflow_parts[1]) text_overflow_parts[2]
	}
	printf "\033[%sm%-" _content_width "s\033[0m\n", _ansi_codes, line;
}

# Main render rule
{
	_do_word_wrap[here] = NR in _do_word_wrap ? _do_word_wrap[NR] : _do_word_wrap[0];
	if (_do_word_wrap[here]) {
		_index = 0;
		while (_index <= length($0)) {
			#printf "[%s]", _index
			_print_line($0, _index);
			_index += _content_width;
		}
	}
	else {
		_print_line($0, 0);
	}
	_ansi_codes = ""; # reset
}
