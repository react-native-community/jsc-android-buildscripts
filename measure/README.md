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

| Npm Version | Publish Date | Config | WebkitGTK Revision | WebkitGTK Date | TTI | SunSpider | Jetstream Hashmap | Octane2 | SixSpeed | Render Flat | Render Deep | Size |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| - | - | Stock RN44 (x32 only, non-i18n) | 174650 | 2014-10-13 | 579 | 519 | 4087 | 2545 | 1386 | 844 | 1162 | 1.8/- |
| 216113.0.3 | 2017-11-17 | webkitGTK:2.17.1<br/>androidICU:7.1.2_r11<br/>i18n:false<br/> | 216113 | 2017-05-03 | 576 | 455 | 3265 | 1980 | 436 | 854 | 1155 | 4.3/6.5 |
| 216113.0.3 | 2017-11-17 | webkitGTK:2.17.1<br/>androidICU:7.1.2_r11<br/>i18n:true<br/> | 216113 | 2017-05-03 | 577 | 456 | 3244 | 2006 | 441 | 862 | 1112 | 4.4/6.6 |
| - | - | 2.18.2-8.0.0_r34-x32-en-nobabel | 216113 | 2017-10-27 | TODO | 480 | 3300 | 1850 | 410 | 900 | 1350 | TODO |
| - | - | 2.18.2-8.0.0_r34-x32-en-nojit | 216113 | 2017-10-27 | TODO | 1045 | 9164 | 3856 | 574 | 900 | 1165 | TODO |
| - | - | 2.18.2-8.0.0_r34-x32-en-tip | 216113 | 2017-10-27 | TODO | 480 | 3250 | 1800 | 400 | 850 | 1300 | TODO |
| - | - | webkitGTK:2.18.2<br/>androidICU:8.0.0_r34<br/>i18n:false<br/> | 216113 | 2017-10-27 | TODO | TODO | TODO | TODO | TODO | TODO | TODO | TODO |
| - | - | 2.18.2-8.0.0_r34-x32-i18n-stable | 216113 | 2017-10-27 | TODO | TODO | TODO | TODO | TODO | TODO | TODO | TODO |


