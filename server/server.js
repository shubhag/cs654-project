//Lets require/import the HTTP module
var http = require('http');
var multer = require('multer');
var dispatcher = require('httpdispatcher');

var express = require('express');
var fs = require('fs');
var bodyParser = require('body-parser');
var path = require('path');
var util = require("util");
var exec = require('exec');

var app = express();

app.use(bodyParser.urlencoded({
	extended: true
}));

app.use(bodyParser.json());
app.use("/css", express.static(__dirname + '/public/stylesheets'));
app.use("/js", express.static(__dirname + '/public/javascripts'));

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

app.get('/upload',function(req,res){
	res.redirect = "/";
});

app.post('/upload',function(req,res){
	console.log('Uploading')
    uploading(req,res,function(err) {
        if(err) {
            return res.end("Error uploading file.");
        }
        console.log(req.body)
        var arg1 = req.body.server_name
        var arg2 = req.body.number_of_servers
        var arg3 = req.body.server_type

        if ( arg3 == "simple_server"){
        	console.log("Starting Simple Server")
	        exec('bash files/nodemongo.sh 1' ,function(err,stdout,stderr){
				console.log(stdout);
			})
        	res.end("Simple Server has started");
		}
		if ( arg3 == "advanced_server"){
			console.log("Starting Advanced Server")
			var arg4 = req.body.mongodb_type
			var arg5 = req.body.load_balancer
			// console.log(arg5+"hi")
			if (arg4 == "simple_mongodb"){
				if (arg5 == "load_balancer"){
			        exec('bash files/loadbalancermongo.sh ' + arg1+" "+arg2+" "+arg3 ,function(err,stdout,stderr){
						console.log(stdout);
					})
				}
				else{
					exec('bash files/loadbalancermongo.sh ' + arg1+" "+arg2+" "+arg3 ,function(err,stdout,stderr){
						console.log(stdout);
					})
				}
		    }
		    else if (arg4 == "shard_mongodb"){
		        exec('bash files/mongo-shard.sh ' + arg1+" "+arg2+" "+arg3 ,function(err,stdout,stderr){
					console.log(stdout);
				})
		    }
		    else if (arg4 == "replica_mongodb"){
		        exec('bash files/mongo-replica.sh ' + arg1+" "+arg2+" "+arg3 ,function(err,stdout,stderr){
					console.log(stdout);
				})
		    }
		    else{
		    	exec('bash files/loadbalancernode.sh ' + arg1+" "+arg2+" "+arg3 ,function(err,stdout,stderr){
					console.log(stdout);
				})
		    }
		}
        res.end("Server has started");
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