// dex2-utils.js
//

var Globals = Globals || {};

Globals.PropertyTypes = [];
Globals.CurrentDisplayMode = '';

var Utils = Utils || {};

Utils.set_display = function(mode)
{
	if (Globals.CurrentDisplayMode!='admin' && mode=='admin')
	{
		document.getElementById("card_operations_area").style.display = 'none';
		ko.cleanNode(document.getElementById("card_operations_area"));
		ko.cleanNode(document.getElementById("template_admin_area"));
		ko.applyBindings(new TemplatesViewModel(), document.getElementById("template_admin_area"));
		document.getElementById("template_admin_area").style.display = 'block';
		Globals.CurrentDisplayMode = 'admin';
	}
	else if (Globals.CurrentDisplayMode!='cards' && mode=='cards')
	{
		document.getElementById("template_admin_area").style.display = 'none';
		ko.cleanNode(document.getElementById("card_operations_area"));
		ko.cleanNode(document.getElementById("template_admin_area"));
		ko.applyBindings(new CardsViewModel(), document.getElementById("card_operations_area"));
		Globals.CurrentDisplayMode = 'cards';
		document.getElementById("card_operations_area").style.display = 'block';
	}
}

Utils.format_messages = function(msg_object)
{
	var ase_msgs = '';
	var other_msgs = '';

	for (var msg_type in msg_object)
	{
		if (msg_type!='base') other_msgs += msg_type + ":\n";
		var msgs = msg_object[msg_type];
		for (var i=0; i<msgs.length; i++)
		{
			if (msg_type=='base')
				base_msgs += msgs[i] + '\n';
			else
				other_msgs += msgs[i] + '\n';
		}
	}
	return  base_msgs + (base_msgs!='' ? '\n-----\n' : '') + other_msgs;
}

Utils.get_template = function(name, ok_callback, err_callback)
{
	$.get("/templates.json?name="+name, ok_callback, err_callback);
}

