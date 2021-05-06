BEGIN {
	# color & background_color
	_colors[  black="black"  ] = 0; # black
	_colors[    red="red"    ] = 1;
	_colors[  green="green"  ] = 2;
	_colors[ yellow="yellow" ] = 3;
	_colors[   blue="blue"   ] = 4;
	_colors[magenta="magenta"] = 5;
	_colors[   cyan="cyan"   ] = 6;
	_colors[  white="white"  ] = 7; # white

	_colors[           gray="gray"         ] = 60; # bright_black
	_colors[    bright_red="bright_red"    ] = 61;
	_colors[  bright_green="bright_green"  ] = 62;
	_colors[ bright_yellow="bright_yellow" ] = 63;
	_colors[   bright_blue="bright_blue"   ] = 64;
	_colors[bright_magenta="bright_magenta"] = 65;
	_colors[   bright_cyan="bright_cyan"   ] = 66;
	_colors[  bright_white="bright_white"  ] = 67; # bright_white

	# text_decoration_line
	_text_decoration_line[     none="none"     ] = 24;
	_text_decoration_line[underline="underline"] =  4;
	_text_decoration_line[    blink="blink"    ] =  5;

	# font_weight
	_font_weight[ normal="normal"] = 21;
	_font_weight[   bold="bold"  ] =  1;

	# white_space
	_white_space[pre_wrap="pre_wrap"] = ! 0; #  TRUE == word_wrap
	_white_space[     pre="pre"     ] = 0;   # FALSE == word_wrap

	# text_overflow
	_TEXT_OVERFLOW[    clip="clip"    ] = "";
	_TEXT_OVERFLOW[ellipsis="ellipsis"] = "1,…"; #because of UTF-8, "<char-lenght>,<characters>"

	# state
	_ansi_codes = ""; 
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
	if (value in _white_space)
		_do_word_wrap = _white_space[value];
	else
		warning("color", value);
}
function color(value) {
	if (value in _colors)
		_set_ansi_code(30+_colors[value])
	else
		warning("color", value);
}
function background_color(value) {
	if (value in _colors)
		_set_ansi_code(40+_colors[value])
	else
		warning("color", value);
}
function text_decoration_line(value) {
	if (value in _text_decoration_line)
		_set_ansi_code(_text_decoration_line[value])
	else
		warning("text_decoration_line", value);
}
function text_decoration(value) {
	text_decoration_line(value);
}
function font_weight(value) {
	if (value in _font_weight)
		_set_ansi_code(_font_weight[value])
	else
		warning("font_weight", value);
}
function text_overflow(value) {
	if (value in _TEXT_OVERFLOW)
		_text_overflow = _TEXT_OVERFLOW[value];
	else
		_text_overflow = "" value;
}
