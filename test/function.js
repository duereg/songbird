const sleep = (ms) => {
    return new Promise((res, rej) => {
        setTimeout(res, ms);
    });
}

module.exports = {
  async: async() => {
    await sleep(10);
    return 'async';
  },
  sync: (cb) => {
    sleep(10).then(() => {
      return cb(null, 'sync');
    });
  },
};
