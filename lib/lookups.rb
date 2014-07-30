module Lookups

	def Lookups.cards_with_properties(template, params)
		puts ">>>>> Lookups: template: #{template} params: #{params.inspect}"
		cards = Card.where(template:template) # for now, template is a must
		cards = cards.where(title:params["title"]) if params["title"]
		puts ">>>>>  >> title search found #{cards.count} cards"
		if params["properties"]
			matched_cards = []

			cards.each do |card|
				matched = true
				params["properties"].each do |p_name,p_value|
					puts ">>>>> looking for property #{p_name}"
					property = template.get_property(p_name) rescue nil
					if property
						comp_value = property.validate p_value # converts to property's data type
						if comp_value
							value = Value.where(card:card, property:property)[0]
							if value && value == comp_value
								next
							end
						end
					else
						puts ">>>>> property #{p_name} not found"
					end
					matched = false
					break
				end
				matched_cards << card if matched
			end
			puts ">>>>> ..... found #{matched_cards.count} cards"
			cards = matched_cards
		end
		puts ">>>>> >> returning #{cards.count} cards"
		return cards
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