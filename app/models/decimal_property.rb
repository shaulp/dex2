class DecimalProperty < Property
	ApplicableConditions = [
		Conditions::Mandatory, Conditions::Unique, Conditions::GreaterThan, 
		Conditions::LessThan, Conditions::GreaterOrEqual, Conditions::LessOrEqual, 
		Conditions::List, Conditions::Referrence
	]

	def self.applicable_condition?(c)
		ApplicableConditions.member? c.class
	end

	def convert(value)
		f = Float(value) rescue nil
		if f
			f.round(frac_digits)
		end
	end

end