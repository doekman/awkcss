# AWKCSS Reference

`awkcss` is a [DSL][DSL] implemented in the awk language to stylize text in your terminal. So basically everything you can do in `awk`, you can do with `awkcss`. 

`awkcss` templates can be used as string-parameters on the command line. However, it's more convenient to store long lived templates in files with the `.awkcss` extention (using the ~~`.ass`~~ filename extention is discouraged).

An `awk` file is build from pattern-action statements. With `awkcss` we talk about selector-property statements, which make out `awkcss` rules. Multiple rules can apply to one line, like _CSS_. However, in `awk` a rule only applies to a line, so this is true for `awkcss`.


## Selectors

You can use any awk-condition to select a line:

	# Will select all lines with three or more consecutive 'e'-characters
	/e{3,}/ { color(red); }
	
	# Will select every odd line
	NR % 2 == 1 { color(green); }

To apply a setting to every line, you can either omit the awk-condition, or use the `BEGIN` template. The latter works a bit different, since it only introduces one entry in the CSS DOM. So this is the preferred approach:

	BEGIN { background(gray); }

To select more sophisticated things, you can use the `select`-function. It returns true, if the provided _selector_ can be selected. Always end the rule with a call to `select` without any arguments, to reset the current query.

To add a line after every 100th line, you can use the pseudo-selector `::after`:

	NR % 100 == 0 && select("::after") {
		content("-=[ Congratulations, another 100 lines processed by AWKCSS! ]=-");
		text_decoration(blink);
		select();
	}

## Properties

The `awkcss` __properties__ work via function calls. This brings some advantages, one of which is when you use an unknown property, `awk` will stop with an error message.

So stylize text, you can use the following properties:

* `color( named_color )`: specify a foreground color, see below.
* `background_color( named_color )`: specify a background color, see below.
* `text_decoration( ... [, ... ])`: shorthand property
	- `text_decoration_line( underline | blink [, ... ] )`: make the text _underline_ and/or _blink_.
* `font_weight( normal | bold )`: make the text appear _bold_ or _normal_.

To control the box model (i.e. lines of text), use the following properties:

* `display( block | none )`:
	- __block__ (default): a paragraph (one or more lines) is created.
	- __none__: the line is not rendered (use this instead of `next`).
* `block_name( "name" )`:
	- For setting up _block continuation_.
	- Normally, every input line results in a block-item in the box-model. To combine adjacent input lines into one block-item, give these lines the same name.
	- When not set, the block-name is regarded the same as the `NR` variable.
* `width( [nr_columns] )`: sets the width, including margins, of a line.
	- __nr\_columns__: set the maximum width of a line. Handy when using background colors.
	- _no arguments_: when omitting `nr_columns`, the default value is used, which is the width of the terminal (see variable `COLS` below).
* `tab_size( nr_characters )`:
	- __nr\_characters__: set the width of a tab-character. Must be a positive integer value. Defaults to `8`.
* `margin( a [, b [, c [, d ]]] )`: Margin collapse for top/bottom margins is supported.
	- `margin_top( length )`: number of lines
	- `margin_right( length )`: number of columns
	- `margin_bottom( length )`: number of lines
	- `margin_left( length )`: number of columns
* `border( named_style )`: for border styles, see `named_style` below.
	- `border_style( named_style )`
		+ `border_style_top( named_style )`
		+ `border_style_right( named_style )`
		+ `border_style_bottom( named_style )`
		+ `border_style_left( named_style )`
* `white_space( pre | pre_wrap )`:
	- __pre\_wrap__ (default): all whitespace is preserved, and when a line doesn't fit the _width_, it is wrapped to the next line. The content-box can be multiple lines.
	- __pre__: same, but the text which doesn't fit the content box is not be displayed. The content-box will stay one line.
* `text_overflow( clip | ellipsis | "string" )`:
	- __clip__ (default): truncate the text.
	- __ellipsis__: display an ellipsis (`…`) to indicate the text is partly shown and is clipped.
	- __"string"__ (experimental): to specify a different character or characters, use a awk string. For example `text_overflow("8<")`.
	- Note: because of `UTF-8`, when using a comma (`,`) or non-ASCII characters, prefix the clipping indicator with character length and a comma. For example: `text_overflow("1,❗️")`.

Other properties:

* `content( "any string" )`: display text for use with the `::before` and `::after` selectors. All lines are replaceable by the way.


## Enumerations

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

`named_style` is used for border styles, and is defined one of:

* `none` to unset borders
* `ascii` for simple borders (left/right: `|`, top/bottom: `-`, corners: `+`)
* `ascii_rounded` same (left/right: `|`, top: `-`, bottom: `_`, corners: `/` and `\`)


## Variables

Besides `awk`'s __variables with special meanings__, like `NR` and `FILENAME`, you can also use the following variables:

* `COLS`: the number of columns in the current terminal (`tput cols`).
* `LINES`: the number of lines in the current terminal (`tput lines`).
* `COLORS`: the number of colors in the current terminal (`tput colors`).

This enables you to make "media-queries" with `awk`-expressions. This example demonstrates how one can query for capabilities and apply style that fits these capabilities:

	COLORS <= 2  { color(white);      }
	COLORS == 8  { color(red);        }
	COLORS >= 16 { color(bright_red); }

One could also have omitted the `COLORS <= 2` expression, and rewrite the second expression to `COLORS>=8`. The outcome would be the same, although not as efficient. `awk` is not a functional language, and more code would be executed.


## Awk specific information

Enumerated __property values__ are variables, like the color `gray`. However, when you use an unsupported value, the value is ignored and a warning is written to the standard error (the _standard error_ is like the [console][console]  of the terminal. A bit confusing, I know…). For example, the property assignment `color(grey)` will result in the following warning:

	‼️ color value '' is unknown and will be ignored

To know what value caused the error, you can also specify the property-value as a string `color("grey")`. This will give a more meaningful warning text:

	‼️ color value 'grey' is unknown and will be ignored

This can be used with all enumerated values.

User templates can assign variables too, but all property-names and enumerated values are reserved and cannot be used. Also all variable names starting with an underscore (`_`) can't be used, because they are used internally.

For your user style-sheet, the `BEGIN` template is an efficient place to place default values. This rule will only be hit once, but properties applied for every line, when not overridden by a normal rule.

For `awkcss` to function optimal, the `print` and `printf` statements should not be called by user templates. `awkcss` supplies a render pipeline, which will take care of showing the output. Also, the statements `next` (use `display(none)` instead) and `nextfile` should be avoided, as they mess up `awkcss`' proces model.

## Files

Check out the `examples/` folder with some idea's how to use `awkcss`.


## Known issues

* Since `awk` doesn't calculate the `length` of non-ASCII characters great (and the fact that emoticons takeup 2 characters of space), `awkcss` doesn't either. Lines with non-ASCII may have crippled content boxes.
* `awkcss` is designed to work with all versions of `awk`, so `gawk` specific capabilities are not used.



[DSL]: https://en.wikipedia.org/wiki/Domain-specific_language "Domain-specific language"
[console]: https://developer.mozilla.org/en-US/docs/Tools/Browser_Console

