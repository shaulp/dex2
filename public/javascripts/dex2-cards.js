// dex2-cards.js

function CardsViewModel() {
  // Data
  var self = this;
  self.templates = ko.observable();
  self.selectedTemplate = ko.observable();
  self.selectedTemplateName = ko.observable();

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
    var title = document.getElementById("value_title").value;
    var params = {"template_name":template, "title":title, "properties":{}};
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
    alert(results);
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
});
