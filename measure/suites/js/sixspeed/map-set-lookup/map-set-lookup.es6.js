module.exports = {
  run: function (assertEqual) {

    var map = new Map(),
      set = new Set(),
      key = {};

    for (var i = 0; i < 50; i++) {
      map.set(i, i);
      set.add(i);
    }

    map.set(key, 'bar');
    set.add(key);

    function fn() {
      return map.has(key) && set.has(key);
    }

    assertEqual(fn(), true);

  }
};
