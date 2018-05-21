module.exports = {
  run: function (assertEqual) {

    var map = {};

    for (var i = 0; i < 50; i++) {
      map[i] = i;
    }

    function fn() {
      return map['49'] === 49;
    }

    assertEqual(fn(), true);

  }
};
