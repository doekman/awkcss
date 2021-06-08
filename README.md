# awkcss

Applying style to your terminal session with `awk`, CSS style!


## Installation

After downloading this repository, add the following to your `~/.profile` file¹ (the script needs to be _sourced_ because it is implemented as a shell function):

	. awkcss.bash

_Optional_: when using Textmate (or compatible editor), you could install [AWK syntax highlighting][awk-tmLanguage]. Installing [ok-bash][] will enhance your experience while working with this repository (while making you smarter in the process).


## Usage

The simplest use is to specify the _awkcss_ inline:

	awkcss 'BEGIN { color(red); } NR % 2 == 0 { color(green); }' defaults.awkcss

Print the start of the README from this repository using the _MarkDown_ example:

	head -n 35 README.md | awkcss -f examples/markdown.awkcss

The `-f` argument (file) takes relative or absolute paths. Use the `-s` argument (system) to resolves the path relative to the location of this repository. Use this to refer to the examples from anywhere:

	cd                                          # go to home folder
	awkcss -s examples/zebra.awkcss < .profile  # ¹


## Language Guide

`awkcss` is a [DSL][DSL] implemented in the awk language to stylize text in your terminal. So basically everything you can do in `awk`, you can do with `awkcss`. 

`awkcss` templates can be used as string-parameters on the command line. However, it's more convenient to store long lived templates in files with the `.awkcss` extention (using the ~~`.ass`~~ filename extention is discouraged).

An `awk` file is build from pattern-action statements. With `awkcss` we talk about selector-property statements, which make out `awkcss` rules. Multiple rules can apply to one line, like _CSS_. However, in `awk` a rule only applies to a line, so this is true for `awkcss`.

The `awkcss` __properties__ work via function calls. This brings some advantages, one of which is when you use an unknown property, `awk` will stop with an error message.

So stylize text, you can use the following properties:

* `color( named_color )`: specify a foreground color, see below.
* `background_color( named_color )`: specify a background color, see below.
* `text_decoration( ... [, ... ])`: shorthand property
	- `text_decoration_line( underline | blink [, ... ] )`: make the text _underline_ and/or _blink_.
* `font_weight( normal | bold )`: make the text appear _bold_ or _normal_.

`named_color` is defined one of:

* `black` and `bright_black` (or `gray`)
* `red` and `bright_red`
* `green` and `bright_green`
* `yellow` and `bright_yellow`
* `blue` and `bright_blue`
* `magenta` and `bright_magenta`
* `cyan` and `bright_cyan`
* `white` and `bright_white`

Always be aware of the capabilities of your system. You can inspect the supported number of colors by the `COLORS` variable (see also below). Black and white always work, but for the normal colors, you need at least 8 colors. To use the bright-variations, 16 colors is the minimum.

To control the content-box (i.e. lines of text), use the following properties:

* `display( block | none )`:
	- __block__ (default): a paragraph (one or more lines) is created.
	- __none__: the line is not rendered (use this instead of `next`).
* `width( [nr_columns] )`:
	- __nr\_columns__: set the maximum width of a line. Handy when using background colors.
	- _no arguments_: when omitting `nr_columns`, the default value is used, which is the width of the terminal (see variable `COLS` below).
* `tab_size( nr_characters )`:
	- __nr\_characters__: set the width of a tab-character. Must be a positive integer value. Defaults to `8`.
* `white_space( pre | pre_wrap )`:
	- __pre\_wrap__ (default): all whitespace is preserved, and when a line doesn't fit the _width_, it is wrapped to the next line. The content-box can be multiple lines.
	- __pre__: same, but the text which doesn't fit the content box is not be displayed. The content-box will stay one line.
* `text_overflow( clip | ellipsis | "string" )`:
	- __clip__ (default): truncate the text.
	- __ellipsis__: display an ellipsis (`…`) to indicate the text is partly shown and is clipped.
	- __"string"__ (experimental): to specify a different character or characters, use a awk string. For example `text_overflow("8<")`.
	- Note: because of `UTF-8`, when using a comma (`,`) or non-ASCII characters, prefix the clipping indicator with character length and a comma. For example: `text_overflow("1,❗️")`.

Enumerated __property values__ are variables, like the color `gray`. However, when you use an unsupported value, the value is ignored and a warning is written to the standard error (the _standard error_ is like the [console][console]  of the terminal. A bit confusing, I know…). For example, the property assignment `color(grey)` will result in the following warning:

	‼️ color value '' is unknown and will be ignored

To know what value caused the error, you can also specify the property-value as a string `color("grey")`. This will give a more meaningful warning text:

	‼️ color value 'grey' is unknown and will be ignored

This can be used with all enumerated values.

Besides `awk`'s __variables with special meanings__, like `NR` and `FILENAME`, you can also use the following variables:

* `COLS`: the number of columns in the current terminal (`tput cols`).
* `LINES`: the number of lines in the current terminal (`tput lines`).
* `COLORS`: the number of colors in the current terminal (`tput colors`).

This enables you to make "media-queries" with `awk`-expressions. This example demonstrates how one can query for capabilities and apply style that fits these capabilities:

	COLORS <= 2  { color(white);      }
	COLORS == 8  { color(red);        }
	COLORS >= 16 { color(bright_red); }

One could also have omitted the `COLORS <= 2` expression, and rewrite the second expression to `COLORS>=8`. The outcome would be the same, although not as efficient. `awk` is not a functional language, and more code would be executed.

User templates can assign variables too, but all property-names and enumerated values are reserved and cannot be used. Also all variable names starting with an underscore (`_`) can't be used, because they are used internally.

For your user style-sheet, the `BEGIN` template is an efficient place to place default values. This rule will only be hit once, but properties applied for every line, when not overridden by a normal rule.

For `awkcss` to function optimal, the `print` and `printf` statements should not be called by user templates. `awkcss` supplies a render pipeline, which will take care of showing the output. Also, the statements `next` (use `display(none)` instead) and `nextfile` should be avoided, as they mess up `awkcss`' proces model.

Finally, check out the `examples/` folder with some idea's how to use `awkcss`.

## Known issues

* Since `awk` doesn't calculate the `length` of non-ASCII characters great (and the fact that emoticons takeup 2 characters of space), `awkcss` doesn't either. Lines with non-ASCII may have crippled content boxes.
* `awkcss` is designed to work with all versions of `awk`, so `gawk` specific capabilities are not used.

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


¹) or your other favourite startup file.

  [awk-tmLanguage]: https://github.com/zhf/lang-tm
  [ok-bash]: https://github.com/secretGeek/ok-bash
  [console]: https://developer.mozilla.org/en-US/docs/Tools/Browser_Console
  [DSL]: https://en.wikipedia.org/wiki/Domain-specific_language "Domain-specific language"


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

