module.exports = {
  run: function (assertEqual) {

    function fn() {
      var ret = [1];
      ret.push(1, 2, 3);
      return ret;
    }

    assertEqual(fn()[3], 3);

  }
};
