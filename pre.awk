BEGIN {
	# color & background_color
	black   = 0;
	red     = 1;
	green   = 2;
	yellow  = 3;
	blue    = 4;
	magenta = 5;
	cyan    = 6;
	white   = 7;
	gray    = 60;

	# text_decoration_line
	none      = 24;
	underline =  4;
	blink     =  5;

	# font_weight
	normal = 21;
	bold   =  1;

	# privates
	_content_width = COLS
}
function warning(property, value) {
	printf "%s value '%s' is unknown and will be ignored\n", property, value > "/dev/stderr";
}
function width(value) {
	_content_width = value
}
function color(value) {
	if (value!="" && ((value>=black && value<=white) || value==gray))
		printf "\033[" (30+value) "m";
	else
		warning("color", value);
}
function background_color(value) {
	if (value!="" && value>=black && value<=white)
		printf "\033[" (40+value) "m";
	else
		warning("background_color", value);
}
function text_decoration_line(value) {
	if (value!="" && (value==none || value==underline || value==blink))
		printf "\033[" value "m";
	else
		warning("text_decoration_line", value);
}
function text_decoration(value) {
	text_decoration_line(value);
}
function font_weight(value) {
	if (value!="" && (value==normal || value==bold))
		printf "\033[" value "m";
	else
		warning("font_weight", value);
}
