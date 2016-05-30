
function init_wf() {
    console.log("calling watchfield");
    $("#q").watchfield({
	name : "wf1",
	delay : 700,
	changed : function(event,ui) {
            $('header.search form').submit();
	}
    });
}


$(document).ready(function() {
    init_wf();
    $('#search-options1 .btn').button();
    $('#search-options2 .btn').button();

});
