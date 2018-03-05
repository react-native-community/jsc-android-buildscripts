module.exports = {
  run: function (assertEqual) {


    function* generator() {
      yield 1;
      yield 2;
    }

    function fn() {
      var iterator = generator();
      iterator.next();
      iterator.next();
      return iterator.next().done;
    }

    assertEqual(fn(), true);

  }
};
