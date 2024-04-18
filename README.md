# awkcss

Applying style to your terminal session with `awk`, CSS style!


## Installation

After downloading this repository, add the following to your `~/.bashrc` file¹ (the script needs to be _sourced_ because it is implemented as a shell function):

	. awkcss.bash

> Don't look at me
> This is a quote
> I need it, for multiple lines


## Usage

The simplest use is to specify the _awkcss_ inline:

	awkcss 'BEGIN { color(red); } NR % 2 == 0 { color(green); }' defaults.awkcss

Print the start of the README from this repository using the _MarkDown_ example:

	head -n 35 README.md | awkcss -f examples/markdown.awkcss

The `-f` argument (file) takes relative or absolute paths. Use the `-s` argument (system) to resolves the path relative to the location of this repository. Use this to refer to the examples from anywhere:

	cd                                          # go to home folder
	awkcss -s examples/zebra.awkcss < .profile  # ¹

For a complete description of the AWKCSS language, see the [Reference](./reference.md).


## Development

Compatiblity is intended with all `awk` variants, including the original implementation by Aho, Kernighan and Weinberger.

**Optional:**

* When using TextMate (or compatible editor), you could install [AWK syntax highlighting][awk-tmLanguage].
* Installing [ok-bash][] will enhance your experience while working with this repository (while making you smarter in the process).


- - - - - - - - - - - - - - - - - - - - 

¹) or your other favourite startup file.

  [awk-tmLanguage]: https://github.com/zhf/lang-tm
  [ok-bash]: https://github.com/secretGeek/ok-bash
