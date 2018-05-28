# React Native Android JS Performance Measurements

A simple react native app with some measurements of the performance of the android jsc.

## How to run

1. Compile the jsc locally (from root project, so that the compiled result will be at `/dist`)
1. Connect a physical device
1. `npm i` from within `/measure`
2. `npm run start`. This will compile a release version of the profiler app with the jsc from `/dist` and start measurements automatically.
- You can run the tests manually: inside the app select one of the tests for it to execute. To run a different test close the app and remove it from recent apps to release all memory.

## Measurements

- All measurements run on (a very clean) Pixel XL, release mode
- Render is measured with 1000 elements, flat or deep. The timing is taken after a full roundtrip (after `onLayout`)
- Synthetic tests were modified to be able to run on RN environment, based on the following:
  - [`jetstream`](http://browserbench.org/JetStream/)
  - [`octane2`](https://chromium.github.io/octane/)
  - [`sixspeed`](https://github.com/kpdecker/six-speed)
  - [`sunspider`](https://webkit.org/perf/sunspider/sunspider.html)
- All timings in milliseconds
- Size in MB

### Results

| Npm Version | Build Date | Config | WebkitGTK Revision | WebkitGTK Date | TTI | SunSpider | Jetstream Hashmap | Octane2 | SixSpeed | Render Flat | Render Deep | Size |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| - | - | Stock RN44 | 174650 | 2014-10-13 | TODO | 550 | 4150 | 2500 | 1400 | 900 | 1400 | TODO |
| 216113.0.3 | 2017-11-17 | 2.17.2-7.1.2_r11-x32-en-swmansion | 216113 | 2017-05-03 | TODO | 480 | 3300 | 1950 | 440 | 850 | 1250 | TODO |
| 216113.0.3 | 2017-11-17 | 2.17.2-7.1.2_r11-x32-i18n-swmansion | 216113 | 2017-05-03 | TODO | TODO | TODO | TODO | TODO | TODO | TODO | TODO |
| - | - | 2.18.2-8.0.0_r34-x32-en-nobabel | 216113 | 2017-10-27 | TODO | 480 | 3300 | 1850 | 410 | 900 | 1350 | TODO |
| - | - | 2.18.2-8.0.0_r34-x32-en-nojit | 216113 | 2017-10-27 | TODO | 1045 | 9164 | 3856 | 574 | 900 | 1165 | TODO |
| - | - | 2.18.2-8.0.0_r34-x32-en-tip | 216113 | 2017-10-27 | TODO | 480 | 3250 | 1800 | 400 | 850 | 1300 | TODO |
| - | - | webkitGTK:2.18.2<br/>androidICU:8.0.0_r34<br/>x64:false<br/>i18n:false<br/>hint:stable<br/> | 216113 | 2017-10-27 | TODO | TODO | TODO | TODO | TODO | TODO | TODO | TODO |
| - | - | 2.18.2-8.0.0_r34-x32-i18n-stable | 216113 | 2017-10-27 | TODO | TODO | TODO | TODO | TODO | TODO | TODO | TODO |


