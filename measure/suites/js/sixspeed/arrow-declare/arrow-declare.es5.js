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

    assertEqual(obj.fn()(), 42);

  }
};
