module Lookups

	def Lookups.cards_with_properties(properties)
		cards = Card.all
		properties.each_pair do |property, value|
			if property=="template"
				cards = cards.where(template_id:value.id)
			elsif property=="title"
				cards = cards.where(title:value)
			else
				cards = cards.where('packed_properties like ?', "%\"#{property}\":\"#{value}\"%")
			end
		end
		cards
	end

	def Lookups.revalidate(template, property)
		cards = Card.where(template_id:template.id)
		cards.each do |card|
			value = card.get(property.name)
			if value
				unless property.validate(card, value)
					card.update_attribute(is_valid:false)
					return
				end
			end
		end
	end

end