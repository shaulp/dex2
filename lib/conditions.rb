#require 'lookups'

module Conditions

	def self.extract_conditions(property)
		conditions = []
		property.get_validation.split(';').each do |text|
			new_cond = nil
			Condition_clauses.each do |reg,cond_class|
				if match = reg.match(text)
					new_cond = cond_class.new(match[1..-1], property) rescue nil
					break
				end
			end
			if new_cond
				if property.class.applicable_condition? (new_cond) 
					conditions << new_cond
				end
			else
				property.add_error "i18> Could not create condition from #{text}"
			end
		end
		conditions
	end

	class Validator
		attr_accessor :card, :property, :value

		def initialize(card, property, value)
			@card = card
			@property = property
			@value = value
		end
		def add_error(message)
			@card.add_property_error property, message if @card && @card.errors
		end
	end

	class Condition

		def initialize(params, prop)
		end
		def check(v)
			return true
		end
	end

	class Mandatory < Condition
		def check(v)
			raise ArgumentError.new if v.value.nil?
			raise ArgumentError.new if v.value.empty? && \
																 v.property.is_a?(StringProperty)
			return true
		rescue ArgumentError
			v.add_error "i18> A value must be supplied'."
			return false
		end
	end

	class Unique < Condition
	end

	class LengthAtLeast < Condition
		def initialize(params, prop)
			@min_length = params[0].to_i
		end
		def check(v)
			raise ArgumentError if v.value.length < @min_length
			return true
		rescue ArgumentError
			v.add_error "i18> The value must be at least #{@min_length} caracters long."
			return false
		end
	end

	class LengthAtMost < Condition
		def initialize(params, prop)
			@max_length = params[0].to_i
		end
		def check(v)
			raise ArgumentError if v.value.length > @max_length
			return true
		rescue ArgumentError
			v.add_error "i18> The value must not be longer than #{@max_length} caracters."
			return false
		end
	end

	class DecimalFraction < Condition
		def initialize(params, prop)
			prop.frac_digits = params[0]
		end
	end

	class ScalarCheck < Condition
		def initialize(params, prop)
			@scalar = prop.convert(params[0])
			raise ArgumentError unless @scalar
			
			@operator = params[1]
			@message = params[2]
		end
		def check(v)
			return true if v.value.send(@operator, @scalar)
			v.add_error @message
			return false
		end
	end

	class GreaterThan < ScalarCheck
		def initialize(params, prop)
			params.push '>', "i18> The value must be greater than #{params[0]}."
			super params, prop
		end
	end

	class LessThan < ScalarCheck
		def initialize(params, prop)
			params.push '<', "i18> The value must be less than #{params[0]}."
			super params
		end
	end

	class GreaterOrEqual < ScalarCheck
		def initialize(params, prop)
			params.push '>=', "i18> The value must be greater than or equal to #{params[0]}."
			super params
		end
	end

	class LessOrEqual < ScalarCheck
		def initialize(params, prop)
			params.push '<=', "i18> The value must be less than or equal to #{params[0]}."
			super params
		end
	end

	class Pattern < Condition
	end

	class List < Condition
		def initialize(params, prop)
			@list = params[0].split(/[<>]/)
			@list.delete ""
		end
		def check(v)
			if @list.member?(v.value)
				return true
			else
				v.add_error "i18> '#{v.value}' is not an allowed value"
				return false
			end
		end
	end

	class Link < Condition
		def check(v)
			if Card.exists?(v.value)
				return true
			else
				v.add_error "i18> Linked card id=#{v.value} does not exist"
				return false
			end
		end
	end

	class Referrence < Condition
		def initialize(params, prop)
			@template = Template.find(name:params[0])
			raise TypeError unless @template
			@property = template.get_property(params[1])
			raise TypeError unless @property
		end
		def check(v)
			cards = Lookups.card_with_properties 'template' => @template, @property => v.value
			if cards.empty
				v.add_error "i18> Referenced cards not found for #{@template.name}.#{@property.name}=#{v.value}"
				return false
			else
				return true
			end
		end
	end

	Condition_clauses = {
		/^Mandatory$/i => Conditions::Mandatory,
		/^Unique$/i => Conditions::Unique,
		/^Max-length:(\d+?)$/i => Conditions::LengthAtMost,
		/^Min-length:(\d+?)$/i => Conditions::LengthAtLeast,
		/^Dec:(\d+?)$/i => Conditions::DecimalFraction,
		/^<(.+?)$/i => Conditions::LessThan,
		/^>(.+?)$/i => Conditions::GreaterThan,
		/^<=(.+?)$/i => Conditions::LessOrEqual,
		/^>=(.+?)$/i => Conditions::GreaterOrEqual,
		/^List:(<[\w _']+(><[\w _']+)*>)$/ => Conditions::List,
		/^Link$/i => Conditions::Link,
		/^Ref:{([\w]+)\/([\w]+)}$/ => Conditions::Referrence
	}

end