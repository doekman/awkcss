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

	# state
	_content_width = COLS
}
function warning(property, value) {
	printf "‼️ %s value '%s' is unknown and will be ignored\n", property, value > "/dev/stderr";
}
function width(value) {
	if (value == "")
		_content_width = COLS
	else
		_content_width = value
}
function color(value) {
	if (value in _colors)
		printf "\033[" (30+_colors[value]) "m";
	else
		warning("color", value);
}
function background_color(value) {
	if (value in _colors)
		printf "\033[" (40+_colors[value]) "m";
	else
		warning("color", value);
}
function text_decoration_line(value) {
	if (value in _text_decoration_line)
		printf "\033[" _text_decoration_line[value] "m";
	else
		warning("text_decoration_line", value);
}
function text_decoration(value) {
	text_decoration_line(value);
}
function font_weight(value) {
	if (value in _font_weight)
		printf "\033[" _font_weight[value] "m";
	else
		warning("font_weight", value);
}
