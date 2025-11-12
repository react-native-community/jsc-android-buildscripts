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

if (!semver.satisfies(process.versions.node, '>= 16.7.0')) {
  console.log('Please execute this script with node version >= 16.7.0');
  process.exit(1);
}

commander
  .requiredOption('-T, --tag <tag>', 'NPM published tag')
  .arguments('<artifact_zip_file>')
  .option('--dry-run', 'Dry run mode for npm publish')
  .parse(process.argv);

const artifactInput = resolveArtifactPath(commander.args[0], '<artifact_path>');
const rootDir = path.dirname(__dirname);
const pkgJsonPath = path.join(rootDir, 'package.json');
const packageTemplate = JSON.parse(fs.readFileSync(pkgJsonPath, 'utf8'));
const workDir = path.join(rootDir, 'build', 'publish');
const distDir = path.join(rootDir, 'dist');

if (fs.existsSync(workDir)) {
  rimraf.sync(workDir);
}
fs.mkdirSync(workDir, {recursive: true});

if (artifactInput.isDirectory) {
  fs.cpSync(artifactInput.path, workDir, {recursive: true});
} else {
  child_process.execFileSync('unzip', [artifactInput.path, '-d', workDir]);
}

const variantList = Array.isArray(packageTemplate.config?.ndkVariants)
  ? packageTemplate.config.ndkVariants
  : [];

const variants =
  variantList.length > 0
    ? [...variantList].sort((a, b) => {
        const aDefault = a && a.default ? 1 : 0;
        const bDefault = b && b.default ? 1 : 0;
        return bDefault - aDefault;
      })
    : [
        {
          id: 'default',
          npmPackage: packageTemplate.name,
          distDir: 'dist',
          distUnstrippedDir: 'dist.unstripped',
        },
      ];

variants.forEach((variant) => {
  publishVariant(variant);
});

// ---------------------------------------------------------------------------
// Helper functions
// ---------------------------------------------------------------------------
function publishVariant(variant) {
  const displayName = variant?.id || 'default';
  console.log(`\n\n========== Publish ${displayName} package ==========`); // eslint-disable-line no-console

  publishVariantFlavor(variant, {
    sourceDirName: variant.distDir || 'dist',
    versionSuffix: '',
    tagSuffix: '',
  });

  publishVariantFlavor(variant, {
    sourceDirName: variant.distUnstrippedDir || 'dist.unstripped',
    versionSuffix: 'unstripped',
    tagSuffix: '-unstripped',
  });
}

function publishVariantFlavor(variant, {sourceDirName, versionSuffix, tagSuffix}) {
  if (!sourceDirName) {
    return;
  }

  const sourceDir = path.join(workDir, sourceDirName);
  if (!fs.existsSync(sourceDir)) {
    console.warn(
      `Skipping ${variant?.id || 'default'}${tagSuffix ? ` (${tagSuffix.replace('-', '')})` : ''} - missing directory ${sourceDirName}`,
    );
    return;
  }

  createPatchedContext(rootDir, {variant, versionSuffix}, () => {
    if (fs.existsSync(distDir)) {
      rimraf.sync(distDir);
    }
    copyDir(sourceDir, distDir);
    const publishTag = tagSuffix ? `${commander.tag}${tagSuffix}` : commander.tag;
    const publishArgs = ['publish', '--tag', publishTag];
    if (commander.dryRun) {
      publishArgs.push('--dry-run');
    }
    child_process.execFileSync('npm', publishArgs, {stdio: 'inherit'});
  });
}

function copyDir(source, destination) {
  fs.mkdirSync(path.dirname(destination), {recursive: true});
  fs.cpSync(source, destination, {recursive: true, force: true});
}

function resolveArtifactPath(inputPath, argName) {
  if (inputPath == null) {
    console.error(`Error: ${argName} is required`);
    process.exit(1);
  }

  const resolvedPath = path.resolve(process.cwd(), inputPath);
  let stat;
  try {
    stat = fs.lstatSync(resolvedPath);
  } catch (error) {
    console.error(error.toString());
    process.exit(1);
  }

  if (!stat.isDirectory() && !stat.isFile()) {
    console.error(`Error: ${argName} must be a directory or zip file`);
    process.exit(1);
  }

  return {path: resolvedPath, isDirectory: stat.isDirectory()};
}

function createPatchedContext(rootDir, options, wrappedRunner) {
  const {versionSuffix, variant} = options || {};
  const configPath = path.join(rootDir, 'package.json');
  const origConfig = fs.readFileSync(configPath);

  function enter() {
    const patchedConfig = JSON.parse(origConfig);
    if (variant) {
      if (variant.npmPackage) {
        patchedConfig.name = variant.npmPackage;
      }
      patchedConfig.config = patchedConfig.config || {};
      if (variant.id) {
        patchedConfig.config.selectedNdkVariant = variant.id;
      }
      if (variant.npmPackage) {
        patchedConfig.config.selectedNdkPackage = variant.npmPackage;
      }
      if (variant.distDir) {
        patchedConfig.config.selectedNdkDistDir = variant.distDir;
      }
    }
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
