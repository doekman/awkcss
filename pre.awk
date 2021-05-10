BEGIN {
	# symbols
	here = "here";

	# color & background_color
	_COLORS[  black="black"  ] = 0; # black
	_COLORS[    red="red"    ] = 1;
	_COLORS[  green="green"  ] = 2;
	_COLORS[ yellow="yellow" ] = 3;
	_COLORS[   blue="blue"   ] = 4;
	_COLORS[magenta="magenta"] = 5;
	_COLORS[   cyan="cyan"   ] = 6;
	_COLORS[  white="white"  ] = 7; # white

	_COLORS[           gray="gray"         ] = 60; # bright_black
	_COLORS[    bright_red="bright_red"    ] = 61;
	_COLORS[  bright_green="bright_green"  ] = 62;
	_COLORS[ bright_yellow="bright_yellow" ] = 63;
	_COLORS[   bright_blue="bright_blue"   ] = 64;
	_COLORS[bright_magenta="bright_magenta"] = 65;
	_COLORS[   bright_cyan="bright_cyan"   ] = 66;
	_COLORS[  bright_white="bright_white"  ] = 67; # bright_white

	# text_decoration_line
	_TEXT_DECORATION_LINE[     none="none"     ] = 24;
	_TEXT_DECORATION_LINE[underline="underline"] =  4;
	_TEXT_DECORATION_LINE[    blink="blink"    ] =  5;

	# font_weight
	_FONT_WEIGHT[ normal="normal"] = 21;
	_FONT_WEIGHT[   bold="bold"  ] =  1;

	# white_space
	_WHITE_SPACE[pre_wrap="pre_wrap"] = ! 0; #  TRUE == word_wrap
	_WHITE_SPACE[     pre="pre"     ] = 0;   # FALSE == word_wrap

	# text_overflow
	_TEXT_OVERFLOW[    clip="clip"    ] = "";
	_TEXT_OVERFLOW[ellipsis="ellipsis"] = "1,…"; #because of UTF-8, "<char-lenght>,<characters>"
}
# https://developer.mozilla.org/en-US/docs/Web/API/Console#using_groups_in_the_console
# TODO: hernoemen naar `section` (een nieuwe groep begint bij een nieuwe naam?)
# TOO: optioneel een groupEnd (die wordt inpliciet aangeroepen bij een nieuwe "value" binnen "scope")
function group(scope, value) {
	if (scope in _group)
		if (_group[scope] == value)
			return 0;
	_group[scope] = value;
	return ! 0;
}
function str_mul(str, nr) {
	res = sprintf("%" nr "s", " ");
	gsub(" ", str, res);
	return res;
}
function warning(property, value) {
	printf "‼️ %s value '%s' is unknown and will be ignored\n", property, value > "/dev/stderr";
}
function _calculate_line_property(line_property) {
	# The basis of the cascade
	line_property[here] = NR in line_property ? line_property[NR] : line_property[0];
}
function _calculate_line_properties() {
	_calculate_line_property(_content_width);
	_calculate_line_property(_do_word_wrap);
	_calculate_line_property(_text_overflow);
	# TODO: system defined ansi-codes now can be overwritten by user defined codes.
	# Undesireable because multiple CSS properties are stored in the same structure.
	_ansi_codes[here] = 0 in _ansi_codes ? _ansi_codes[0] : "";
	if (NR in _ansi_codes) {
		_ansi_codes[here] = _ansi_codes[here] (length(_ansi_codes[here]) > 0 ? ";" : "") _ansi_codes[NR]
	}
}
function _set_ansi_code(value) {
	if (length(_ansi_codes[NR]) > 0)
		_ansi_codes[NR] = _ansi_codes[NR] ";" value;
	else
		_ansi_codes[NR] = value;
}
function width(value) {
	#printf "WIDTH[%s:%s]", NR, value
	if (value == "") 
		_content_width[NR] = COLS
	else
		_content_width[NR] = value
}
function white_space(value) {
	#printf "WS[%s:%s]", NR, value
	if (value in _WHITE_SPACE)
		_do_word_wrap[NR] = _WHITE_SPACE[value];
	else
		warning("color", value);
}
function color(value) {
	if (value in _COLORS)
		_set_ansi_code(30+_COLORS[value])
	else
		warning("color", value);
}
function background_color(value) {
	if (value in _COLORS)
		_set_ansi_code(40+_COLORS[value])
	else
		warning("color", value);
}
function text_decoration_line(value) {
	if (value in _TEXT_DECORATION_LINE)
		_set_ansi_code(_TEXT_DECORATION_LINE[value])
	else
		warning("text_decoration_line", value);
}
function text_decoration(value) {
	text_decoration_line(value);
}
function font_weight(value) {
	if (value in _FONT_WEIGHT)
		_set_ansi_code(_FONT_WEIGHT[value])
	else
		warning("font_weight", value);
}
function text_overflow(value) {
	if (value in _TEXT_OVERFLOW)
		_text_overflow[NR] = _TEXT_OVERFLOW[value];
	else
		_text_overflow[NR] = value; # Use supplied string as text-overflow (experimental)
}
