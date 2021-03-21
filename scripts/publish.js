#!/usr/bin/env node
/*
 * @format
 */

const child_process = require('child_process');
const commander = require('commander');
const fs = require('fs');
const path = require('path');
const rimraf = require('rimraf');
const semver = require('semver');

if (!semver.satisfies(process.versions.node, '>= 10.12.0')) {
  console.log('Please execute this script with node version >= 10.12.0');
  process.exit(1);
}

commander
  .requiredOption('-T, --tag <tag>', 'NPM published tag')
  .arguments('<artifact_zip_file>')
  .option('--dry-run', 'Dry run mode for npm publish')
  .parse(process.argv);

const artifactZipFile = verifyFile(commander.args[0], '<artifact_zip_file>');
const rootDir = path.dirname(__dirname);
const workDir = path.join(rootDir, 'build', 'publish');
const distDir = path.join(rootDir, 'dist');
if (fs.existsSync(workDir)) {
  rimraf.sync(workDir);
}
fs.mkdirSync(workDir, {recursive: true});

child_process.execFileSync('unzip', [artifactZipFile, '-d', workDir]);

// Publish standard package
console.log('\n\n========== Publish standard package ==========');
createPatchedContext(rootDir, '', () => {
  if (fs.existsSync(distDir)) {
    rimraf.sync(distDir);
  }
  fs.renameSync(path.join(workDir, 'dist'), distDir);
  const publishArgs = ['publish', '--tag', commander.tag];
  if (commander.dryRun) {
    publishArgs.push('--dry-run');
  }
  child_process.execFileSync('npm', publishArgs);
});

// Publish unstripped package
// 1. Add suffix in version, e.g. 245459.0.0-unstripped
// 2. Add suffix in tag, e.g. latest-unstripped
// 3. Get unstripped distribution from dist.unstripped/ in CI archive.zip
console.log('\n\n========== Publish unstripped package ==========');
createPatchedContext(rootDir, 'unstripped', () => {
  if (fs.existsSync(distDir)) {
    rimraf.sync(distDir);
  }
  fs.renameSync(path.join(workDir, 'dist.unstripped'), distDir);
  const publishArgs = ['publish', '--tag', `${commander.tag}-unstripped`];
  if (commander.dryRun) {
    publishArgs.push('--dry-run');
  }
  child_process.execFileSync('npm', publishArgs);
});

// ---------------------------------------------------------------------------
// Helper functions
// ---------------------------------------------------------------------------
function verifyFile(filePath, argName) {
  if (filePath == null) {
    console.error(`Error: ${argName} is required`);
    process.exit(1);
  }

  let stat;
  try {
    stat = fs.lstatSync(filePath);
  } catch (error) {
    console.error(error.toString());
    process.exit(1);
  }

  if (!stat.isFile()) {
    console.error(`Error: ${argName} is not a regular file`);
    process.exit(1);
  }

  return filePath;
}

function createPatchedContext(rootDir, versionSuffix, wrappedRunner) {
  const configPath = path.join(rootDir, 'package.json');
  const origConfig = fs.readFileSync(configPath);

  function enter() {
    const patchedConfig = JSON.parse(origConfig);
    if (versionSuffix) {
      patchedConfig.version += '-' + versionSuffix;
    }
    fs.writeFileSync(configPath, JSON.stringify(patchedConfig, null, 2));
  }

  function exit() {
    fs.writeFileSync(configPath, origConfig);
  }

  enter();
  const ret = wrappedRunner.apply(this, arguments);
  exit();
  return ret;
}
