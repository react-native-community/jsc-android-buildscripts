# React Native Android JS Performance Measurements

A simple react native app with some measurements of the performance of the android jsc.

## How to run

1. Compile the jsc locally (from root project, so that the compiled result will be at `/dist`)
1. Connect a physical device
1. `npm i` from within `/measure`
1. `npm run android`. This will unzip the compiled jsc into the android dir, and use it to compile a release version of this app
1. Inside the app select one of the tests for it to execute. To run a different test close the app and remove it from recent apps to release all memory.

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


| Version                         | Launch | Sunspider | Jetstream HashMap | Octane2 | SixSpeed | Render Flat | Render Deep | Size |
|---------------------------------|:------:|:---------:|:-----------------:|:-------:|:--------:|:-----------:|:-----------:|:----:|
| Stock RN44 (r174650, Oct2014)   |    ?   |    550    |        4150       |   2500  |   1400   |     900     |     1400    |   ?  |
| 2.17.2-r216113.0.2 (May2017)    |    ?   |    480    |        3300       |   1950  |    440   |     850     |     1250    |   ?  |
| 2.18.2-8.0.0_r34-x32-en-tip     |    ?   |    480    |        3250       |   1800  |    400   |     850     |     1300    |   ?  |
| 2.18.2-8.0.0_r34-x32-en-nobabel |    ?   |    480    |        3300       |   1850  |    410   |     900     |     1350    |   ?  |
| 2.18.2-8.0.0_r34-x32-en-nojit   |    ?   |    1045   |        9164       |   3856  |    574   |     900     |     1165    |   ?  |
| ?                               |        |           |                   |         |          |             |             |      |

