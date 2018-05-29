const _ = require('lodash');
const exec = require('shell-utils').exec;

const PACKAGE_NAME = 'com.javascriptcore.profiler';
const ACTIVITY_NAME = 'MainActivity';
const LOGCAT_TAG = 'JavaScriptCoreProfiler';

const tests = {
  TTI: /ApplicationLoadedAndRendered:(\d+)/,
  Sunspider: /sunspider:(\d+)/,
  Jetstream: /jetstream:(\d+)/,
  Octane2: /octane2:(\d+)/,
  SixSpeed: /sixspeed:(\d+)/,
  RenderFlat: /RenderFlatResult:(\d+)/,
  RenderDeep: /RenderDeepResult:(\d+)/
};

run();

function run() {
  installProfiler();

  let resultsStr = '';

  _.times(10, () => {
    clearLogcat();

    launchProfiler();
    clickOnJsTest();
    killProfiler();

    launchProfiler();
    clickOnFlatRenderTest();
    killProfiler();

    launchProfiler();
    clickOnDeepRenderTest();
    killProfiler();

    resultsStr += readLogcatFilteredOutput() + '\n';
  })

  const resultLines = _.split(resultsStr, '\n');
  printTestsAverages(resultLines);
}

function readLogcatFilteredOutput() {
  return exec.execSyncRead(`adb logcat -d | grep "${LOGCAT_TAG}"`, true);
}

function printTestsAverages(resultLines) {
  _.forEach(tests, (test, name) => {
    const testAverage = _.round(_.mean(parseTestValues(resultLines, test)));
    console.log(`${name}: ${testAverage}`);
  });
}

function parseTestValues(resultLines, regex) {
  return _.chain(resultLines)
    .map((line) => regex.exec(line))
    .filter(_.negate(_.isNil))
    .map((match) => Number(match[1]))
    .value();
}

function installProfiler() {
  exec.execSync(`cd android && ./gradlew clean uninstallRelease installRelease`);
}

function clearLogcat() {
  exec.execSyncSilent(`adb logcat -c`);
}

function waitForLogcatMsg(msg) {
  while (!_.includes(exec.execSyncRead(`adb logcat -d`, true), msg)) {
    exec.execSyncSilent(`sleep 1`);
  }
}

function launchProfiler() {
  exec.execSyncSilent(`adb shell am start-activity -W "${PACKAGE_NAME}/.${ACTIVITY_NAME}" && sleep 1`);
}

function killProfiler() {
  exec.execSyncSilent(`adb shell am force-stop ${PACKAGE_NAME}`);
  exec.execSyncSilent(`adb shell am kill ${PACKAGE_NAME}`);
}

function clickOnJsTest() {
  exec.execSyncSilent(`adb shell input tap 720 1008`); // TODO replace with non-magical values
  waitForLogcatMsg(`${LOGCAT_TAG}:JSProfile:Done`);
}

function clickOnFlatRenderTest() {
  exec.execSyncSilent(`adb shell input tap 720 1240`); // TODO replace with non-magical values
  waitForLogcatMsg(`${LOGCAT_TAG}:RenderFlatResult:`);
}

function clickOnDeepRenderTest() {
  exec.execSyncSilent(`adb shell input tap 720 1470`);// TODO replace with non-magical values
  waitForLogcatMsg(`${LOGCAT_TAG}:RenderDeepResult:`);
}
