require_relative 'basic'

$verbose = true

exec { delete_template "Dec" } 
assert { create_template "Dec" }
assert { add_prop_to_template "Dec", "CustomerID", "StringProperty", "Mandatory;Max-length:4" }
unsert { add_prop_to_template "Dec", "CustomerID", "StringProperty", "Mandatory;Max-length:4" }
assert { add_prop_to_template "Dec", "Name", "StringProperty", "Mandatory" }
assert { add_prop_to_template "Dec", "Country", "StringProperty", "List:<Israel><PRC>;Mandatory" }
assert { add_prop_to_template "Dec", "BeginDate", "DateProperty", ">2014-01-01" }

assert { create_card "Joe", "Dec" }
cid = $resp["card"]["_id"]["$oid"]
puts ">>>>> #{cid}"

assert { set_card_property cid, "Name", "Joe Shmoe" }
unsert { set_card_property cid, "Name", "" }
assert { set_card_property cid, "Country", "PRC" }
assert { set_card_property cid, "Country", "Israel" }
exit
