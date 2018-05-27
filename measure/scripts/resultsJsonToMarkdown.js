const _ = require('lodash');
const fs = require('fs');

const rootDir = process.cwd();

const fields = {
  name: "Version Name",
  npm: "Npm Version",
  date: "Build Date",
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
      table += ` ${test[key]} |`
    });
    table += '\n';

  });
  table += '\n';
  return table;
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
