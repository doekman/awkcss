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
# -=[ internal functions ]=-
function _warning(property, value) {
	printf "‼️ %s value '%s' is not recognized and will be ignored\n", property, value, reason > "/dev/stderr";
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
function _set_property(property_name, property_value) {
	_BAT[NR, property_name] = property_value;
}
function _append_property(property_name, property_value		, the_value) {
	if ((NR, property_name) in _BAT)
		the_value = _BAT[NR, property_name] ";";
	_BAT[NR, property_name] = the_value property_value;
}
function _get_property(property_name) {
	if ((NR, property_name) in _BAT) 
		return _BAT[NR, property_name];
	if ((0, property_name) in _BAT)
		return _BAT[0, property_name];
}
function _append_get_property(property_name		, result) {
	result = (0, property_name) in _BAT ? _BAT[0, property_name] : "";
	if ((NR, property_name) in _BAT) {
		result = result (length(result) > 0 ? ";" : "") _BAT[NR, property_name];
	}
	return result;
}
# -=[ Public properties ]=-
function display(value) {
	if (("display", value) in _ENUM)
		_set_property("display", _ENUM["display",value]);
	else
		_warning("display", value);
}
function tab_size(value) {
	if (value == "") 
		_set_property("tab_size", 8);
	else if (value >= 0 && value==int(value))
		_set_property("tab_size", int(value));
	else
		_warning("tab_size", value);
}
function width(value) {
	if (value == "")
		_set_property("width", COLS);
	else if (value > 0 && value==int(value))
		_set_property("width", int(value));
	else
		_warning("width", value);
}
function white_space(value) {
	#printf "WS[%s:%s]", NR, value
	if (("white_space", value) in _ENUM)
		_set_property("white_space", _ENUM["white_space", value]);
	else
		_warning("white_space", value);
}
function color(value) {
	if (("color", value) in _ENUM)
		_append_property("ansi_codes", 30+_ENUM["color", value])
	else
		_warning("color", value);
}
function background_color(value) {
	if (("color", value) in _ENUM)
		_append_property("ansi_codes", 40+_ENUM["color", value])
	else
		_warning("background_color", value);
}
function text_decoration_line2(value) {
	if (("text_decoration_line", value) in _ENUM)
		_append_property("ansi_codes", _ENUM["text_decoration_line", value])
	else
		_warning("text_decoration_line", value);
}
function text_decoration_line(value1, value2) {
	text_decoration_line2(value1);
	if (value2) text_decoration_line2(value2);
}
function text_decoration(value1, value2) {
	text_decoration_line(value1, value2);
}
function font_weight(value) {
	if (("font_weight", value) in _ENUM)
		_append_property("ansi_codes", _ENUM["font_weight", value])
	else
		_warning("font_weight", value);
}
function text_overflow(value) {
	if (("text_overflow", value) in _ENUM)
		_set_property("text_overflow", _ENUM["text_overflow", value]);
	else
		_set_property("text_overflow", value); # Use supplied string as text-overflow (experimental)
}
