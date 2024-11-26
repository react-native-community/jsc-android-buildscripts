const assert = require('assert');
const { withProjectBuildGradle } = require('expo/config-plugins');

const withJscAndroidProjectBuildGradle = (config) => {
  return withProjectBuildGradle(config, (config) => {
    assert(config.modResults.language === 'groovy');
    if (!config.modResults.contents.match(/\/\/ Local dist maven repo/)) {
      const mavenRepo = `
        maven {
            // Local dist maven repo
            url('../../dist')
        }`;
      config.modResults.contents = config.modResults.contents.replace(
        /^(allprojects \{[\s\S]+?repositories \{)/gm,
        `$1${mavenRepo}`
      );
    }

    if (
      !config.modResults.contents.match(
        /io\.github\.react-native-community:jsc-android:/
      )
    ) {
      config.modResults.contents += `
allprojects {
  configurations.all {
    resolutionStrategy.dependencySubstitution {
      substitute(module('org.webkit:android-jsc'))
        .using(module('io.github.react-native-community:jsc-android:+'))
    }
  }
}
`;
    }

    return config;
  });
};

const withJscAndroid = (config) => {
  config = withJscAndroidProjectBuildGradle(config);
  return config;
};

module.exports = withJscAndroid;
