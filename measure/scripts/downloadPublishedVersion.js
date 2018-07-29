const _ = require('lodash');
const exec = require('shell-utils').exec;

let version = process.argv.splice(process.execArgv.length + 2)[0];
const scriptDir = __dirname;
const distDir = `${scriptDir}/../../dist`;

run();

function run() {
  if (!version) {
    version = require('../../package.json').version;
  }
  const url = exec.execSyncRead(`npm view jsc-android@${version} dist.tarball`);
  exec.execSync(`curl ${url} | tar -xf -`);
  exec.execSync(`rm -rf ${distDir}`);
  exec.execSync(`cd package && mv $(find . -type d -maxdepth 1 -mindepth 1) ${distDir}`);
  exec.execSync(`rm -rf ./package`);
}
