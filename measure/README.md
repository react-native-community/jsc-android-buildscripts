# React Native Android JS Performance Measurements

A simple react native app with some measurements of the performance of the android jsc.

It has 3 tests:
- A render test that measures the time it takes to render a 1000 children on screen, both the js-based render and a full roundtrip (after the native done layout+measure)
- A deep render test, same as above but it renders a 1000 children deeply (each child inside the previous)
- A JS execution speed test based on 4 suites:
  - [`jetstream`](http://browserbench.org/JetStream/)
  - [`octane2`](https://chromium.github.io/octane/)
  - [`sixspeed`](https://github.com/kpdecker/six-speed)
  - [`sunspider`](https://webkit.org/perf/sunspider/sunspider.html)

To run it:

1. Compile the jsc locally (from root project, so that the compiled result will be at `/result`)
1. Connect a physical device
1. `npm i` from within `/measure`
1. `npm run android`. This will unzip the compiled jsc into the android dir, and use it to compile a release version of this app
1. Inside the app select one of the tests for it to execute. To run a different test close the app and remove it from recent apps to release all memory.

## Measurements

- All measurements run on (a very clean) Pixel XL.
- Render is measured with 1000 elements, flat or deep.
- Synthetic tests copied and adapted from Webkit and V8 OSS
- All timings in milliseconds


| Version                         | Launch | Sunspider | Jetsream, HashMap | Octane2 | SixSpeed | Render Flat | Render Deep | Size |
|---------------------------------|:------:|:---------:|:-----------------:|:-------:|:--------:|:-----------:|:-----------:|:----:|
| Stock RN44                      |    ?   |    550    |        4150       |   2500  |   1400   |     900     |     1400    |   ?  |
| 2.17.2-r216113.0.2 (npm)        |    ?   |    480    |        3300       |   1950  |    440   |     850     |     1250    |   ?  |
| 2.18.2-8.0.0_r34-x32-en-tip     |    ?   |    480    |        3250       |   1800  |    400   |     850     |     1300    |   ?  |
| 2.18.2-8.0.0_r34-x32-en-nobabel |    ?   |    480    |        3300       |   1850  |    410   |     900     |     1350    |   ?  |
| 2.18.2-8.0.0_r34-x32-en-nojit   |    ?   |    1045   |        9164       |   3856  |    574   |     900     |     1165    |   ?  |
| ?                               |        |           |                   |         |          |             |             |      |

