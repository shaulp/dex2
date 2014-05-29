class LinkProperty
	ApplicableConditions = [
		Conditions::Mandatory, Conditions::Unique
	]

	def self.applicable_condition?(c)
		ApplicableConditions.member? c.class
	end

	def convert(value)
		value.to_i<=0 ? nil : value.to_i
	end
end