{
	_index = 0;
	while (_index <= length($0)) {
		_line = substr($0, _index + 1, _content_width);
		_index += _content_width;
		printf "%-" _content_width "s\n", _line;
	}
	printf "%s", "\033[0m";
}
