BEGIN {
	NR_OK = 0;
	NR_ERR = 0;
	VERBOSE = !0;
}

function assert_equal(actual, expected, message) {
	assert(actual == expected, actual, expected, message);
}
function assert_not_equal(actual, expected, message) {
	assert(actual != expected, actual, expected, message);
}
function assert(condition, actual, expected, msg) {
	if (condition) {
		NR_OK += 1;
		printf "- ok: %s\n", msg
	}
	else {
		NR_ERR += 1;
		printf "# ERROR: %s\n", msg
	}
}
