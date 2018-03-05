# React Native Android JS Performance Measurements

A simple react native app with some measurements of the performance of the android jsc.

It has 3 tests:
- A render test that measures the time it takes to render a 1000 children on screen, both the js-based render and a full roundtrip (after the native done layout+measure)
- A deep render test, same as above but it renders a 1000 children deeply (each child inside the previous)
- A JS execution speed test based on 4 suites (`jetstream`, `octane2`, `sixspeed`, `sunspider`)

To run it:

1. Compile the jsc locally (from root project, so that the compiled result will be at `/result`)
1. Connect a physical device
2. `npm i` from within `/measure`
3. `npm run android`. This will unzip the compiled jsc into the android dir, and use it to compile a release version of this app
4. Inside the app select one of the tests for it to execute. To run a different test close the app and remove it from recent apps to release all memory.
