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
var options = {
  db: { native_parser: true },
  server: { poolSize: 5 },
  replset: { rs_name: replicaSet}
}
//mongoose.connect('mongodb://mongo1.ttnd.com:27017/'+DB_NAME, options);
mongoose.connect('mongodb://mongos:27017/'+DB_NAME, {mongos: true})

if (process.env.MONGO_PORT) MONGO_URL = 'mongodb://mongo/';

// mongoose.connect(MONGO_URL + DB_NAME);

mongoose.connection.on('error', console.error.bind(console));

module.exports = mongoose.connection;
