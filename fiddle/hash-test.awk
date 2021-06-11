BEGIN {
}
function sset_property(property_name, property_value) {
    _values[NR, property_name] = property_value;
}
#    if (NR in _values) {
#        VALUES = _values[NR];
#    }
#    VALUES[property_name] = property_value;
#    # Wil niet?
#    #awk: can't read value of (null); it's an array name.
#    # input record number 1, file fiddle/hash-test.txt
#    # source line number 11
#    _values[NR] = VALUES;
#}
#function has_property(property_name) {
#    return property_name in _values[NR] || property_name in _values[0];
#}
function gget_property(property_name) {
    if ((NR, property_name) in _values) 
        return _values[NR, property_name]
    if ((0, property_name) in _values) 
        return _values[0, property_name]
}
{
    sset_property($1, $2);
    printf "%s = %s\n", $1, $2
}

END {
    for(ding in _values) {
        if (ding ~ /@/ )
            printf "- %s => %s\n", ding, _values[ding];
        else
            printf "- %s = %s\n", ding, _values[ding];
    }
    NR=1
    printf "[%s]\n", gget_property("@")
    printf "[%s]\n", gget_property("#")
    printf "[%s]\n", gget_property("±")
}