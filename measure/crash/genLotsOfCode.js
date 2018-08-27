const fs = require('fs');
require('child_process').execSync(`rm -rf ${__dirname}/modules`);
fs.mkdirSync(`${__dirname}/modules`);

const MODULES = 5000;
const FUNCS = 10;

const indexLines = [];
indexLines.push(`const all = []`);
indexLines.push(`if (Math.random() < 0) {`);

for (let module = 0; module < MODULES; module++) {
  const lines = [];

  lines.push(`const fns = [];`);
  for (let i = 0; i < FUNCS; i++) {
    lines.push(`function fn${i}() { const str = '🤩 This is a string for fn${i}'; const num = ${i}; const obj = { foo: { bar: { baz: { arr: [str, num] } } } }; const obj2 = { ...obj }; if (!obj2.toString()) { throw new Error('huh${i}'); } else { return obj2; } }`);
    lines.push(`fns.push(fn${i})`);
  }
  lines.push(`module.exports = { fns }`);

  fs.writeFileSync(`${__dirname}/modules/module${module}.js`, lines.join('\n'));

  indexLines.push(`all.push(require('./modules/module${module}'));`);
}
indexLines.push(`}`);
indexLines.push(`module.exports = { all }`);
fs.writeFileSync(`${__dirname}/index.js`, indexLines.join('\n'));
