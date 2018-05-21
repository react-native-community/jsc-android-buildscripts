module.exports = {
  run: function (assertEqual) {

    class C {
      constructor() {
        this.foo = 'bar';
      }
      bar() {
        return 123;
      }
    }

    assertEqual(new C().foo, 'bar');
    assertEqual(new C().bar(), 123);
  }
};
