BEGIN {
	printf "FS[%s]\n", FS
}
{
	# Hoe een regel in kolommen + seperators te splitsen
	printf "%s(%s)> ", NR, NF
	split($0, columns);
	j = 1; #position seperator
	for(i=1; i<=NF; i++) {
		column = columns[i];
		printf "[%s]", column;
		if (i<NF) {
			j += length(column)
			remaining = substr($0, j);
			if (match(remaining, FS)) {
				sep = substr(remaining, RSTART, RLENGTH);
				j += RLENGTH;
			}
			else
				sep = "-=FOUTJE=-";
			printf " (%s) ", sep;
		}
	}
	printf "\n";
}