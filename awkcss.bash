# Copyright (c) 2021 Doeke Zanstra under the MIT license

called=$_

#basically, get the absolute path of this script
pushd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null || (>&2 echo "awkcss: pushd failed")
AWKCSS_PATH=$(pwd)
popd > /dev/null || (>&2 echo "awkcss: popd failed")

if [[ "$called" == "$0" ]]; then
	>&2 echo 'tip: "." (i.e. source) this file in order to use it'
	exit 1
else
	export AWKCSS_PATH
	
	function awkcss {
		local user_source
		if [[ $1 == "-s" ]]; then
			shift
			user_source="${AWKCSS_PATH}/$1"
		else
			user_source="$1"
		fi
		expand | awk -v "COLS=$(tput cols)" -v "LINES=$(tput lines)" -v "colors=$(tput colors)" -f "$AWKCSS_PATH/head.awk" -f "$user_source" -f "$AWKCSS_PATH/tail.awk"
	}
fi
