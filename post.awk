function _print_line(from_index		, line, text_overflow_parts) {
	line = substr($0, from_index + 1, _content_width[here]);
	if (! _do_word_wrap[here] && _text_overflow[here] && length(line) < length) {
		split(_text_overflow[here], text_overflow_parts, ",")
		line = substr(line, 0, length(line) - text_overflow_parts[1]) text_overflow_parts[2]
	}
	printf "\033[%sm%-" (_content_width[here]) "s\033[0m\n", _ansi_codes[here], line;
}

# Main render rule
{
	_calculate_line_properties();
	if (_do_word_wrap[here]) {
		_index = 0;
		while (_index <= length) {
			#printf "[%s]", _index
			_print_line(_index);
			_index += _content_width[here];
		}
	}
	else {
		_print_line(0);
	}
}
