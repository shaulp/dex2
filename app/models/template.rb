require 'properties'

class Template
	include Mongoid::Document
	include Mongoid::Timestamps

	field :name, type: String

	embeds_many :properties

	validates :name, presence:true, uniqueness:true

=begin
	before_destroy :verify_no_cards_exists #!!!!!!!!!!!!!!

	def verify_no_cards_exists
		if cards.empty?
			return true
		else
			errors.add :base, "i18> Cannot delete template because it has cards"
			return false
		end
	end
=end

	def add_property(params)
		properties.each do |p|
			if p.name == params[:name]
				errors.add p.name.to_sym, "i18> Property already exists"
				return
			end
		end

		prop_class = Properties::get_class params[:type]
		if prop_class
			p = prop_class.new(params)
			if p.valid?
				properties.push p
			else
				errors.add :base, "i18> Error creating property #{params[:name]}: #{p.errors}."
			end
		else
			errors.add :base, "i18> #{params[:type]} is not a valid property type."
		end
	end

	def update_property(prop_params)
	end
	def delete_property(prop_params)
	end

	def validate(card, prop_name, value)
		begin
			prop = get_property(prop_name)
		rescue Exception => e
			card.add_error e.message
			return nil
		end
		val = prop.validate card, value
		return val
	end
end