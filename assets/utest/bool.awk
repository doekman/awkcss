BEGIN {
	assert_equal(0, !!0, "0 == !!0");
	assert_equal(1, !!2, "1 == !!2");
}
