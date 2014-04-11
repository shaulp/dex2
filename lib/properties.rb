module Properties

	def Properties.get_class(property_name)
		ret = Dex2.const_get(property_name.to_sym) rescue nil
		if ret && ret.superclass == Property
			return ret
		else
			return nil
		end
	end

end