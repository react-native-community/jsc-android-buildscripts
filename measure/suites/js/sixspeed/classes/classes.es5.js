module.exports = {
  run: function (assertEqual) {

    function C() {
      this.foo = 'bar';
    }
    C.prototype.bar = function () {
      return 123;
    };

    assertEqual(new C().foo, 'bar');
    assertEqual(new C().bar(), 123);

  }
};
