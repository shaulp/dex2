class Card
  include Mongoid::Document
	include Mongoid::Timestamps

	field :title, type: String

	belongs_to :template
	embeds_many :values

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

	def set(name, value)
		errors.clear
		if template.validate self, name, value
			@properties[name] = value
		end
	end
	def get(name)
		if self.template && (p=self.template.get_property name )
			p.convert @properties[name]
		else
			add_error "i18> No such property: #{name}"
		end
	end

end
