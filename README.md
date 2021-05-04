# awkcss

Applying style to your terminal session with `awk`, CSS style!


## Installation

After downloading this repository, add the following to your `~/.profile` file (or your other favourite startup file):

	. awkcss.bash

_Optional_: when using Textmate (or compatible editor), you could install [AWK syntax highlighting][awk-tmLanguage]. Installing [ok-bash][] will enhance your experience while working with this repository (while making you smarter in the process).


## Usage

The simplest use is to specify the _awkcss_ inline:

	awkcss 'NR % 2 == 1 { color(red); } NR % 2 == 0 { color(green); }' < examples/markdown.awkcss

Print the start of the README from this repository using the _MarkDown_ example:

	head -n 35 README.md | awkcss -f examples/markdown.awkcss

The `-f` argument (file) takes relative or absolute paths. Use the `-s` argument (system) to resolves the path relative to the location of this repository. Use this to refer to the examples from anywhere:

	cd #go to home folder
	awkcss -s examples/zebra.awkcss < .profile  #or .bashrc


## Known issues

* You can't match a TAB character in an action, since the `awkcss`-input is first processed via `expand`


  [awk-tmLanguage]: https://github.com/zhf/lang-tm
  [ok-bash]: https://github.com/secretGeek/ok-bash

----

## Plans

Proposition:

* Pattern is the selector(-list)
* Action is the CSS property(-list)
	- Function sets a propery
	- A variable (or string) is used as property value
* No specificity.
* Inheritance (document/box-model)?
	- Doesn't work now; see `width`. Work via state?
* No Cascade....
* Important? `next()` doesn't do it..?


How to wrap text:

* overflow: (we have no scroll bars, so basically it's either clip or visible)
	+ visible: might be supported (rendered outside padding box)
	+ hidden: supported (same as clip )
	+ clip: supported
	+ scroll: not supported
	+ auto: not supported
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
* 

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
		- word_wrap
		- word_break
		- text_overflow: .../clip
* Other:
	+ supply column number to property-function as column selector?


### others

* specify `--verbose` to enable printing warnings to stderr
* specify programs as  strings on command line (something with temporary files)

