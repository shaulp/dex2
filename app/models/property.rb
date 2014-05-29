require 'conditions'
class Property
	include Mongoid::Document
	include Mongoid::Timestamps

	embedded_in :template, inverse_of: :properties
	has_many :values, dependent: :destroy

	field :name, type: String
	field :type, type: String
	field :validation, type: String
	field :delete_key, type: String

	after_initialize :set_conditions

	@@ApplicableConditions = []

	def self.applicable_condition?(c)
		@@ApplicableConditions.member? c.class
	end
	def set_conditions
		@conditions = Conditions::extract_conditions(self)
	end
	def get_validation
		validation || ''
	end
	def conditions
		@conditions
	end
	def property_type
		self.class.to_s
	end
	def convert(value)
		value.to_s
	end
	def validate(card, raw_value)
		value = convert(raw_value)
		unless value
			card.add_property_error self, "i18> Bad property value: #{self.class} / #{raw_value}"
			return nil
		end
		unless @conditions
			return true
		end
		@conditions.reduce(true) do |is_valid, condition| 
			is_valid && condition.check(Conditions::Validator.new(card, self, value))
		end
	end
	def add_error(msg)
		self.errors.add :base, msg
		logger.info ">>>>> error added to prop #{self.has_errors?}"
	end
	def has_errors?
		self.errors.any?
	end
	def print_errors
		msg = ''
		self.errors.each do |key,msgs|
			msg << msgs << '\n'
		end
		msg
	end

end # class Property
