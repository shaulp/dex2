// dex2-init.js

// delete property key mismatch
// extract and format errors

function TemplatesViewModel() {
  // Data
  var self = this;
  var action_property;
  var newTemplateName;

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
  self.addTemplate = function()
  {
    newTemplateName = document.getElementById("template_name").value;
    $.post({
      url:"/templates.json",
      contentType: "application/json",
      data:JSON.stringify({name:self.selectedTemplateName()}),
      success:function(resp) { self.handleAddPTemplateResponse(resp); }
    });
  }
  self.addProperty = function()
  {
    var pName = document.getElementById("prop_name").value;
    var pType = document.getElementById("prop_type").value;
    var pValidation = document.getElementById("prop_validation").value;
    $.ajax({
      url:"/templates/add_property.json",
      type:'put', 
      contentType: "application/json",
      data:JSON.stringify({name:self.selectedTemplateName(), 
        property:{name:pName, type:pType, validation:pValidation}}),
      success:function(resp) { self.handleAddPropResponse(resp); }
    });
  }
  self.deleteProperty = function(property) {
    action_property = property;
    $.ajax({
      url:"/templates/delete_property.json",
      type:'put', 
      contentType: "application/json",
      data:JSON.stringify({name:self.selectedTemplateName(), property:{name:property.name}}),
      success:function(resp) { self.handleDeletePropResponse(resp); }
    });
  };

  self.handleDeletePropResponse = function(resp)
  {
    if (resp.status=="error")
    {
      if (resp.template.key)
      {
        if (confirm("This template has cards. Are you sure you want to delete a property?")==true)
        {
          $.ajax({
            url:"/templates/delete_property.json", 
            type:'put',
            contentType: "application/json",
            data:JSON.stringify({name:self.selectedTemplateName(), property:{name:action_property.name, conf_key:resp.template.key[0]}}),
            success:self.handleDeletePropResponse
          });
        }
      }
      else
        alert("Property not deleted because "+resp.message);
    }
    else
      self.selectTemplate(self.selectedTemplateName());
  };

  self.handleAddPropResponse = function(resp)
  {
    if (resp.status=="error")
      alert("Property not added because\n"+ Utils.format_messages(resp.template));
    else
      self.selectTemplate(self.selectedTemplateName());
  };

  self.handleAddPTemplateResponse = function(resp)
  {
    if (resp.status=="error")
      alert("Template not added because\n"+ Utils.format_messages(resp.template));
    else
    {
      self.displayTemplates();
      self.selectTemplate(newTemplateName);
    }
  }

  self.displayTemplates();
};

$().ready(function() {
	ko.applyBindings(new TemplatesViewModel());
});
