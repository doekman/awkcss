
if [[ "$_" == "$0" ]]; then
	>&2 echo 'tip: "." (i.e. source) this file in order to use it'
	exit 1
else
	#basically, a complicated way of getting the absolute path of this script
	pushd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null || (>&2 echo "awkcss: pushd failed")
	AWKCSS_PATH="$(pwd)"
	popd > /dev/null || (>&2 echo "awkcss: popd failed")

	export AWKCSS_PATH #="${AWKCSS_PATH/$HOME/\$HOME}"

	function awkcss {
		local debug=""
		local has_program=""
		local has_post=""
		local -a args
		local -a cmd=(awk)
		function _awk_css__usage {
			unset -f _awk_css__usage #emulate a "local" function
			echo "Usage: awkcss [ -F fs ] [-f PROGRAM_FILE | -s LIBRARY_FILE | PROGRAM_STRING | --help | --version] [FILE1, ...]"
		}
		function _awk_add_post {
			if [[ -z $has_post ]]; then
				args[${#args[@]}]="-f"
				args[${#args[@]}]="$AWKCSS_PATH/post.awk"
				has_post="1"
			fi
		}
		args=(-v "COLS=$(tput cols)" -v "LINES=$(tput lines)" -v "COLORS=$(tput colors)" "-f" "$AWKCSS_PATH/pre.awk" "-f" "$AWKCSS_PATH/defaults.awkcss")
		if (( $# == 0)); then _awk_css__usage; return 0; fi
		while (( $# > 0 )); do
			if [[ $has_post && $1 = -* ]]; then
				>&2 echo "awkcss: can't supply options after an input file has been specified"; return 4
			fi
			case "$1" in
				-F) if (( $# > 1 )); then
						cmd[${#cmd[@]}]="-F"; cmd[${#cmd[@]}]="$2"; shift
					else
						>&2 echo "awkcss: no field separator specified with -F"; return 2
					fi;;
				-f) if (( $# > 1 )); then
						args[${#args[@]}]="-f"; args[${#args[@]}]="$2"; shift
						has_program="1"
					else
						>&2 echo "awkcss: no program filename provided with -f"; return 2
					fi;;
				-s) if (( $# > 1 )); then
						args[${#args[@]}]="-f"; args[${#args[@]}]="$AWKCSS_PATH/$2"; shift
						has_program="1"
					else
						>&2 echo "awkcss: no library filename provided with -s"; return 3
					fi;;
				--debug) debug="True";;
				--help) _awk_css__usage; return 0;;
				--version) echo "awkcss $(cat "$AWKCSS_PATH/version.txt")"; return 0;;
				-*)	>&2 echo "awkcss: unknown option '$1'"; return 1;;
				*)	if [[ -z $has_program ]]; then
						string_file=$(mktemp /tmp/awkcss.XXXXXX) || return 4
						echo "$1" > "$string_file"
						args[${#args[@]}]="-f"; args[${#args[@]}]="$string_file"
						has_program="1"
					else
						_awk_add_post
						args[${#args[@]}]="$1"
					fi;;
			esac
			shift
		done
		_awk_add_post
		

		if [[ -z $debug ]]; then
			"${cmd[@]}" "${args[@]}"
			exit_code=$?
		else
			echo "${cmd[@]} ${args[*]}"
			exit_code=0
		fi

		if [[ ${string_file:-} && -f $string_file ]]; then
			if [[ -z $debug ]]; then
				rm -f "$string_file"
			else
				echo "rm -f \"$string_file\""
			fi
		fi
		return $exit_code
	}
fi
