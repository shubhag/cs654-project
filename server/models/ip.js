var mongoose = require('mongoose');
module.exports = mongoose.model('Ip',{
	ip: String,
	address: String,
	busy: Boolean
});