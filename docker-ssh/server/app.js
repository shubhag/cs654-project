//Lets require/import the HTTP module
var http = require('http');
var dispatcher = require('httpdispatcher');

var express = require('express');
var fs = require('fs');
var bodyParser = require('body-parser');
var app = express();

app.use(bodyParser.urlencoded({
	extended: true
}));

app.use(bodyParser.json());
const PORT=80; 

app.get('/', function(req, res){
	res.writeHead(200, {'Content-Type': 'text/plain'});
	res.end('Server with Simple MongoDB and Load Balancer !!!');
	// res.send(JSON.stringify({"name": "Lucky Sahani"}));
})

app.post('/sum', function(req, res){
	// console.log(req.body)
	var num1 = parseFloat(req.body.num1);
	var num2 = parseFloat(req.body.num2);
	var add_result ;
	res.setHeader('Content-Type', 'application/json');
	add_result = num1+num2;
	console.log('Adding two numbers :',num1,' and ',num2,' = ',add_result)
	res.send(JSON.stringify({"status": "true", "add": add_result}));
});

app.listen(PORT);
console.log('Listening at http://localhost:' + PORT);