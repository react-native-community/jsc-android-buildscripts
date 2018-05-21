const _ = require('lodash');

const TIMES = 1000;

function assertEqual(a, b) {
  if (a != b) throw new Error(`expected ${a} toEqual ${b}`);
}

function run() {
  _.times(TIMES, () => require('./arrow/arrow.es5').run(assertEqual));
  _.times(TIMES, () => require('./arrow/arrow.es6').run(assertEqual));
  _.times(TIMES, () => require('./arrow-args/arrow-args.es5').run(assertEqual));
  _.times(TIMES, () => require('./arrow-args/arrow-args.es6').run(assertEqual));
  _.times(TIMES, () => require('./arrow-declare/arrow-declare.es5').run(assertEqual));
  _.times(TIMES, () => require('./arrow-declare/arrow-declare.es6').run(assertEqual));
  _.times(TIMES, () => require('./bindings/bindings.es5').run(assertEqual));
  _.times(TIMES, () => require('./bindings/bindings.es6').run(assertEqual));
  _.times(TIMES, () => require('./bindings-compound/bindings-compound.es5').run(assertEqual));
  _.times(TIMES, () => require('./bindings-compound/bindings-compound.es6').run(assertEqual));
  _.times(TIMES, () => require('./classes/classes.es5').run(assertEqual));
  _.times(TIMES, () => require('./classes/classes.es6').run(assertEqual));
  _.times(TIMES, () => require('./defaults/defaults.es5').run(assertEqual));
  _.times(TIMES, () => require('./defaults/defaults.es6').run(assertEqual));
  _.times(TIMES, () => require('./destructuring/destructuring.es5').run(assertEqual));
  _.times(TIMES, () => require('./destructuring/destructuring.es6').run(assertEqual));
  _.times(TIMES, () => require('./destructuring-simple/destructuring-simple.es5').run(assertEqual));
  _.times(TIMES, () => require('./destructuring-simple/destructuring-simple.es6').run(assertEqual));
  _.times(TIMES, () => require('./for-of-array/for-of-array.es5').run(assertEqual));
  _.times(TIMES, () => require('./for-of-array/for-of-array.es6').run(assertEqual));
  _.times(TIMES, () => require('./for-of-object/for-of-object.es5').run(assertEqual));
  _.times(TIMES, () => require('./for-of-object/for-of-object.es6').run(assertEqual));
  _.times(TIMES, () => require('./generator/generator.es5').run(assertEqual));
  _.times(TIMES, () => require('./generator/generator.es6').run(assertEqual));
  _.times(TIMES, () => require('./map-set/map-set.es5').run(assertEqual));
  _.times(TIMES, () => require('./map-set/map-set.es6').run(assertEqual));
  _.times(TIMES, () => require('./map-set-lookup/map-set-lookup.es5').run(assertEqual));
  _.times(TIMES, () => require('./map-set-lookup/map-set-lookup.es6').run(assertEqual));
  _.times(TIMES, () => require('./map-set-object/map-set-object.es5').run(assertEqual));
  _.times(TIMES, () => require('./map-set-object/map-set-object.es6').run(assertEqual));
  _.times(TIMES, () => require('./map-string/map-string.es5').run(assertEqual));
  _.times(TIMES, () => require('./map-string/map-string.es6').run(assertEqual));
  _.times(TIMES, () => require('./object-assign/object-assign.es5').run(assertEqual));
  _.times(TIMES, () => require('./object-assign/object-assign.es6').run(assertEqual));
  _.times(TIMES, () => require('./object-literal-ext/object-literal-ext.es5').run(assertEqual));
  _.times(TIMES, () => require('./object-literal-ext/object-literal-ext.es6').run(assertEqual));
  _.times(TIMES, () => require('./rest/rest.es5').run(assertEqual));
  _.times(TIMES, () => require('./rest/rest.es6').run(assertEqual));
  _.times(TIMES, () => require('./spread/spread.es5').run(assertEqual));
  _.times(TIMES, () => require('./spread/spread.es6').run(assertEqual));
  _.times(TIMES, () => require('./spread-generator/spread-generator.es5').run(assertEqual));
  _.times(TIMES, () => require('./spread-generator/spread-generator.es6').run(assertEqual));
  _.times(TIMES, () => require('./spread-literal/spread-literal.es5').run(assertEqual));
  _.times(TIMES, () => require('./spread-literal/spread-literal.es6').run(assertEqual));
  _.times(TIMES, () => require('./super/super.es5').run(assertEqual));
  _.times(TIMES, () => require('./super/super.es6').run(assertEqual));
  _.times(TIMES, () => require('./template_string/template_string.es5').run(assertEqual));
  _.times(TIMES, () => require('./template_string/template_string.es6').run(assertEqual));
  _.times(TIMES, () => require('./template_string_tag/template_string_tag.es5').run(assertEqual));
  _.times(TIMES, () => require('./template_string_tag/template_string_tag.es6').run(assertEqual));
}

module.exports = {
  run
};
