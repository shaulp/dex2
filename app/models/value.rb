class Value
	include Mongoid::Document
	include Mongoid::Timestamps

	embedded_in :card, inverse_of: :values
	belongs_to :property
end
