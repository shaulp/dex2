class Card
 	include Mongoid::Document
	include Mongoid::Timestamps

	field :title, type: String
	field :is_valid, type: Boolean

	belongs_to :template
	has_many :values, dependent: :destroy

	validates :title, presence:true
	validates :template, presence:true

	scope :with_template, lambda {|name|
		if name.nil? || name.empty?
			all
		else
			template = Template.where(name:name)[0]
			raise "i18> Template not found" unless template
			where(template_id:template.id)
		end
	}

	scope :with_title, lambda { |title|
		if title.nil? || title.empty?
			all
		else 
			where(title:title)
		end
	}

	def set(name, new_val)
		errors.clear
		begin
			property = template.get_property(name)
			if template.validate self, name, new_val
				value = Value.where(card:self, property:property)[0]
				if value
					value.value = new_val
				else
					value = Value.new(card:self, property:property, value:new_val)
				end
				value.save || raise("i18> Could not save value #{new_val} for #{self.title}/#{property.name}: #{value.errors[:all].join(',')}")
			else
				# error messages added by "validate"
			end
		rescue Exception => e
			add_error e.message
		end
	end

	def get(name)
		if self.template && (p=self.template.get_property name )
			p.convert @properties[name]
		else
			add_error "i18> No such property: #{name}"
		end
	end
	def add_error(message)
		errors.add :base, message
	end
	def add_property_error(property, message)
		errors.add property.name.to_sym, message
	end

	def set_properties(properties)
		properties.each do |k,v|
			set k,v
			return if errors.any?
		end
	end

	## overrides
	##

	def save
		logger.info ">>>>> Doing my own save...!"
		template.properties.each do |p|
			logger.info ">>>>> looking for value of #{p.name}"
			v = Value.where(card:self, property:p)[0]
			unless v
				logger.info ">>>>> No value for #{p.name}"
				p.conditions.each do |c|
					if c.is_a? Conditions::Mandatory
						add_property_error p, "i18> cannot be empty"
						return false
					end
				end
			end
		end

		super()
	end

	def as_json
		{
			'title' => title,
			'is_valid' => is_valid,
			'created_at' => created_at,
			'updated_at' => updated_at,
			'template' => template.name,
			'properties' => values.map {|p| p.as_json}
		}
	end
end
