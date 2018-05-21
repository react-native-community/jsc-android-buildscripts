module.exports = {
  run: function (assertEqual) {

    function fn() {
      var map = {},
        set = [];

      for (var i = 0; i < 50; i++) {
        map[i] = i;
        set.push(i);
      }

      map.foo = 'bar';
      set.push('bar');
      return ('foo' in map) && set.indexOf('bar') >= 0;
    }

    assertEqual(fn(), true);

  }
};
