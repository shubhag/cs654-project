$(document).ready(function(){
	$("form").submit(function(){
		console.log("Form submitted")
		// var fileName = $("#fileUpload").val();
		// if(fileName) { 
		//     // alert(fileName + " was selected");
		// } else { 
		//     alert("Please select a file");
		//     return false; 
		// }
		$('#loading').show();
		$('.windows8').show();
		$(".fakeloader").fakeLoader();

		sleepFor(10000);
	});

	$('.image').click(function() {
		$('.panel-body').hide();
		$(this).parent().siblings().show();
		console.log($(this).parent().siblings());
		$(this).closest('.panel-body').show();
	});
	function sleepFor( sleepDuration ){
	    var now = new Date().getTime();
	    while(new Date().getTime() < now + sleepDuration){ /* do nothing */ } 
	}
});