class Value
	include Mongoid::Document
	include Mongoid::Timestamps

	belongs_to :card
	belongs_to :property

	field :value
end
