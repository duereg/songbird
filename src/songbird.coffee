Promise = global.Promise || require("bluebird")

module.exports = Promise

if (!Promise.promisify)
  Promise.promisify = (asyncFn, context) ->
    (args...) ->
      args = Array.prototype.slice.apply(args)
      new Promise (resolve, reject) ->
        args.push (err, rets...) ->
          if err
            reject(err)
          else
            resolve.apply(context, rets)
        asyncFn.apply(context, args)

synchronize = (asyncFn) ->
  (args...) ->
    fnThis = @ is asyncFn and global or @

    Promise.promisify(asyncFn, fnThis).apply(fnThis, args)

getMethods = (src) ->
  obj = src
  keys = []

  while obj
    # Break master classes
    break if obj in [Object::, Function::]
    keys = keys.concat Object.getOwnPropertyNames(obj).filter (key) ->
      # Ignore any rewrites of toString, etc which can cause problems
      return if Object::[key]?
      # getter methods can have unintentional side effects when called in the wrong context
      return if Object.getOwnPropertyDescriptor(obj, key).get?
      # getter methods may throw an exception in some contexts
      return typeof obj[key] is 'function'
    obj = Object.getPrototypeOf(obj)

  # TODO: return unique items
  keys

proxyAll = (src, target, proxyFn) ->
  # Gives back the keys on this object, not on prototypes
  for key in getMethods(src)
    do (key) ->
      target[key] = proxyFn(key)

  target

proxyBuilder = (that) ->
  result =
    if typeof(that) is 'function'
      func = synchronize(that)
      func.__proto__ = Object.getPrototypeOf(that).promise if Object.getPrototypeOf(that) isnt Function.prototype
      func
    else
      Object.create(Object.getPrototypeOf(that) and Object.getPrototypeOf(that).promise or Object::)

  result.that = that

  proxyAll that, result, (key) ->
    (args...) ->
      # Lookup the method every time to pick up reassignments of key on obj or an instance
      func = @that[key]
      # HACK: async function will return promise
      # we don't need reproxy
      if func.constructor.name is 'AsyncFunction'
        @that[key].apply(@that, args)
      else
        @that[key].promise.apply(@that, args)

  result

definePromiseProperty = (target, factory) ->
  return if target.hasOwnProperty "promise"

  cacheKey = "__songbird__"
  Object.defineProperty target, "promise",
    enumerable: false
    set: (value) ->
      delete @[cacheKey]
      # allow overriding the property turning back to default behavior
      Object.defineProperty @, "promise", value: value, writable:true, configurable: true, enumerable: true
    get: ->
      unless Object::hasOwnProperty.call(@, cacheKey) and @[cacheKey]
        # ensure the cached version is not enumerable
        Object.defineProperty @, cacheKey, value: factory(@), writable: true, configurable: true, enumerable: false
      @[cacheKey]

# Mix promise into Object and Function prototypes
for base in [Object::, Function::]
  definePromiseProperty(base, proxyBuilder)
