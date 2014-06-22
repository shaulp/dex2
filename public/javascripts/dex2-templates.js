// dex2-templates.js

function TemplatesViewModel() {
  // Data
  var self = this;
  var action_property;
  var newTemplateName;

  self.templates = ko.observable();
  self.selectedTemplate = ko.observable();
  self.selectedTemplateName = ko.observable();
  Globals.PropertyTypes = ko.observableArray(["String","Number"]);

  // Behaviours

  self.displayTemplates = function () {
    self.templates([]);
  	$.get("/templates.json", {}, function(resp) {
  		self.templates(resp.template);
  	});
  };

  self.selectTemplate = function(template) {
    var name = template.name
    Utils.get_template(name, self.selectedTemplateResponse, null);
  };

  self.selectedTemplateResponse = function(resp) {
    self.selectedTemplate(resp.template);
    self.selectedTemplateName(resp.template.name);
  };

  self.clearPropertyArea = function()
  {
    self.selectedTemplate({name:"", properties:[]});
    self.selectedTemplateName("");
  };
  self.addTemplate = function()
  {
    newTemplateName = document.getElementById("template_name").value;
    $.ajax({
      url:"/templates.json",
      type:'post',
      contentType: "application/json",
      data:JSON.stringify({name:newTemplateName}),
      success:function(resp) { self.handleAddTemplateResponse(resp); }
    });
  }
  self.delTemplate = function(template)
  {
    var name = template.name
    $.ajax({
      url:"/templates/" + name + ".json",
      type:'delete',
      contentType: "application/json",
      data:JSON.stringify({name:newTemplateName}),
      success:function(resp) { self.handleDelTemplateResponse(resp); }
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
      self.selectTemplate({name:self.selectedTemplateName()});
  };

  self.handleAddPropResponse = function(resp)
  {
    if (resp.status=="error")
      alert("Property not added because\n"+ Utils.format_messages(resp.template));
    else
      self.selectTemplate({name:self.selectedTemplateName()});
  };

  self.handleAddTemplateResponse = function(resp)
  {
    if (resp.status=="error")
      alert("Template not added because\n"+ Utils.format_messages(resp.template));
    else
    {
      document.getElementById("template_name").value = '';
      self.displayTemplates();
      self.selectTemplate({name:newTemplateName});
    }
  }

  self.handleDelTemplateResponse = function(resp)
  {
    if (resp.status=="error")
      alert("Template not deleted because\n"+ Utils.format_messages(resp.template));
    else
    {
      self.displayTemplates();
      self.clearPropertyArea();
    }
  }

  self.loadPropertyTypes = function()
  {
    $.get("/properties/types.json", {}, function(resp) {
      Globals.PropertyTypes = resp.template.property_types;
    });    
  }

  self.displayTemplates();
  self.loadPropertyTypes();
};

//$().ready(function() {
//	ko.applyBindings(new TemplatesViewModel(), document.getElementById("template_admin_area"));
//});
