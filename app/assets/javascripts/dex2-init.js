// dex2-init.js

function TemplatesViewModel() {
    // Data
    var self = this;
    self.templates = ko.observable();

    // Behaviours
    self.loadTemplates = function() {
    	$.getJSON("/templates.json", {}, self.setTemplates);
    };
    self.setTemplates = function (jsonResp) {
    	resp = JSON.parse(jsonResp);
    	if (resp.status=="ok")
    		self.templates = resp.template;
    	else
    		self.templates = [];
    };
};

ko.applyBindings(new TemplatesViewModel());
