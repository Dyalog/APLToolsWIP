
function Hide_ejAccSection(id,idx) {
	var div = $("#" + id + "_section_" +idx);
	div.hide();
	div.prev().hide();
}

function Show_ejAccSection(id,idx) {
	var div = $("#" + id + "_section_" +idx);
	div.show();
	div.prev().show();
	$("#" + id).ejAccordion("expandPanel",idx-1);
}


 function ApplyOptimizersPick() {
 	var id =  $("[name='optpick_pack']").val();
	 $("#pSelPack option[value='p" + id + "']").prop("selected",true);
	if ($("[name='optpick_items']").val().length)
	{
		var liste = $("[name='optpick_items']").val().trim().split(" ");
		for (var i=0;i<liste.length;i++)
		{
			id=liste[i];
				   $('#' + id ).prop("checked",true);
		}
	}
	$("#regform").trigger("UpdateInvoice");
}