module.exports = {
  run: function (assertEqual) {

    var obj = {
      value: 42,
      fn: function () {
        return function () {
          return obj.value;
        };
      }
    };

    var fn = obj.fn();
    assertEqual(fn(), 42);

  }
};
