const _ = require('lodash');
const exec = require('shell-utils').exec;

const TIMES = 10;

const PACKAGE_NAME = 'com.javascriptcore.profiler';
const ACTIVITY_NAME = 'MainActivity';
const LOGCAT_TAG = 'JavaScriptCoreProfiler';

const TESTS = {
  tti: /ApplicationLoadedAndRendered:(\d+)/,
  sunspider: /sunspider:(\d+)/,
  jetstream: /jetstream:(\d+)/,
  octane2: /octane2:(\d+)/,
  sixspeed: /sixspeed:(\d+)/,
  renderflat: /RenderFlatResult:(\d+)/,
  renderdeep: /RenderDeepResult:(\d+)/
};

run();

function run() {
  installProfiler();

  let resultsStr = '';

  _.times(TIMES, () => {
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
  parseAndPrintTestResults(resultLines);

  exec.execSync(`find ./android/app/build/intermediates/transforms/mergeJniLibs/release | xargs ls -lh`);
}

function parseAndPrintTestResults(resultLines) {
  console.log('\n\n\nTest Results:\n\n\n');
  _.forEach(TESTS, (test, name) => {
    const testValues = parseTestValues(resultLines, test);
    const testAverage = _.round(_.mean(testValues));
    console.log(`"${name}": "${testAverage}",`);
  });
  console.log('\n\n\n');
}

function readLogcatFilteredOutput() {
  return exec.execSyncRead(`adb logcat -d | grep "${LOGCAT_TAG}"`, true);
}

function parseTestValues(resultLines, regex) {
  return _.chain(resultLines)
    .map((line) => regex.exec(line))
    .filter(_.negate(_.isNil))
    .map((match) => Number(match[1]))
    .value();
}

function installProfiler() {
  const useI18n = _.includes(process.argv, 'i18n') ? '--project-prop i18n=true' : '';
  exec.execSync(`cd android && ./gradlew clean uninstallRelease installRelease ${useI18n}`);
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
