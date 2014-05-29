require 'properties'

class Template
	include Mongoid::Document
	include Mongoid::Timestamps

	field :name, type: String

	embeds_many :properties
	has_many :cards

	validates :name, presence:true, uniqueness:true

	before_destroy :verify_no_cards_exists

	def verify_no_cards_exists
		if cards.empty?
			return true
		else
			errors.add :base, "i18> Cannot delete template because it has cards"
			return false
		end
	end

	def add_property(params)
		properties.each do |p|
			if p.name.downcase == params[:name].downcase
				errors.add p.name.to_sym, "i18> Property already exists"
				return
			end
		end

		prop_class = Properties::get_class params[:type]
		if prop_class
			p = prop_class.new(params)
			if p.has_errors?
				errors.add :base, "i18> Error creating property #{params[:name]}: #{p.print_errors}."
			else
				properties.push p
			end
		else
			errors.add :base, "i18> #{params[:type]} is not a valid property type."
		end
	end

	def update_property(prop_params)
	end

	def delete_property(prop_params)
		name = prop_params["name"]
		begin
			prop = get_property(name)
		rescue Exception => e
			errors.add :base, e.message
			return
		end
		unless cards.empty?
			conf_key = prop_params["conf_key"]
			if conf_key
				if prop.delete_key != conf_key
					logger.info ">>>>> prop_key: #{prop.delete_key} ? conf_key: #{conf_key}"
					errors.add :base, "i18> Cannot delete property #{name}. Confirmation key mismatched."
					return
				end
			else
				key = SecureRandom.uuid
				prop.delete_key = key
				save
				errors.add :base, "i18> Try again and supply key"
				errors.add :key, key
				return
			end
		end
		prop.destroy # also destroys related values
	end

	def validate(card, prop_name, value)
		begin
			prop = get_property(prop_name)
		rescue Exception => e
			raise e.message
		end
		val = prop.validate card, value
		return val
	end

	def get_property(name)
		p = (properties.select {|p| p.name==name})[0]
		if p
			return p
		else
			raise "i18> Property #{prop_name} does not exists"
		end
	end
end