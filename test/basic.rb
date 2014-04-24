require 'rest-open-uri'
require 'json'

def rand_string(len)
	(0..len).map {(65+rand(26)).chr}.join
end

def dexx_end
	puts "end"
end

def assert(&blk)
	dexx_call &blk
	puts '' if $verbose
end

def unsert(&blk)
	dexx_call false, &blk
	puts '' if $verbose
end

def exec (&blk)
	$resp = blk.call
	if $verbose
		puts $resp
		puts ''
	else
		puts "....Done"
	end
end

def dexx_call(expect_pass=true)
	return unless block_given?
	$resp = yield
	if $resp["status"]=="ok"
		if $verbose
			puts "....OK" if expect_pass
			puts "....OK(test failed)" if !expect_pass
		else
			print "." if expect_pass
			print "=X=" if !expect_pass
		end
	else
		if expect_pass
			puts "\n#{$resp}\nExecution stopped!"
			exit
		else
			print "." unless $verbose
			puts "..#{$resp} (test passed)" if $verbose
		end
	end
end

def get_template(name)
	print "get_template '#{name}'" if $verbose
	resp=""
	open("http://localhost:3000/templates.json?name=#{name}", 
		:method => :get, 
		"content-type" => 'application/json'
		) do |f|
		f.each_line {|l| resp << l}
	end
	JSON.parse(resp)
end

def create_template(name)
	print "create_template '#{name}'" if $verbose
	resp=""
	open('http://localhost:3000/templates.json', 
		:method => :post, 
		"content-type" => 'application/json',
		:body => {name:name}.to_json
		) do |f|
		f.each_line {|l| resp << l}
	end
	JSON.parse(resp)
end

def delete_template(name)
	print "delete_template '#{name}'" if $verbose
	resp=""
	open("http://localhost:3000/templates/#{name}.json",
			:method => :delete, 
			"content-type" => 'application/json',
			:body => {template:{name:name}}.to_json
		) do |f|
		f.each_line {|l| resp << l}
	end
	JSON.parse(resp)
end

def add_prop_to_template(template_name, name, type, validation)
	print "add_prop_to_template (#{template_name}): name: '#{name}' type: '#{type}' validation: '#{validation}'" if $verbose
	resp=""
	open("http://localhost:3000/templates/add_property.json", 
		:method => :put, 
		"content-type" => 'application/json',
		:body => {name:template_name, property:{name:name, type:type, validation:validation}}.to_json
		) do |f|
		f.each_line {|l| resp << l}
	end
	JSON.parse(resp)
end

def remove_prop_from_template(template_name, name, conf_key=nil)
	print "remove_prop_from_template (#{template_name}): name: '#{name}' key: '#{conf_key}'" if $verbose
	resp=""
	prop_params = {name:name}
	prop_params[:conf_key] = conf_key if conf_key
	open("http://localhost:3000/templates/delete_property.json", 
		:method => :put, 
		"content-type" => 'application/json',
		:body => {name:template_name, property:prop_params}.to_json
		) do |f|
		f.each_line {|l| resp << l}
	end
	JSON.parse(resp)
end

def create_card(title, template_name)
	print "create_card '#{title}' on template '#{template_name}'" if $verbose
	resp=""
	open('http://localhost:3000/cards.json', 
		:method => :post, 
		"content-type" => 'application/json',
		:body => {title:title, template_name:template_name}.to_json
		) do |f|
		f.each_line {|l| resp << l}
	end
	JSON.parse(resp)
end

def set_card_property(cid, prop, value)
	print "set_card_property (#{cid}): prop: '#{prop}' value: '#{value}'" if $verbose
	resp=""
	open('http://localhost:3000/cards/set.json', 
		:method => :put, 
		"content-type" => 'application/json',
		:body => {id:cid, property:{name:prop, value:value}}.to_json
		) do |f|
		f.each_line {|l| resp << l}
	end
	JSON.parse(resp)
end

def get_card(template_name, title = nil)
	if $verbose
		print "get_card for template (#{template_name}) " 
		print "with title (#{title}) " if title
	end
	resp=""
	params = "?template_name=#{template_name}"
	params << "&title=#{title}" if title && title.length >0
	open('http://localhost:3000/cards.json'+params, 
		:method => :get, 
		"content-type" => 'application/json'
		) do |f|
		f.each_line {|l| resp << l}
	end
	JSON.parse(resp)
end

def delete_card(cid)
	print "delete_card '#{cid}'" if $verbose
	resp=""
	open("http://localhost:3000/cards/#{cid}.json",
			:method => :delete, 
			"content-type" => 'application/json'
		) do |f|
		f.each_line {|l| resp << l}
	end
	JSON.parse(resp)
end

def search_cards(props)
	print "search cards by #{props}"
	resp = ""
	open("http://localhost:3000/cards/query.json",
			:method => :post, 
			"content-type" => 'application/json',
			:body => {"properties" => props}.to_json
		) do |f|
		f.each_line {|l| resp << l}
	end
	JSON.parse(resp)
end
