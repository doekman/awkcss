function test(ding) {
	if (ding)
		printf "X"
	else
		printf "x"
	if (ding == "")
		printf "Y"
	else
		printf "y"
	if (ding == 0)
		printf "Z"
	else
		printf "z"
	dong = ding;
	printf "\t"
}
BEGIN {
	printf "START: [%s]\n", dong
	test();
	printf "1: [%s] no arg\n", dong
	test("");
	printf "2: [%s] empty arg\n", dong
	test(0);
	printf "3: [%s] 0 arg\n", dong
	test(" ");
	printf "3: [%s] space arg\n", dong
}
