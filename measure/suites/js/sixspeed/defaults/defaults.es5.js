module.exports = {
  run: function (assertEqual) {

    function fn(arg, other) {
      arg = arg === undefined ? 1 : arg;
      other = other === undefined ? 3 : other;
      return arg + other;
    }

    assertEqual(fn(), 4);
    assertEqual(fn(2), 5);
    assertEqual(fn(1, 2), 3);

  }
};
