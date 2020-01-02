require ('../lib/songbird')
var chai = require('chai');
var expect = chai.expect;

describe('ECMA only', function() {
  var ver = parseFloat(process.versions.node.split('.').slice(0, 2).join('.'));

  // node < 8 doesn't have the `async` keyword
  if (ver < 8) {
    return;
  }

  it('support chaining with async function', function(done) {
    var functions = require('./function');
    functions.promise.async().then(function(value) {
      expect(value).to.equal('async');
      done();
    });
  });
});
