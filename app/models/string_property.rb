class StringProperty < Property
	@@ApplicableConditions = [
		Conditions::Mandatory, Conditions::Unique, 
		Conditions::LengthAtLeast, Conditions::LengthAtMost, Conditions::GreaterThan, 
		Conditions::LessThan, Conditions::GreaterOrEqual, Conditions::LessOrEqual, 
		Conditions::Pattern, Conditions::List, Conditions::Referrence
	]

end