class DateProperty < Property
	ApplicableConditions = [
		Conditions::Mandatory, Conditions::Unique, Conditions::GreaterThan, 
		Conditions::LessThan, Conditions::GreaterOrEqual, Conditions::LessOrEqual, 
		Conditions::List, Conditions::Referrence
	]

	def self.applicable_condition?(c)
		ApplicableConditions.member? c.class
	end

	def convert(value)
		if value.is_a? DateTime
			value
		elsif value.is_a? String
			DateTime.parse value rescue nil
		else
			nil
		end
	end
end