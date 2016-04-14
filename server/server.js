//Lets require/import the HTTP module
var http = require('http');
var multer = require('multer');
var dispatcher = require('httpdispatcher');

var express = require('express');
var fs = require('fs');
var bodyParser = require('body-parser');
var path = require('path');
var util = require("util");

var app = express();

app.use(bodyParser.urlencoded({
	extended: true
}));

app.use(bodyParser.json());

const PORT=8080; 

app.get('/home', function(req, res){
	res.writeHead(200, {'Content-Type': 'text/plain'});
	res.end('Nice to meet you !!!');
})

var storage =   multer.diskStorage({
  destination: function (req, file, callback) {
    callback(null, './public/uploads');
  },
  filename: function (req, file, callback) {
    // callback(null, file.fieldname + '-' + Date.now());
    callback(null, file.fieldname) ;
  }
});

var uploading = multer({ storage : storage}).single("code")


app.get('/',function(req,res){
      res.sendFile(__dirname + "/views/index.html");
});

app.post('/upload',function(req,res){
	console.log('hi')
    uploading(req,res,function(err) {
        if(err) {
            return res.end("Error uploading file.");
        }
        res.end("File is uploaded");
    });
});

// app.post('/upload', function(req, res){
	// console.log(req.body)
	// var num1 = parseFloat(req.body.num1);
	// var num2 = parseFloat(req.body.num2);
	// var add_result ;
	// res.setHeader('Content-Type', 'application/json');
	// add_result = num1+num2;
	// console.log('Adding two numbers :',num1,' and ',num2,' = ',add_result)
	// res.send(JSON.stringify({"status": "true", "add": add_result}));
// });

app.listen(PORT);
console.log('Listening at port ' + PORT);