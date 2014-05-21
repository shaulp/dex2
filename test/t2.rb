require_relative 'basic'

$verbose = true

assert { create_template "Project" }
assert { add_prop_to_template "Project", "Name", "StringProperty", "Mandatory" }
assert { add_prop_to_template "Project", "Country", "StringProperty", "List:<Israel><PRC>;Mandatory" }
assert { add_prop_to_template "Project", "BeginDate", "DateProperty", ">2014-01-01" }
