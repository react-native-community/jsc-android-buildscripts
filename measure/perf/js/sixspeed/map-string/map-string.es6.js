module.exports = {
  run: function (assertEqual) {

    var map = new Map();

    for (var i = 0; i < 50; i++) {
      map.set(i + '', i);
    }

    function fn() {
      return map.get('49') === 49;
    }

    assertEqual(fn(), true);

  }
};
