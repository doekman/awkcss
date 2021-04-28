# awkcss

Applying style to your terminal session with `awk`, CSS style!


## Installation

After downloading this repository, add the following to your `~/.profile` file (or your other favourite startup file):

	. awkcss.bash


## Usage

Print code from this repository using the _Zebra-stripes_ example:

	awkcss examples/zebra.awkcss < awkcss.bash

Show the README styled with _markdown_::

	awkcss examples/markdown.awkcss < README.md

You can always specify to use the awkcss-path with the `-s` parameter, so you can use the examples from every location:

	cd
	awkcss -s examples/zebra.awkcss < .bashrc


## Known issues

* You can't match a TAB character in an action, since the `awkcss`-input is first processed via `expand`


----

## Plans

Proposition:

* Pattern is the selector(-list)
* Action is the CSS property(-list)
	- Function sets a propery
	- A variable is used as property value
* No specificity.
* Inheritance (document/box-model)?
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
	- color: rgb-colors?
	- background_color: rgb-colors?
	+ box-model:
		- padding
		- border
		- margin
		- width
	+ rendering:
		- font_stretch: spaces in between
		- text_transform: capitalize/uppercase/lowercase/none
		- text_align: left/center/right
		- word_wrap
		- word_break
		- text_overflow: .../clip
* Other:
	+ supply column number to property-function as column selector?


### others

* specify `--verbose` to enable printing warnings to stderr
* specify programs as  strings on command line (something with temporary files)
