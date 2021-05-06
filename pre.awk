BEGIN {
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

	# state
	width();
	white_space("pre_wrap");
	text_overflow("clip");
}
function warning(property, value) {
	printf "‼️ %s value '%s' is unknown and will be ignored\n", property, value > "/dev/stderr";
}
function _set_ansi_code(value) {
	if (length(_ansi_codes) > 0)
		_ansi_codes = _ansi_codes ";" value;
	else
		_ansi_codes = value;
}
function width(value) {
	if (value == "") 
		_content_width = COLS
	else
		_content_width = value
}
function white_space(value) {
	if (value in _WHITE_SPACE)
		_do_word_wrap = _WHITE_SPACE[value];
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
		_text_overflow = _TEXT_OVERFLOW[value];
	else
		_text_overflow = "" value;
}
