require_relative 'basic'

$verbose = true

exec { search_cards({"title" => "Joe", "Country" => "Israel"}) }
exit

exec { delete_template "Dec" } 
assert { create_template "Dec" }
assert { add_prop_to_template "Dec", "CustomerID", "StringProperty", "Mandatory;Max-length:4" }
unsert { add_prop_to_template "Dec", "CustomerID", "StringProperty", "Mandatory;Max-length:4" }
assert { add_prop_to_template "Dec", "Name", "StringProperty", "Mandatory" }
assert { add_prop_to_template "Dec", "Country", "StringProperty", "List:<Israel><PRC>;Mandatory" }
assert { add_prop_to_template "Dec", "BeginDate", "DateProperty", ">2014-01-01" }

assert { create_card "Joe", "Dec" }
cid = $resp["card"]["_id"]["$oid"]

unsert { delete_template "Dec" } 

assert { set_card_property cid, "Name", "Joe Shmoe" }
unsert { set_card_property cid, "Name", "" }
assert { set_card_property cid, "Country", "PRC" }
assert { set_card_property cid, "Country", "Israel" }

assert { create_card "Joe", "Dec" }

unsert { remove_prop_from_template "Dec", "CustomerID" }
if $resp["status"]=="error"
	if $resp["template"]["key"]
		key = $resp["template"]["key"][0]
		assert { remove_prop_from_template "Dec", "CustomerID", key}
	end
end

exec { search_cards({"title" => "Joe", "Country" => "Israel"}) }

exec { search_cards({"title" => "Joe"}) }
if $resp["status"]=="ok"
	$resp["card"].each do |c|
		cid = c["_id"]["$oid"]
		assert { delete_card cid }
	end
end

exit
