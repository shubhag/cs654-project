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
	});

	$(.image).click(function() {
		$('.panel-body').hide();
		$(this).closest('.panel-body').show()
	});
});