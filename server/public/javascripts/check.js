$(document).ready(function(){
	$("form").submit(function(){
	var fileName = $("#fileUpload").val();
	if(fileName) { // returns true if the string is not empty
	    alert(fileName + " was selected");
	} else { // no file was selected
	    alert("no file selected");
	    return false; //<---- Add this line.
	}
	});
});