const fs = require('fs');
const REGEX = /^VERSION_NAME=(.+)$/m;

function replaceInGradleProperties(path, version) {
  const gradleProps = fs.readFileSync(path).toString();
  const newGradleProps = gradleProps.replace(REGEX, `VERSION_NAME=${version}`);
  fs.writeFileSync(path, newGradleProps);
  console.log(`written version ${version} to ${path}`);
}

module.exports = () => {
  const version = require('./getVersion')();
  replaceInGradleProperties('./lib/lib/gradle.properties', version);
  replaceInGradleProperties('./lib/libIntl/gradle.properties', version);
}
