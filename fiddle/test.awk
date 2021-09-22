function no_arg(value) {
	return (value=="") && (value==0)
}
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
	dyng = no_arg(ding)
	printf "\t"
}
BEGIN {
	printf "START: [%s] (%s)\n", dong, dyng
	test();
	printf "1: [%s] no arg (%s)\n", dong, dyng
	test("");
	printf "2: [%s] empty arg (%s)\n", dong, dyng
	test(0);
	printf "3: [%s] 0 arg (%s)\n", dong, dyng
	test(" ");
	printf "4: [%s] space arg (%s)\n", dong, dyng
	test("ja");
	printf "5: [%s] space arg (%s)\n", dong, dyng
}
