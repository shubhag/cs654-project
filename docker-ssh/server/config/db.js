var mongoose = require('mongoose');
var MONGO_URL = 'mongodb://localhost/';
var DB_NAME = 'example-app-db';

dbOptions = {
	db: {native_parser: true},
	replset: {
	  auto_reconnect:false,
	  poolSize: 5,
	  socketOptions: {
	    keepAlive: 1000,
	    connectTimeoutMS: 30000
	  }
	},
	server: {
	  poolSize: 5,
	  socketOptions: {
	    keepAlive: 1000,
	    connectTimeoutMS: 30000
	  }
	}
};
var replicaSet = 'ttnd';

if (process.env.MONGO_PORT) MONGO_URL = 'mongodb://mongo/';

// mongoose.connect(MONGO_URL + DB_NAME);
mongoose.connect('mongodb://172.17.0.2:27017,172.17.0.3:27017,172.17.0.4:27017/'+DB_NAME+'?replicaSet='+replicaSet)

mongoose.connection.on('error', console.error.bind(console));

module.exports = mongoose.connection;