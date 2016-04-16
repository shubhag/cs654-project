$(document).ready(function(){
	$("form").submit(function(){
		console.log("Form submitted")
		var fileName = $("#fileUpload").val();
		if(fileName) { 
		    // alert(fileName + " was selected");
		} else { 
		    alert("Please select a file");
		    return false; 
		}
		if (!(document.getElementById('mongodb').checked) && !(document.getElementById('mongodb').checked)){
			alert("Please select mongodb or load balancer");
			return false;
		}
	});
	$('input[type="radio"]').click(function() {
		if($(this).attr('id') == 'simple_server') {
			$('#advanced_options').hide();           
		}

       else{
			$('#advanced_options').show();   
       }
    });
	$('input[type="checkbox"]').change(function() {
    if ($('#mongodb').prop('checked')) {
        $('#mongodb_check').show();
    } else {
        $('#mongodb_check').hide();
    }
});
});