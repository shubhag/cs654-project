 $("#docker_details_form").on("submit", function(){
	if ($('#fileUpload').get(0).files.length === 0) {
	    console.log("No files selected.");
	}
})