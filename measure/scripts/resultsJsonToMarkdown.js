const _ = require('lodash');
const fs = require('fs');

const rootDir = process.cwd();

const fields = {
  npm: "Npm Version",
  date: "Build Date",
  config: "Config",
  revision: "WebkitGTK Revision",
  revisionDate: "WebkitGTK Date",
  tti: "TTI",
  sunspider: "SunSpider",
  jetstream: "Jetstream Hashmap",
  octane2: "Octane2",
  sixspeed: "SixSpeed",
  renderflat: "Render Flat",
  renderdeep: "Render Deep",
  size: "Size"
};

function run() {
  const results = JSON.parse(fs.readFileSync(`${rootDir}/results.json`).toString());

  const table = populateWithAllData(
    createHeaderLine(createHeaderFields(''))
    , results);

  updateReadme(table, results);
}

function createHeaderFields(table) {
  table += '|';
  _.forEach(fields, (field) => {
    table += ` ${field} |`;
  });
  table += '\n';
  return table;
}

function createHeaderLine(table) {
  table += '|';
  _.forEach(fields, (field) => {
    table += ` :---: |`;
  });
  table += '\n';
  return table;
}

function populateWithAllData(table, results) {
  _.forEach(results, (test) => {

    table += '|';
    _.forEach(fields, (field, key) => {
      const raw = test[key];
      const value = _.isPlainObject(raw) ? explodeJson(raw) : raw;
      table += ` ${value} |`
    });
    table += '\n';

  });
  table += '\n';
  return table;
}

function explodeJson(json) {
  return _.reduce(json, (result, val, key) => result += `${key}:${val}<br/>`, '');
}

function updateReadme(table, results) {
  const readmeStr = fs.readFileSync(`${rootDir}/README.md`).toString();

  const indexOfResults = readmeStr.indexOf(`### Results`);
  let readme = readmeStr.substring(0, indexOfResults);
  readme += '### Results\n\n';
  readme += table;
  readme += '\n';

  fs.writeFileSync(`${rootDir}/README.md`, readme);
  console.log(readme);
}

run();
