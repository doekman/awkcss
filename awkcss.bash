
if [[ "$_" == "$0" ]]; then
	>&2 echo 'tip: "." (i.e. source) this file in order to use it'
	exit 1
else
	#basically, a complicated way of getting the absolute path of this script
	pushd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null || (>&2 echo "awkcss: pushd failed")
	AWKCSS_PATH="$(pwd)"
	popd > /dev/null || (>&2 echo "awkcss: popd failed")

	export AWKCSS_PATH

	function awkcss {
		local debug=""
		local -a args
		function _awk_css__usage {
			unset -f _awk_css__usage #emulate a "local" function
			echo "Usage: awkcss [-f PROGRAM_FILE | -s LIBRARY_FILE | PROGRAM_STRING | --help | --version]"
		}
		args=(-v "COLS=$(tput cols)" -v "LINES=$(tput lines)" -v "COLORS=$(tput colors)" "-f" "$AWKCSS_PATH/pre.awk" "-f" "$AWKCSS_PATH/defaults.awkcss")
		if (( $# == 0)); then _awk_css__usage; return 0; fi
		while (( $# > 0 )); do
			case "$1" in
				-f) if (( $# > 1 )); then
						args[${#args[@]}]="-f"; args[${#args[@]}]="$2"; shift
					else
						>&2 echo "awkcss: no program filename provided"; return 2
					fi;;
				-s) if (( $# > 1 )); then
						args[${#args[@]}]="-f"; args[${#args[@]}]="$AWKCSS_PATH/$2"; shift
					else
						>&2 echo "awkcss: no library filename provided"; return 3
					fi;;
				--debug) debug="True";;
				--help) _awk_css__usage; return 0;;
				--version) echo "awkcss $(cat "$AWKCSS_PATH/version.txt")"; return 0;;
				-*)	>&2 echo "awkcss: unknown option '$1'"; return 1;;
				*)	string_file=$(mktemp /tmp/awkcss.XXXXXX) || return 4
					echo "$1" > "$string_file"
					args[${#args[@]}]="-f"; args[${#args[@]}]="$string_file";;
			esac
			shift
		done
		args[${#args[@]}]="-f"; args[${#args[@]}]="$AWKCSS_PATH/post.awk"

		if [[ -z $debug ]]; then
			expand | awk "${args[@]}"
			exit_code=$?
		else
			echo "expand | awk ${args[*]}"
			exit_code=0
		fi

		if [[ -f $string_file ]]; then
			if [[ -z $debug ]]; then
				rm -f "$string_file"
			else
				echo "rm -f \"$string_file\""
			fi
		fi
		return $exit_code
	}
fi
