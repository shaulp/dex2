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
  	var e = document.getElementById("option_select_template")
  	if (e.selectedIndex==0) return;

  	var name = e.options[e.selectedIndex].text;

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

  self.loadTemplates();
}

$().ready(function() {
	ko.applyBindings(new CardsViewModel(), document.getElementById("card_operations_area"));
});
