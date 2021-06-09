BEGIN {
}
function set_property(property_name, property_value     ,VALUES) {
    if (NR in _values) {
        VALUES = _values[NR];
    }
    VALUES[property_name] = property_value;
    # Wil niet?
    #awk: can't read value of (null); it's an array name.
    # input record number 1, file fiddle/hash-test.txt
    # source line number 11
    _values[NR] = VALUES;
}
#function has_property(property_name) {
#    return property_name in _values[NR] || property_name in _values[0];
#}
#function get_property(property_name) {
#    if (property_name in _values[NR]) 
#        return _values[NR][property_name]
#    if (property_name in _values[0]) 
#        return _values[0][property_name]
#}
{
    set_property($1, $2);
    printf "%s = %s\n", $1, $2
}

END {
}