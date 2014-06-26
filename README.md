[![Build Status](https://travis-ci.org/duereg/songbird.svg)](https://travis-ci.org/duereg/songbird)
[![Dependencies](https://david-dm.org/duereg/songbird.svg)](https://david-dm.org/duereg/songbird)
[![devDependencies](https://david-dm.org/duereg/songbird/dev-status.svg)](https://david-dm.org/duereg/songbird#info=devDependencies&view=table)
[![NPM version](https://badge.fury.io/js/songbird.svg)](http://badge.fury.io/js/songbird)

Songbird
=======

Easily mix asynchronous and synchronous programming styles in node.js.

Mix promises into all the objects in your code base.

Songbird is built upon the bluebird promise library (hence the name).

If you have any questions about what methods the promises expose, go [here](https://raw2.github.com/petkaantonov/bluebird/master/API.md) to view the bluebird API.

*A project by [Matt Blair](http://mattblair.co) at https://github.com/duereg/songbird.*

Install
-------

Songbird requires node version 0.6.x or greater.

```
npm install songbird
```


Examples
-----

Would you rather write this:

```javascript
var updateUser = function(id, attributes, callback) {
  User.findOne(id, function (err, user) {
    if (err) return callback(err);

    user.set(attributes);
    user.save(function(err, updated) {
      if (err) return callback(err);

      console.log("Updated", updated);
      callback(null, updated);
    });
  });
});
```

Or this, which behaves identically:

```coffeescript

  User.promise.findOne(id).then( (user) →
    user.set(attributes)
    user.promise.save()
  ).then (user) -> console.log("Updated", user)
```

### Without Songbird

Using standard node callback-style APIs without Songbird, we write
(from [the fs docs](http://nodejs.org/docs/v0.6.14/api/fs.html#fs_fs_readfile_filename_encoding_callback)):

```javascript
fs.readFile('/etc/passwd', function (err, data) {
  if (err) throw err;
  console.log(data);
});
```

### Using the promise property

Using Songbird, we write:

```javascript
fs.promise.readFile('/etc/passwd').then(console.log);
```

### Console

Songbird makes it much easier to work with asynchronous methods in an
interactive console, or REPL.

If you find yourself in an interactive session, you can require Songbird so that
you can use `promise`.

```
> fs = require('fs');
> require('songbird');
> fs.promise.readFile('/etc/passwd', 'utf8').then (data) → data.get()
```

```
$ songbird
Starting Songbird node REPL...
> fs = require('fs');
> fs.promise.readFile('/etc/passwd', 'utf8').then(console.log)
##
# User Database
#
...
```

Or for a CoffeeScript REPL:

```
$ songbird -c [or --coffee]
Starting Songbird coffee REPL...
coffee> fs = require 'fs'
coffee> fs.promise.readFile('/etc/passwd', 'utf8').then console.log
##
# User Database
#
...
```
### Object & Function mixins

Songbird mixes `promise` into `Function.prototype` so you can
use them directly as in:

```javascript
readFile = require('fs').readFile;
readFile.promise('/etc/passwd').then(console.log);
```

Songbird adds `promise` to `Object.prototype` correctly so they
are not enumerable.

These proxy methods also ignore all getters, even those that may
return functions. If you need to call a getter with Songbird that returns an
asynchronous function, you can do:

```javascript
func = obj.getter
func.promise.call(obj, args)
```

### Handling Multiple Promises

Requiring the songbird library not only updates the Object and Function prototype, but also returns a Promise library in which you can carry out certain actions that aren't easily handled from the the promise property.

For example: you have a situation where you're dealing with multiple promises, but don't care what order they complete in.

```js
Promise = require("songbird");

Promise.all([task1, task2, task3]).spread(function(result1, result2, result3){

});
```

Normally when using `.then` the code would be like:

```js
Promise = require("songbird");

Promise.all([task1, task2, task3]).then(function(results){
    var result1 = results[0];
    var result2 = results[1];
    var result3 = results[2];
});
```

For more information about the underlying bluebird promise API, the [API docs are here](https://raw2.github.com/petkaantonov/bluebird/master/API.md).

### Disclaimer

Some people don't like libraries that mix in to Object.prototype
and Function.prototype. If that's how you feel, then Songbird is probably
not for you.

Contributing
------------

```
git clone git://github.com/duereg/songbird.git
npm install
npm test
```

Songbird is written in [coffeescript](http://coffeescript.org) with
source in `src/` compiled to `lib/`.

Tests are written with mocha and chai in `test/`.

Run tests with `npm test` which will also compile the coffeescript to
`lib/`.

Pull requests are welcome. Please provide tests for your changes and
features. Thanks!

License
-------

(The MIT License)

Copyright (c) 2014 Matt Blair

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

