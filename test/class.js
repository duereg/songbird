const sleep = (ms) => {
  return new Promise((res, rej) => {
    setTimeout(res, ms);
  });
}

class Parent {
  async asyncMethod() {
    await sleep(10);
    return 'async';
  }

  syncMethod(cb) {
    sleep(10).then(() => {
      return cb(null, 'sync');
    });
  }

  static async staticAsyncMethod() {
    await sleep(10);
    return 'static async';
  }

  static staticSyncMethod(cb) {
    sleep(10).then(() => {
      return cb(null, 'static sync')
    });
  }
}

class Child extends Parent {
  async asyncMethod() {
    await sleep(10);
    return 'override';
  }

  async asyncMethod2() {
    await sleep(10);
    return 'async2';
  }
}

module.exports = {
  Parent: Parent,
  Child: Child,
};
