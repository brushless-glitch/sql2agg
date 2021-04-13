var fs = require('fs');
var p = new require('./parser.js');

var myArgs = process.argv.slice(2);
var input = myArgs.length ? myArgs[0] : 0;

var data = fs.readFileSync(input, 'utf-8');
var result = p.run(data);

console.log(result);
console.log("");