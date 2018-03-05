module.exports = {
  run: function (assertEqual) {

    var data = { 'a': 'b', 'c': 'd' };
    function fn() {
      var ret = '';
      for (var name in data) {
        if (data.hasOwnProperty(name)) {
          ret += data[name];
        }
      }
      return ret;
    }

    assertEqual(fn(), 'bd');

  }
};
