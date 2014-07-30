// dex2-cards.js

function CardsViewModel() {
  // Data
  var self = this;
  self.templates = ko.observable();
  self.selectedTemplate = ko.observable();
  self.selectedTemplateName = ko.observable();
  self.searchResults = ko.observable();
  var curr_template = null;
  var empty_result_set = {card:[]};
  var base_value_set = {};

  // Behavior
  self.loadTemplates = function () {
  	$.get("/templates.json", {}, function(resp) {
  		self.templates(resp.template);
  	});
  };

  self.templateSelectionChanged = function(event)
  {
  	var name = self.getSelectedTemplate();
    if (name != null)
      Utils.get_template(name, self.selectedTemplateResponse, null);
  }

  self.selectedTemplateResponse  = function(resp) {
    curr_template = resp.template;
    base_value_set = {};
    for (var i=0; i<curr_template.properties.length; i++)
    {
      prop = curr_template.properties[i];
      base_value_set[prop.name] = '';
    }
	  self.selectedTemplate(resp.template);
    self.selectedTemplateName(resp.template.name);
  };

  self.searchFieldID = function(data)
  {
  	return "1";
  }

  self.doCardAction = function()
  {
    var template = self.getSelectedTemplate();
    var params = {"template_name":template, "properties":{}};
    var title = document.getElementById("value_title").value;
    if (title) params.title = title;

    var fields = document.getElementsByName("value_field");
    for (var i=0; i<fields.length; i++)
    {
      var f = fields[i];
      if (f.value!='')
      {
        var name = f.id.substr(6);
        params.properties[name] = f.value;
      }
    }
    if ($.isEmptyObject(params))
      alert("No data given.");
    else
      if (document.getElementById("action_create").checked)
        Utils.create_card(params, self.displayCreateResults);
      else if (document.getElementById("action_search").checked)
        Utils.search_cards(params, self.displaySearchResults);
  }

  self.displaySearchResults = function(results)
  {
    var result_set = {card:[]};

    if (results.status=='ok')
    {
      for (var i=0; i<results.cards.length; i++)
      {
        var card = results.cards[i];
        var values = $.extend({}, base_value_set);
        for (var j=0; j<card.properties.length; j++)
        {
          var prop = card.properties[j];
          values[prop.name] = prop.value;
        }
        var card_data = {title:card.title, values: Utils.extract_values(values)};
        result_set['card'].push(card_data);
      }
      self.searchResults(result_set);
      document.getElementById('card_list').style.display = 'block';
    }
    else
    {
      self.searchResults(empty_result_set);
      document.getElementById('card_list').style.display = 'none';
    }
  }

  self.stam = function(results)
  {
    var header_set = false;
    document.getElementById('card_list_header').innerHTML = '';
    document.getElementById('card_list_body').innerHTML = '';

    for (var i = 0; i < results.card.length; i++) 
    {
      var tr_head = document.createElement('tr');
      var card = results.card[i];
      var tr = document.createElement('tr');
      for (var p in card)
      {
        if (p=="_id" || p=="template_id") continue;
        var td = document.createElement('td');
        td.innerHTML = card[p];
        tr.appendChild(td);

        if (!header_set)
        {
          var td = document.createElement('td');
          td.innerHTML = p;
          tr_head.appendChild(td);
        }
      }
      if (!header_set)
      {
        document.getElementById('card_list_header').appendChild(tr_head);
        header_set = true;
      }
      document.getElementById('card_list_body').appendChild(tr);
    }
    document.getElementById('card_list').style.display = 'block';
  }

  self.displayCreateResults = function(results)
  {
    if (results.status=="error")
      alert("Card not created because\n"+ Utils.format_messages(results.card));
    else
      alert(results.status);
  }

  self.getSelectedTemplate = function()
  {
    var e = document.getElementById("option_select_template")
    if (e.selectedIndex==0) return null;

    var name = e.options[e.selectedIndex].text;
    return name;
  }

  self.loadTemplates();
}

$().ready(function() {
	ko.applyBindings(new CardsViewModel(), document.getElementById("card_operations_area"));
  document.getElementById('card_list').style.display = 'none';
});
