class Value
	include Mongoid::Document
	include Mongoid::Timestamps

	belongs_to :card
	belongs_to :property

	field :value

	def as_json
		{
			"name" => property_id ? card.template.properties.find(property_id).name : "",
			"value" => value
		}
	end
end
