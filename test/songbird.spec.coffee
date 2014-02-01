require '../src/songbird'
{expect, should} = require('chai')
should()

class Parent
  name: 'instanceA'
  constructor: (name) -> @name = name if name?
  method1: (arg, cb) -> process.nextTick => cb null, "#{@name}.method1(#{arg})"
  @static1 = (arg, cb) -> process.nextTick => cb null, "#{@name}.static1(#{arg})"

class Child extends Parent
  name: 'instanceB'
  method2: (arg, cb) -> process.nextTick => cb null, "#{@name}.method2(#{arg})"
  @static2 = (arg, cb) -> process.nextTick => cb null, "#{@name}.static2(#{arg})"

describe 'Songbird', ->
  describe 'promise', ->

    describe 'Prototypes', ->
      it 'does not add enumerable properties to the Object prototype', ->
        expect(Object.keys(Object::)).to.be.empty

      it 'does not add enumerable properties to the Function prototype', ->
        expect(Object.keys(Function::)).to.be.empty

    describe 'Class Definition', ->
      it 'defines a promise property', ->
        expect(Parent.promise).to.exist

      it 'defines a static function on the promise property', ->
        expect(Parent.promise.static1).to.exist

    describe 'Instantiated Class', ->
      {a} = {}

      beforeEach ->
        a = new Parent()
        a.method3 = (arg, cb) -> process.nextTick => cb null, "#{@name}.method3(#{arg})"

      it 'defines a instance function method1 on the promise property', ->
        expect(a.promise.method1).to.exist

      it 'defines a promise property on instance of Parent Class', ->
        expect(a.promise).to.exist

      it 'caches the results on the object', ->
        expect(a.promise).to.equal a.promise

      it 'caches the results on the prototype', ->
        expect(Object.getPrototypeOf(a.promise)).to.equal Parent.prototype.promise

      describe 'Overriding Object Prototype methods', ->
        beforeEach ->
          a.toString = -> 'alternate toString'

        it 'does not copy over overwritten methods to promise', ->
          expect('toString' in Object.keys(a.promise)).to.be.false

      describe 'Enumerable Properties', ->
        beforeEach ->
          #invoke the getters to ensure the properties are created
          expect(a.promise).not.to.be.null
          expect(a.__songbird__).not.to.be.null

        it 'object contains added method', ->
          # enumerable properties defined on object a
          expect(Object.keys(a)).to.include.members ['method3']

        it 'promise is not enumerable', ->
          expect('promise' in Object.keys(a)).not.to.be.true

        it 'object contains all enumerable properties', ->
          keys = (key for key of a)
          expect(keys).to.include.members ['method3', 'name', 'method1']

      describe 'Prototype Chain', ->

        it 'only uses a prototype chain, containing only its own methods', ->
          expect(Object.keys(a.promise)).to.include.members ['that',  'method3']

        it 'properly sets up the prototype chain of the proxies to derive from Object.prototype', ->
          # There was a bug with a null root of the prototype chain which was causing weird exception stack traces
          expect(a.promise.__lookupGetter__).to.exist
          expect(Parent.promise.__lookupGetter__).to.exist

    describe 'Inheritance', ->
      {a, b} = {}

      beforeEach ->
        a = new Parent()
        b = new Child()

      it 'supports static methods in the parent class', (done) ->
        Parent.promise.static1(5).then (value) ->
          expect(value).to.equal 'Parent.static1(5)'
          done()

      it 'supports static methods in the child class', (done) ->
        Child.promise.static2(10).then (value) ->
          expect(value).to.equal 'Child.static2(10)'
          done()

      it 'supports instance methods inherited from a base class', (done) ->
        b.promise.method1(4).then (value) ->
          expect(value).to.equal 'instanceB.method1(4)'
          done()

      it 'supports instance methods from a child class', (done) ->
        b.promise.method2(6).then (value) ->
          expect(value).to.equal 'instanceB.method2(6)'
          done()

      describe 'Enumerable Properties on an inherited instance', ->
        beforeEach ->
          #invoke the getters to ensure the properties are created
          expect(b.promise).not.to.be.null
          expect(b.__songbird__).not.to.be.null

        it 'object contains added method', ->
          # enumerable properties defined on object a
          expect(Object.keys(a).length).to.equal 0

        it 'object contains all enumerable properties', ->
          keys = (key for key of b)
          expect(keys).to.include.members ['constructor', 'name', 'method2', 'method1']

      describe 'Another object of the same type', ->
        {aDog, bCat} = {}

        beforeEach ->
          aDog = new Parent('dog')
          bCat = new Child('cat')

        it 'supports instance methods inherited from a base class', (done) ->
          bCat.promise.method1(3).then (value) ->
            expect(value).to.equal 'cat.method1(3)'
            done()

        it 'supports instance methods from a child class', (done) ->
          bCat.promise.method2(5).then (value) ->
            expect(value).to.equal 'cat.method2(5)'
            done()

    describe 'Overriding promise property', ->
      {p} = {}
      beforeEach ->
        p = ->
        expect(Parent.promise).not.to.equal p
        Parent.promise = p

      it 'Allows the property to be overriden', ->
        expect(Parent.promise).to.equal p

      it 'promise is now enumerable', ->
        expect('promise' in Object.keys(Parent)).to.be.true

    describe 'getter functions', ->
      {obj} = {}
      beforeEach ->
        obj = {}
        Object.defineProperty obj, 'someGetter',
          get: ->
            (cb) -> cb(null, 'some result')
          enumerable: true

      it 'are enumerable', ->
        expect('someGetter' in Object.keys(obj)).to.be.true

      it 'are functions', ->
        expect(typeof obj.someGetter).to.equal 'function'

      it 'are ignored by promise', ->
        expect(obj.promise.someGetter).not.to.exist

    describe 'Errors', ->
      {f, boom} = {}
      beforeEach ->
        boom = new Error('BOOM')
        f = (cb) -> throw boom

      it 'return errors via the catch() method', (done) ->
        f.promise().then( (value) ->
          expect(value).not.to.exist
        ).catch (e) ->
          done()

    describe 'Functions', ->
      {f} = {}

      beforeEach ->
        f = (cb) ->
          process.nextTick =>
            cb(null, "#{@}.f()")

      it 'are supported', (done) ->
        f.promise().then (value) ->
          expect(value).to.equal '[object global].f()'
          done()

      it 'are supposed using call() or apply()', (done) ->
        f.promise.call(10).then (value) ->
          expect(value).to.equal '10.f()'
          done()

      describe 'As prototypes', ->
        {obj} = {}

        beforeEach ->
          f.staticF = (cb) ->
            process.nextTick =>
              cb(null, "#{@}.staticF()")
          f.toString = -> 'f'

          obj = Object.create(f)
          obj.toString = -> 'obj'

        it 'are supported', (done) ->
          f.promise.staticF().then (value) ->
            expect(value).to.equal 'f.staticF()'
            done()

        it 'are supported when creating objects from the functions', (done) ->
          obj.promise.staticF().then (value) ->
            expect(value).to.equal 'obj.staticF()'
            done()

      describe 'using functions as prototypes of other functions', ->
        {otherF} = {}

        beforeEach ->
          f.staticF = (cb) ->
            process.nextTick =>
              cb(null, "#{@}.staticF()")
          f.toString = ->
            'f'

          otherF = ->
          otherF.__proto__ = f
          otherF.toString = ->
            'otherF'

        it 'are supported', (done) ->
          f.promise.staticF().then (value) ->
            expect(value).to.equal 'f.staticF()'
            done()

        it 'are supported really well', (done) ->
          otherF.promise.staticF().then (value) ->
            expect(value).to.equal 'otherF.staticF()'
            done()
