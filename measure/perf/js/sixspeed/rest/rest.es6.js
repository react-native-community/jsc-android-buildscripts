module.exports = {
  run: function (assertEqual) {

    function fn(foo, ...args) {
      return args[0];
    }

    assertEqual(fn(), undefined);
    assertEqual(fn(2), undefined);
    assertEqual(fn(2, 4), 4);

  }
};
