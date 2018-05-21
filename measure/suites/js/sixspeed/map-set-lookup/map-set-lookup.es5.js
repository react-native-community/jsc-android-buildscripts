module.exports = {
  run: function (assertEqual) {

    var keys = [],
      values = [],
      set = [],
      key = {};

    for (var i = 0; i < 50; i++) {
      keys.push(i);
      values.push(i);
      set.push(i);
    }

    keys.push(key);
    values.push('bar');
    set.push(key);

    function fn() {
      return set.indexOf(key) >= 0 && keys.indexOf(key) >= 0;
    }

    assertEqual(fn(), true);

  }
};
