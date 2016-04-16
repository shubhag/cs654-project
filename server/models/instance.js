var mongoose = require('mongoose');
module.exports = mongoose.model('Instance',{
	username: String,
	numServer: Number,
	ip: String,
	address: String,
	type: Number,
	name: String
});