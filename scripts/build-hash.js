#!/usr/bin/env node

const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

const rootDir = process.cwd();

const includePaths = [
  'package.json',
  'yarn.lock',
  'patches',
  'scripts',
  'tools',
  'lib',
];

const excludePatterns = [/^scripts\/publish\.js$/];

const hash = crypto.createHash('sha256');

function shouldInclude(relPath) {
  if (relPath.includes('node_modules')) {
    return false;
  }
  if (relPath.startsWith('.git')) {
    return false;
  }
  return true;
}

function shouldExclude(relPath) {
  return excludePatterns.some((pattern) => pattern.test(relPath));
}

function addFile(filePath, relPath) {
  const content = fs.readFileSync(filePath);
  hash.update(relPath);
  hash.update('\0');
  hash.update(content);
}

function walk(currentPath, basePath) {
  const entries = fs.readdirSync(currentPath).sort();
  entries.forEach((entry) => {
    const absPath = path.join(currentPath, entry);
    const relPath = path.relative(basePath, absPath).replace(/\\/g, '/');

    if (!shouldInclude(relPath) || shouldExclude(relPath)) {
      return;
    }

    const stat = fs.statSync(absPath);
    if (stat.isDirectory()) {
      walk(absPath, basePath);
    } else if (stat.isFile()) {
      addFile(absPath, relPath);
    }
  });
}

includePaths.forEach((relativePath) => {
  const relative = relativePath.replace(/\\/g, '/');
  const abs = path.join(rootDir, relative);
  if (!fs.existsSync(abs)) {
    return;
  }
  const stat = fs.statSync(abs);
  if (stat.isDirectory()) {
    walk(abs, rootDir);
  } else if (stat.isFile()) {
    addFile(abs, path.relative(rootDir, abs).replace(/\\/g, '/'));
  }
});

process.stdout.write(hash.digest('hex'));
