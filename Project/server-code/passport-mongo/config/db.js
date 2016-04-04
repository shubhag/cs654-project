var mongoose = require('mongoose');
var MONGO_URL = 'mongodb://localhost/';
var DB_NAME = 'example-app-db';

if (process.env.MONGO_PORT) MONGO_URL = 'mongodb://mongo/';

mongoose.connect(MONGO_URL + DB_NAME);

mongoose.connection.on('error', console.error.bind(console));

module.exports = mongoose.connection;