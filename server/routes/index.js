var express = require('express');
var multer = require('multer');
var path = require('path');
var util = require("util");
var exec = require('exec');
var router = express.Router();
var Ip = require('../models/ip.js');
var Instance = require('../models/instance.js');

var isAuthenticated = function (req, res, next) {
	// if user is authenticated in the session, call the next() to call the next request handler 
	// Passport adds this method to request object. A middleware is allowed to add properties to
	// request and response objects
	if (req.isAuthenticated())
		return next();
	// if the user is not authenticated then redirect him to the login page
	res.redirect('/');
}

module.exports = function(passport){

	/* GET login page. */
	router.get('/', function(req, res) {
    	// Display the Login page with any flash message, if any
		res.render('index', { message: req.flash('message') });
	});

	/* Handle Login POST */
	router.post('/login', passport.authenticate('login', {
		successRedirect: '/server',
		failureRedirect: '/',
		failureFlash : true  
	}));

	/* GET Registration Page */
	router.get('/signup', function(req, res){
		res.render('register',{message: req.flash('message')});
	});

	/* Handle Registration POST */
	router.post('/signup', passport.authenticate('signup', {
		successRedirect: '/server',
		failureRedirect: '/signup',
		failureFlash : true  
	}));

	/* GET Home Page */
	router.get('/home', isAuthenticated, function(req, res){
		res.render('home', { user: req.user });
	});

	/* Handle Logout */
	router.get('/signout', function(req, res) {
		req.logout();
		res.redirect('/');
	});


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


	router.get('/server', isAuthenticated,function(req,res){
	    res.sendFile(__dirname + "/create_server.html");
	});

	// router.get('/temp', isAuthenticated,function(req,res){
	//     res.sendFile(__dirname + "/instances.html");
	// });

	router.get('/upload', isAuthenticated,function(req,res){
	    res.redirect = "/";
	});

	router.post('/terminate', isAuthenticated,function(req,res){
		exec('bash files/terminate.sh',function(err,stdout,stderr){
            console.log(stdout);
        })
		res.redirect = "/server";
	});
	router.post('/add_servers', isAuthenticated,function(req,res){
			exec('bash files/addserver.sh',function(err,stdout,stderr){
	            console.log(stdout);
	        })
			// res.redirect = "/server";
			res.end("Added extra servers");
		});

	router.get('/instances', isAuthenticated, function(req, res){
		Instance.find({'username': req.user.username}, function(err, instances){
			if(err){
				return res.end("Unable to process request");
			} else{
				return res.render('instances', { user: req.user, instances:instances });
			}
		})
	});
	router.post('/upload', isAuthenticated,function(req,res){
	    console.log('Uploading')
	    uploading(req,res,function(err) {
	        if(err) {
	            return res.end("Error uploading file.");
	        }
	        console.log(req.body)
	        var arg1 = req.body.server_name
	        var arg2 = req.body.number_of_servers
	        var arg3 = req.body.server_type
	        var type = req.body.type

	        Ip.findOne({'busy': false}, function(err, instance){
	        	if (err){
	        		return res.end("Error 404");
	        	}
	        	if(instance){
	        		var ip = instance.ip;
	        		var addr = instance.address;
	        		console.log(ip)
	        		console.log(addr)
	        		if ( arg3 == "simple_server"){
			            console.log("Starting Simple Server")
			            exec('bash files/simplenodeserver.sh ' + addr ,function(err,stdout,stderr){
			                console.log(stdout);
			            })
			        }
			        if ( arg3 == "advanced_server"){
			            console.log("Starting Advanced Server")
			            var arg4 = req.body.mongodb_type
			            var arg5 = req.body.load_balancer
			            if ((arg4 == "simple_mongodb") && (req.body.mongodb == "mongodb")){
			                if (arg5 == "load_balancer"){
			                	console.log('bash files/mongo-simple-with-load-balancer.sh '+ ip+ ' '+ addr+ ' '+ arg2)
			                    exec('bash files/mongo-simple-with-load-balancer.sh '+ ip+ ' '+ addr+ ' '+ arg2,function(err,stdout,stderr){
			                        console.log(stdout);

			                    })
			                }
			                else{
			                    exec('bash files/mongo-simple.sh '+addr ,function(err,stdout,stderr){
			                        console.log(stdout);
			                    })
			                }
			            }
			            else if ((arg4 == "shard_mongodb") && (req.body.mongodb == "mongodb")){
			            		var numShards = req.body.number_of_shards
			                    exec('bash files/mongo-shard.sh 6 '+ ip+ ' '+ arg2 + ' ' +addr + ' '+numShards ,function(err,stdout,stderr){
			                        console.log(stdout);
			                    })
			            }
			            else if ((arg4 == "replica_mongodb") && (req.body.mongodb == "mongodb")){
			                    exec('bash files/mongo-replica-with-load-balancer.sh '+ ip+ ' '+ arg2 + ' '+addr ,function(err,stdout,stderr){
			                        console.log(stdout,err);
			                    })
			            }
			            else{
			                exec('bash files/load-balancer.sh ' + ip+ ' '+ addr+ ' '+ arg2 ,function(err,stdout,stderr){
			                    console.log(stdout);
			                })
			            }
			        }
					Ip.findOneAndUpdate({ip:ip}, {busy: true}, {upsert:true}, function(err, doc){
					    if (err){
					    	console.log('error in updating database')
					    } else{
					    	console.log('busy updated')
					    }
					});
					var newInstance = new Instance();
						newInstance.username = req.user.username;
						newInstance.numServer = arg2;
						newInstance.ip = ip;
						newInstance.address = addr; 
						newInstance.type = type;
						newInstance.name = arg1
						newInstance.save(function(err) {
                            if (err){
                                console.log('Error in user instance');  
                            }
                            console.log('User Instance saved');    
                        });
	        	} 
	        	else{
	        		return ;
	        	}
	        })
	        
	        res.redirect('/instances');
	        // res.end("Server has started");
	        // res.sendFile(__dirname + "/uploaded.html");
	    });
	});

	return router;
}





