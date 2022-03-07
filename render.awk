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
function _print_border_line(text, from_index, current_width		, border_part, border_glyph, chars_consumed) {
	border_part = _get_property("border_style_left");
	if (border_part) {
		if (current_width <= 2) {
			_warning("border_style_left", border_part, "Ignored, because width is too small.")
		}
		else {
			border_glyph = get_border_glyph(border_part, 1);
			printf("%s", border_glyph);
			current_width -= length(border_glyph);
		}
	}
	border_part = _get_property("border_style_right");
	if (border_part) {
		if (current_width <= 2) {
			_warning("border_style_right", border_part, "Ignored, because width is too small.")
		}
		else {
			border_glyph = get_border_glyph(border_part, 3);
			current_width -= length(border_glyph);
		}
	}
	chars_consumed = _print_inline_block(text, from_index, current_width)
	if (border_part) {
		printf("%s", border_glyph);
	}
	return chars_consumed;
}
function _print_margin_line(text, from_index		, current_width, left_margin, right_margin, chars_consumed) {
	current_width = _get_property("width");
	left_margin = _get_property("margin_left");
	if (left_margin >= current_width) {
		_warning("margin_left", left_margin, "Ignored, because width is too small.")
		left_margin = 0;
	}
	else if (left_margin > 0) {
		printf("%" left_margin "s", " ");
		current_width -= left_margin
	}
	right_margin = _get_property("margin_right");
	if (right_margin >= current_width) {
		_warning("margin_right", right_margin, "Ignored, because width is too small.")
		right_margin = 0;
	}
	else if (right_margin > 0) {
		current_width -= right_margin
	}
	chars_consumed = _print_border_line(text, from_index, current_width)
	if (right_margin > 0) {
		printf("%" right_margin "s", " ");
	}
	printf "\n";
	return chars_consumed;
}
function _print_vertical_margin(margin_property_name		, value) {
	if (margin_property_name == "margin_bottom") {
		value = _STATE["last_vertical_margin"];
		NR -= 1; # margin_bottom belongs to previous line
	}
	else { #if (margin_property_name == "margin_top")
		value = _get_property(margin_property_name);
		value = value - _STATE["last_vertical_margin"]
		_STATE["last_vertical_margin"] = _get_property("margin_bottom");
	}
	while (value > 0) {
		_print_margin_line("", 0);
		value -= 1;
	}
	if (margin_property_name == "margin_bottom") {
		NR += 1; # restore
	}
}
function _print_vertical_border(border_side		, border_style, border_width, border_glyph, border_corner_width) {
	if (border_side == "bottom") {
		NR -= 1;
	}
	border_width = _get_property("width") - _get_property("margin_left") - _get_property("margin_right");
	if (border_side == "bottom") {
		border_style = _get_property("border_style_bottom");
		_STATE["border_row"] = 3;
		border_glyph = get_border_glyph(border_style, 2);
		if (border_glyph) {
			border_corner_width = length(get_border_glyph(_get_property("border_style_left"), 1) get_border_glyph(_get_property("border_style_right"), 3))
			_print_margin_line(str_mul(border_glyph, border_width - border_corner_width), 0);
		}
	}
	else { # border_side == "top"
		border_style = _get_property("border_style_top");
		_STATE["border_row"] = 1;
		border_glyph = get_border_glyph(border_style, 2);
		if (border_glyph) {
			border_corner_width = length(get_border_glyph(_get_property("border_style_left"), 1) get_border_glyph(_get_property("border_style_right"), 3))
			_print_margin_line(str_mul(border_glyph, border_width - border_corner_width), 0);
		}
	}
	if (border_side == "bottom") {
		NR += 1;
	}
}
function _close_box() {
	_print_vertical_border("bottom");
	_print_vertical_margin("margin_bottom");
}
function _print_margin_box(		text, last_block_name, current_block_name) {
	if (_get_property("display") == block) {
		if (_has_property("content")) {
			text = _get_property("content");
		}
		else {
			text = $0;
		}
		last_block_name = _STATE["last_block_name"];
		current_block_name = _get_current_block_name();
		# We only know whether to print a bottom_margin, when the next line DOESN'T belong
		# to the next block, so we need to buffer this.
		if (NR > 1 && last_block_name != current_block_name) {
			_close_box();
		}

		if (last_block_name != current_block_name) {
			_print_vertical_margin("margin_top");
			_print_vertical_border("top");
		}
		_STATE["border_row"] = 2;
		if (_get_property("white_space") == pre_wrap) {
			_index = 0;
			while (_index == 0 || _index < length(text)) {
				_index += _print_margin_line(text, _index);
			}
		}
		else { # white_space == pre, just print what fits
			_print_margin_line(text, 0);
		}
		_STATE["last_block_name"] = current_block_name;
	}
}
# Main render rule
{
	select();
	if (_get_property("::before") == "block") {
		select("::before");
		_print_margin_box();
		select();
	}
	_print_margin_box(); # handle main line
	if (_get_property("::after") == "block") {
		select("::after");
		_print_margin_box();
		select();
	}
}

END {
	# We need to close the last box
	NR += 1;
	_close_box();
	NR -= 1;
	if (_DUMP != "") {
		_bat_debug(_DUMP);
	}
}
