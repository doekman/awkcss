BEGIN {
	# color & background_color
	_ENUM["color",   black="black"  ] = 0; # black
	_ENUM["color",     red="red"    ] = 1;
	_ENUM["color",   green="green"  ] = 2;
	_ENUM["color",  yellow="yellow" ] = 3;
	_ENUM["color",    blue="blue"   ] = 4;
	_ENUM["color", magenta="magenta"] = 5;
	_ENUM["color",    cyan="cyan"   ] = 6;
	_ENUM["color",   white="white"  ] = 7; # white
	# bright colors
	_ENUM["color",           gray="gray"          ] = 60;
	_ENUM["color",   bright_black="bright_black"  ] = 60;
	_ENUM["color",     bright_red="bright_red"    ] = 61;
	_ENUM["color",   bright_green="bright_green"  ] = 62;
	_ENUM["color",  bright_yellow="bright_yellow" ] = 63;
	_ENUM["color",    bright_blue="bright_blue"   ] = 64;
	_ENUM["color", bright_magenta="bright_magenta"] = 65;
	_ENUM["color",    bright_cyan="bright_cyan"   ] = 66;
	_ENUM["color",   bright_white="bright_white"  ] = 67; # bright_white
	# border_style (value is comma-splittable array, first value is encoding-type)
	# 1: telephone number pad, 1..9 (5 is empty) defines edge characters
	_ENUM["border_style",          none="none"]           = "0";
	_ENUM["border_style",         ascii="ascii"]          = "1,+,-,+,|,,|,+,-,+";
	_ENUM["border_style",   ascii_round="ascii_rounded"]  = "1,/,-,\\,|,,|,\\,_,/";
	# display
	_ENUM["display", block="block"] = block;
	_ENUM["display",  none="none" ] = none;
	# text_decoration_line
	_ENUM["text_decoration_line",      none="none"     ] = 24;
	_ENUM["text_decoration_line", underline="underline"] =  4;
	_ENUM["text_decoration_line",     blink="blink"    ] =  5;
	# font_weight
	_ENUM["font_weight", normal="normal"] = 21;
	_ENUM["font_weight",   bold="bold"  ] =  1;
	# white_space
	_ENUM["white_space", pre_wrap="pre_wrap"] = pre_wrap;
	_ENUM["white_space",      pre="pre"     ] = pre;
	# text_overflow
	_ENUM["text_overflow",     clip="clip"    ] = "";
	_ENUM["text_overflow", ellipsis="ellipsis"] = "1,…"; #because of UTF-8, "<char-lenght>,<characters>"
	
	# Initialize
	select();
	_STATE["last_vertical_margin"] = 0;  # for use with margin collapse, and block continuation
	_STATE["last_block_name"] = "";     # determine if a line is a block continuation
	_STATE["border_row"] = 0; # 0 undefined, 1 border-top, 2 inside border, 3 border-bottom
}

# section is gemodelleerd naar console.group()
# https://developer.mozilla.org/en-US/docs/Web/API/Console#using_groups_in_the_console
# TODO: optioneel een sectionEnd (die wordt inpliciet aangeroepen bij een nieuwe "value" binnen "scope")
function section(scope, value) {
	if (scope in _section)
		if (_section[scope] == value)
			return 0;
	_section[scope] = value;
	return ! 0;
}
function count(ch		, a) {
	split($0, a, ch);
	return length(a) - 1;
}
function str_mul(str, nr) {
	res = sprintf("%" nr "s", " ");
	gsub(" ", str, res);
	return res;
}
function _no_arg_(value) {
	return (value=="") && (value==0)
}
# -=[ internal functions ]=-
function _warning(property, value, message) {
	if (_no_arg_(message))
		printf "‼️ %s value '%s' is not recognized and will be ignored\n", property, value > "/dev/stderr";
	else
		printf "‼️ %s with value '%s': %s\n", property, value, message > "/dev/stderr";
}
# _BAT == Big AwkCss Table
function _bat_debug(dump_line		,title, key_combined, key_separate, property_value) {
	title = sprintf("---[ BAT DUMP %s ]---", dump_line);
	print title str_mul("-", COLS - length(title));
	for ( key_combined in _BAT) {
		split(key_combined, key_separate, SUBSEP);
		if (dump_line == "*" || dump_line == key_separate[1]) {
			property_value = _BAT[key_separate[1], key_separate[2], key_separate[3]];
			gsub("\t", "\\t", property_value)
			printf "%s,%s,%s=='%s' (len:%s)\n", key_separate[1], key_separate[2], key_separate[3], property_value, length(property_value);
		}
	}
}
# Property setters/getters
function _has_property_bare(nr, query, property_name) {
	return (nr, query, property_name) in _BAT;
}
function _get_property_bare(nr, query, property_name) {
	return _BAT[nr, query, property_name];
}
function _set_property_bare(nr, query, property_name, property_value) {
	_BAT[nr, query, property_name] = property_value;
}
function _has_property(property_name) {
	return _has_property_bare(NR, _QUERY, property_name);
}
function _get_property(property_name) {
	if (_has_property_bare(NR, _QUERY, property_name))
		return _get_property_bare(NR, _QUERY, property_name);
	if (_has_property_bare(NR, "", property_name))
		return _get_property_bare(NR, "", property_name);
	if (_has_property_bare(0, "", property_name))
		return _get_property_bare(0, "", property_name);
}
function _set_property(property_name, property_value) {
	_set_property_bare(NR, _QUERY, property_name, property_value)
}

function get_border_glyph(style, part		, items, glyph_index) {
	split(_ENUM["border_style", style], items, ",");
	if (items[0] == "0" || _STATE["border_row"] == 0) {
		return "";
	}
	glyph_index = (_STATE["border_row"] - 1) * 3 + (part + 1);
	#printf("(%s,%s,%s,%s,%s)", style, _STATE["border_row"], part, glyph_index, items[glyph_index])
	return items[glyph_index];
}
# -=[ Public functions ]=-
function select(query) {
	if (query) {
		if (query ~ /^::(before|after)$/) {
			_QUERY = query;
		}
		else {
			_warning("select", query);
			return 0; # False
		}
	}
	else {
		_QUERY = "";
	}
	return ! 0;
}

# -=[ Public properties ]=-

function block_name(value) {
	if (value)
		_set_property("block_name", value);
	else
		_warning("block_name", value, "You need to supply a value");
}
function _get_current_block_name() {
	if (_has_property_bare(NR, _QUERY, "block_name"))
		return _get_property_bare(NR, _QUERY, "block_name");
	return "" NR; # when no name specified, use line number as name
}

# stylize text
function color(value) {
	if (("color", value) in _ENUM)
		_set_property("color", 30+_ENUM["color", value]);
	else
		_warning("color", value);
}
function background_color(value) {
	if (("color", value) in _ENUM)
		_set_property("background_color", 40+_ENUM["color", value]);
	else
		_warning("background_color", value);
}
	function _text_decoration_line2(value, sequence_nr) {
		if (("text_decoration_line", value) in _ENUM)
			_set_property("text_decoration_line-" sequence_nr, _ENUM["text_decoration_line", value]);
		else
			_warning("text_decoration_line", value);
	}
function text_decoration_line(value1, value2) {
	_text_decoration_line2(value1, 1);
	if (value2) _text_decoration_line2(value2, 2);
}
function text_decoration(value1, value2) {
	text_decoration_line(value1, value2);
}
function font_weight(value) {
	if (("font_weight", value) in _ENUM)
		_set_property("background_color", _ENUM["font_weight", value]);
	else
		_warning("font_weight", value);
}

function _set_property__length(name, value, default_value) {
	if (value == "")
		value = default_value
	if (value==int(value))
		_set_property(name, int(value));
	else
		_warning(name, value);
}
function width(value) {
	if (value == "")
		_set_property("width", COLS);
	else if (value > 0 && value==int(value))
		_set_property("width", int(value));
	else
		_warning("width", value);
}
function tab_size(value) {
	if (value == "") 
		_set_property("tab_size", 8);
	else if (value >= 0 && value==int(value))
		_set_property("tab_size", int(value));
	else
		_warning("tab_size", value);
}
function margin_top(value) {
	_set_property__length("margin_top", value); 
}
function margin_right(value) {
	_set_property__length("margin_right", value); 
}
function margin_bottom(value) {
	_set_property__length("margin_bottom", value); 
}
function margin_left(value) {
	_set_property__length("margin_left", value); 
}
function margin(top, right, bottom, left) {
	if (_no_arg_(top))
		_warning("margin", ""); # margin needs at least one value
	else if (_no_arg_(right)) {
		margin_top(top);
		margin_right(top);
		margin_bottom(top);
		margin_left(top);
	}
	else if (_no_arg_(bottom)) {
		margin_top(top);
		margin_right(right);
		margin_bottom(top);
		margin_left(right);
	}
	else if (_no_arg_(left)) {
		margin_top(top);
		margin_right(right);
		margin_bottom(bottom);
		margin_left(right);
	}
	else  {
		margin_top(top);
		margin_right(right);
		margin_bottom(bottom);
		margin_left(left);
	}
}
function border_style_top(style) {
	if (style==unset || ("border_style", style) in _ENUM)
		_set_property("border_style_top", style);
	else
		_warning("border_style_top", style);
}
function border_style_right(style) {
	if (style==unset || ("border_style", style) in _ENUM)
		_set_property("border_style_right", style);
	else
		_warning("border_style_right", style);
}
function border_style_bottom(style) {
	if (style==unset || ("border_style", style) in _ENUM)
		_set_property("border_style_bottom", style);
	else
		_warning("border_style_bottom", style);
}
function border_style_left(style) {
	if (style==unset || ("border_style", style) in _ENUM)
		_set_property("border_style_left", style);
	else
		_warning("border_style_left", style);
}
function border_style(style) {
	if (style==unset || ("border_style", style) in _ENUM) {
		border_style_top(style);
		border_style_right(style);
		border_style_bottom(style);
		border_style_left(style);
	}
	else
		_warning("border_style", value);
}
function border(style) {
	if (_no_arg_(style))
		_warning("border", ""); # border needs at least one value
	else {
		border_style(style);
	}
}

function display(value) {
	if (("display", value) in _ENUM)
		_set_property("display", _ENUM["display",value]);
	else
		_warning("display", value);
}
function white_space(value) {
	#printf "WS[%s:%s]", NR, value
	if (("white_space", value) in _ENUM)
		_set_property("white_space", _ENUM["white_space", value]);
	else
		_warning("white_space", value);
}
function text_overflow(value) {
	if (("text_overflow", value) in _ENUM)
		_set_property("text_overflow", _ENUM["text_overflow", value]);
	else
		_set_property("text_overflow", value); # Use supplied string as text-overflow (experimental)
}

function content(value		, display_value) {
	_set_property("content", value);
	if (_QUERY ~ /^::(before|after)$/) {
		# Optimization, so renderer can quickly see if there is before/after-work.
		if (_has_property("display")) {
			display_value = _get_property("display");
		}
		else {
			display_value = "block"; # default value
		}
		_set_property_bare(NR, "", _QUERY, display_value);
	}
}
