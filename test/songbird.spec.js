require ('../lib/songbird')
var chai = require('chai');
var expect = chai.expect;

describe('ECMA only', function() {
  var ver = parseFloat(process.versions.node.split('.').slice(0, 2).join('.'));

  // node < 8 doesn't have the `async` keyword
  if (ver < 8) {
    return;
  }

  describe('functions', function() {
    var functions = require('./function');

    it('chaining with lib function', function(done) {
      Promise.all([
        functions.promise.async().then(function(value) {
          expect(value).to.equal('async');
        }),
        functions.promise.sync().then(function(value) {
          expect(value).to.equal('sync');
        }),
      ]).then(function() { done(); }).catch(function(e) { done(e); });

    });
  });

  describe('classes', function() {
    var classes = require('./class');

    it('chaining static method', function(done) {
      Promise.all([
        classes.Parent.promise.staticAsyncMethod().then(function(value) {
          expect(value).to.equal('static async');
        }),
        classes.Parent.promise.staticSyncMethod().then(function(value) {
          expect(value).to.equal('static sync');
        }),
      ]).then(function() { done(); }).catch(function(e) { done(e); });
    });

    it('chaining with method', function(done) {
      var instance = new classes.Parent();
      Promise.all([
        instance.promise.asyncMethod().then(function(value) {
          expect(value).to.equal('async');
        }),
        instance.promise.syncMethod().then(function(value) {
          expect(value).to.equal('sync');
        }),
      ]).then(function() { done(); }).catch(function(e) { done(e); });
    });

    it('chaining with async method in subclass', function(done) {
      var instance = new classes.Child();
      Promise.all([
        instance.promise.asyncMethod().then(function(value) {
          expect(value).to.equal('override');
        }),
        instance.promise.asyncMethod2().then(function(value) {
          expect(value).to.equal('async2');
        })
      ]).then(function() { done(); }).catch(function(e) { done(e); });
    });
  });
});
