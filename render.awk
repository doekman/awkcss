function _escape_ansi_codes(ansi_codes) {
	return length(ansi_codes)>0 ? sprintf("\033[%sm", ansi_codes) : "";
}
function _get_ansi_codes(nr, query		, properties, i, ansi_codes) {
	split("color,background_color,text_decoration_line-1,text_decoration_line-2,font_weight", properties, ",");
	for (i in properties) {
		if (_has_property_bare(nr, query, properties[i])) {
			ansi_codes = ansi_codes ";" _get_property_bare(nr, query, properties[i]);
		}
	}
	return substr(ansi_codes, 2);
}
function _handle_text_overflow(text, width		, text_overflow, text_overflow_parts) {
	if (length(text) > width) {
		text_overflow = _get_property("text_overflow")
		if (text_overflow) {
			if (index(text_overflow, ",") > 0) {
				split(text_overflow, text_overflow_parts, ",") # because of UTF-8
			}
			else {
				text_overflow_parts[1] = length(text_overflow)
				text_overflow_parts[2] = text_overflow
			}
			return substr(text, 0, width - text_overflow_parts[1]) text_overflow_parts[2]
		}
		return substr(text, 0, width); # just clip the text
	}
	return text;
}

function _print_inline_block(text, from_index, width		, terminal_line, pos, tab_size, tab_width, nr_tabs_expanded, ansi_codes) {
	tab_size = _get_property("tab_size");
	terminal_line = substr(text, from_index + 1);
	# expand tabs
	nr_tabs_expanded = 0
	while (1) {
		pos = index(terminal_line, "\t");
		if (pos == 0 || pos > width - tab_size)
			break;
		tab_width = tab_size - (pos - 1) % tab_size;
		sub("\t", sprintf("%" tab_width "s", ""), terminal_line);
		nr_tabs_expanded += 1;
	}
	terminal_line = _handle_text_overflow(terminal_line, width);
	# output the line
	printf _escape_ansi_codes(_get_ansi_codes(0, _QUERY));
	printf _escape_ansi_codes(_get_ansi_codes(NR, _QUERY));
	printf "%-" width "s", terminal_line;
	printf _escape_ansi_codes("0");
	# return the number of characters of the original "text" variable where consumed
	return width - ( (tab_size - 1) * nr_tabs_expanded)
}
function _print_margin_box(text, from_index		, current_width, margin_part, chars_consumed) {
	current_width = _get_property("width");
	margin_part = _get_property("margin_left");
	if (margin_part >= current_width) {
		_warning("margin_left", margin_part, "Ignored, because width is too small.")
		margin_part = 0;
	}
	if (margin_part > 0) {
		#printf("%d>%" margin_part "s", margin_part, " ");
		printf("%" margin_part "s", " ");
		current_width -= margin_part
	}
#	margin_part = _get_property("margin_right");
#	if (margin_part >= current_width) {
#		_warning("margin_right", margin_part, "Ignored, because width is too small.")
#		margin_part = 0;
#	}
#	if (margin_part > 0) {
#		current_width -= margin_part
#	}
	chars_consumed = _print_inline_block(text, from_index, current_width);
#	if (margin_part > 0) {
#		#printf("%" margin_part "s%<d", " ", margin_part);
#		printf("%" margin_part "s", " ");
#	}
	printf "\n";
	return chars_consumed;
}
function _handle_content(		text) {
	if (_get_property("display") == block) {
		if (_has_property("content")) {
			text = _get_property("content");
		}
		else {
			text = $0;
		}
		if (_get_property("white_space") == pre_wrap) {
			_index = 0;
			while (_index == 0 || _index < length(text)) {
				_index += _print_margin_box(text, _index);
			}
		}
		else {
			# white_space == pre, just print what fits
			_print_margin_box(text, 0);
		}
	}
}
# Main render rule
{
	select();
	if (_get_property("::before") == "block") {
		select("::before");
		_handle_content();
		select();
	}
	_handle_content(); # handle main line
	if (_get_property("::after") == "block") {
		select("::after");
		_handle_content();
		select();
	}
}

END {
	if (_DUMP != "") {
		_bat_debug(_DUMP);
	}
}
