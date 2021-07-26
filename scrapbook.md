# Scrap book

Some plans at the moment:

* `display:fields`: stylize (colorize) columns, like `select("$2")`
* `margin/border/padding`:
* `display:table`: like `table-layout:fixed`



## Future plans

I would want to focus on _selectors_. Implementing new _properties_ should only be done to demonstrate those _selectors_.

There can be three levels of selectors:

* `BEGIN { ... }`: effectively this is line NR==0. Properties apply to all lines, but can be overridden.

* `[pattern] { ... }`: a line selector. Properties apply to the selected lines only.

* `select( [selector] )`: can be used to select columns.
	- pseudo selectors: like `::before` and `::after`; display:block will generate new line, display:inline will not.
	- positive _number_: select that column: `select(1) { color(red); }` makes column 1 red.
	- a negative number would select from the right. So with a 6 column layout, -2 would select column number 5.
	- separator selector: select the separator, selected by `FS`: `select("1:2") { color(gray); }` makes the separator between column 1 and 2 gray. (TODO: how to specify border between cells then ??)
	- range selector: select multiple columns: `select("1-3") { color(white); }` makes column 1, 2 and 3 white. Seperator is not selected.
	- inclusive range selector: using `"1..3"` would also select the separators.
	- since `awk` is imperative, you might need to reset the selector if you don't want it to apply to subsequent rules: `select("2") { color(white); select(); }`
	- `select` returns FALSE if the current line isn't selected (if there aren't enough columns)
	- **implementation**: do we need an implicit `display: columns` and/or `display: table`


Data structure:

	Line properties    : _values[NR][property_name] == property_value
	Selector properties: _values[NR]['selectors'][selector][property_name] == property_value

	- set_property(property_name, property_value) # implicit: NR, current_selector
		+ _values[NR][property_name] == property_value
	- has_property(property_name) # implicit: NR, current_selector
		+ property_name in _values[NR] ||  property_name in _values[0]
	- get_property(property_name) # implicit: NR, current_selector
		+ _values[NR][property_name] || _values[0][property_name]


Grouping construct:

* a mechanism to detect a group op multiple lines would be nice to have. The property `border` comes to mind.
* Something like: `group("comment") { border(solid, gray); group(); }`
	- className and/or div comes to mind
	- `class_name("class_name") { border(solid, gray); class_name(); }`
	- `div("class_name") { border(solid, gray); div(); }`

`section(name, value)` (experimental): returns true when name/value-combination has not been hit for a line; false otherwise

There are no plans to implement input buffering, so related CSS features won't be considered. Just to keep things simple.


  [console]: https://developer.mozilla.org/en-US/docs/Tools/Browser_Console


----

<small>(please ignore notes below)</small>

## Plans

### Box model for lines

Every line is a box. Multiple lines can be grouped to be one box by adding `group( name[, value] )` to every line. Consecutive lines with the same group/value combination will be considered one box.

Boxes can have the following properties:

* border( named_line[, named_color[, named_color]] )
	- border_style( named_line {1,4} ): default `none`
		+ border_style_top( named_line )
		+ border_style_right( named_line )
		+ border_style_bottom( named_line )
		+ border_style_left( named_line )
	- `border_color( named_color {1,4}  )`: default `inherit`
	- `border_background_color( named_color {1,4} )` -- can't make inside & outside of borders have different colors, so introduce this property.
	- ~~border_width: not-supported~~
* padding( a[, b[, c[, d]]] )
	- padding-bottom: value in rows
	- padding-left: value in columns
	- padding-right: value in columns 
	- padding-top: value in rows
* margin: idem

* `named_line := none | solid | double | thick`
	- light, heavy & double Unicode box drawing
	- connector[position_numpad, vertical_named_line, horizontal_named_line]
		+ position_numpad: 12346789 on numeric keypad
	- horizontal & vertical
* combinaties (voor 1..9):
	- light-light:   "└┴┘├┼┤┌┬┐"
	- light-heavy:   "┕┷┙┝┿┥┍┯┑"
	- light-double:  "╘╧╛╞╪╡╒╤╕"
	- heavy-heavy:   "┗┻┛┣╋┫┏┳┓"
	- heavy-light:   "┖┸┚┠╂┨┎┰┒"
	- heavy-double:  ""
	- double-double: "╚╩╝╠╬╣╔╦╗"
	- double-light:  "╙╨╜╟╫╢╓╥╖"
	- double-heavy:  ""

	for combinaties(9x):
		for numpad_positions(9x):
			_ENUM["named_line", "connector", 1..9, horizontal_style, vertical_style] = "┌"
	for styles(3x):
		_ENUM["named_line", "horizontal", style] = "-"
		_ENUM["named_line", "vertical", style] = "|"


### Proposition

* Pattern is the selector(-list)
* Action is the CSS property(-list)
	- Function sets a propery
	- A variable (or string) is used as property value
* No specificity 
* Inheritance (document/box-model)?
	- Doesn't work now; see `width`. Work via state?
* No Cascade....
* Important? `next()` doesn't do it..?


### selectors

* Universal selector
* nth_child(odd): `NR % 2 == 1`
* Type selector: /xxx/
* Attribute/class/id selector: $3 ~ /yyy/
* Could we match multiple lines with three rules: begin+end condition, and in between?
	- Ranges are no use
* media queries: `cols`, `lines` and `colors`.
	- with "stretch"

### properties

* Done:
	- color: named-colors
	- background_color: named-colors
	- text_decoration: none/underline/blink
	- font_weight: bold
* Todo:
	- text_decoration: multiple values? `text_decoration(underline, blink)`
	- color/background_color: rgb-colors?
		+ box-model:
		- padding
		- border
		- margin
		- width
	+ rendering:
		- font_stretch: spaces in between
		- text_transform: capitalize/uppercase/lowercase/none
		- text_align: left/center/right
	+ wrap text
		- word_wrap
		- word_break 
		- text_overflow: .../clip
* Other:
	+ supply column number to property-function as column selector?


### others

* specify `--verbose` to enable printing warnings to stderr. --lint
* specify programs as  strings on command line (something with temporary files)


## Wrap text

Related properties:

* overflow: (we have no scroll bars, so basically it's either clip or visible)
	+ visible: might be supported (rendered outside padding box)
	+ hidden: supported (same as clip )
	+ clip: supported
	+ scroll: not supported
	+ auto: not supported
* text-overflow:
	+ clip
	+ ellipsis
* hyphens: (no hyphens support)
	+ none
	+ manual
	+ auto
* word-break:
	+ normal
	+ break-all
	+ keep-all
	+ .inherit
	+ .initial
	+ .unset
* word-wrap: (alias for overflow-wrap)
* overflow-wrap:
	+ normal
	+ anywhere
	+ break-word
* white-space: (tabs are never preserved)
	+ normal: not supported (lines collapsing makes no sense in awk)
	+ nowrap: not supported (lines collapsing makes no sense in awk)
	+ !pre: no-wrap (clipped)
	+ !pre-wrap: possible to wrap to next line
	+ pre-line: not supported (collapse spaces make no sense in awk)
	+ break-spaces: not supported 

Plan:

* `white-space` gebruiken om te kijken of een regel kan wrappen (`pre-wrap`) of afgekapt kan worden (`pre`).
* Geen support voor word-breaks (`hyphens`, `word-break`, `word-wrap` en `overflow-wrap`)
* Mochten we padding/border/margin gaan doen, dan kan `overflow` hiervoor gebruikt worden.
* Initial value: `pre-wrap`
* Eventueel `text-overflow` ondersteunen.

