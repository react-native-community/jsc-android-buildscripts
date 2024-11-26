const assert = require('assert');
const {
  withAppBuildGradle,
  withProjectBuildGradle,
} = require('expo/config-plugins');

const withJscAndroidAppBuildGradle = (config) => {
  return withAppBuildGradle(config, (config) => {
    assert(config.modResults.language === 'groovy');
    if (
      !config.modResults.contents.match(
        /@generated withJscAndroidAppBuildGradle/
      )
    ) {
      const code = `
// [begin] @generated withJscAndroidAppBuildGradle
afterEvaluate {
  project.rootProject.allprojects {
    // Remove original mavenCentral added by RNGP
    repositories.removeIf { repo ->
      repo instanceof MavenArtifactRepository && repo.url.toString().contains('https://repo.maven.apache.org/maven2')
    }

    repositories {
      maven {
        // Local dist maven repo
        url("\${rootDir}/../../dist")
      }

      mavenCentral {
        content {
          excludeGroup('org.webkit')
          excludeGroup('io.github.react-native-community')
        }
      }
    }
  }

  configurations.all {
    resolutionStrategy.dependencySubstitution {
      substitute(module('org.webkit:android-jsc'))
        .using(module('io.github.react-native-community:jsc-android:+'))
    }
  }
}
// [end] @generated withJscAndroidAppBuildGradle
`;
      config.modResults.contents += code;
    }
    return config;
  });
};

const withJscAndroidProjectBuildGradle = (config) => {
  return withProjectBuildGradle(config, (config) => {
    assert(config.modResults.language === 'groovy');
    const code = `
        mavenCentral {
            content {
                excludeGroup('org.webkit')
                excludeGroup('io.github.react-native-community')
            }
        }
`;
    config.modResults.contents = config.modResults.contents.replace(
      /^(\s+)(mavenCentral\(\))(\s*)$/gm,
      code
    );
    return config;
  });
};

const withJscAndroid = (config) => {
  config = withJscAndroidAppBuildGradle(config);
  config = withJscAndroidProjectBuildGradle(config);
  return config;
};

module.exports = withJscAndroid;
