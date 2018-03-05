module.exports = {
  run: function (assertEqual) {

    function fn() {
      return arguments[1];
    }

    assertEqual(fn(), undefined);
    assertEqual(fn(2), undefined);
    assertEqual(fn(2, 4), 4);

  }
};
