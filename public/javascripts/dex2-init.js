// dex2-init.js

function TemplatesViewModel() {
    // Data
    var self = this;
    self.templates = ko.observable();
    self.selectedTemplate = ko.observable();
    self.selectedTemplateName = ko.observable();
    
    // Behaviours
    self.displayTemplates = function () {
    	$.get("/templates.json", {}, function(resp) {
    		self.templates(resp.template);
    	});
    };
    self.selectTemplate = function(name) {
    	$.get("/templates.json?name="+name, {}, function(resp) {
    		self.selectedTemplate(resp.template);
            self.selectedTemplateName(resp.template.name);
    	});
    };
    self.deleteProperty = function(property) {
      alert("delete "+property.name);
    };

    self.displayTemplates();
};

$().ready(function() {
	ko.applyBindings(new TemplatesViewModel());
});
