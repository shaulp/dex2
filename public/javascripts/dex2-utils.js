// dex2-utils.js
//
var Utils = Utils || {};

Utils.format_messages = function(msg_object)
{
	var base_msgs = '';
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
