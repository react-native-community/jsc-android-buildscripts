import React, { Component } from 'react';
import {
  AppRegistry,
  StyleSheet,
  Text,
  View,
  Button
} from 'react-native';
const _ = require('lodash');

const JsPerf = require('./perf/JsPerf');
const RenderPerf = require('./perf/RenderPerf');

const RENDER_JS = 1;
const RENDER_PERF = 2;
const RENDER_PERF_DEEP = 4;

class ReactNativePerf extends Component {
  constructor(props) {
    super(props);
    this.state = {
      render: undefined
    };
  }

  render() {
    return (
      <View style={styles.container}>
        <Text style={styles.title}>Select A Test:</Text>
        {this.renderPerf()}
      </View>
    );
  }

  renderPerf() {
    switch (this.state.render) {
      case RENDER_JS: return this.startJsPerf();
      case RENDER_PERF: return this.startRenderPerf();
      case RENDER_PERF_DEEP: return this.startRenderPerf(true);
      default: return this.renderBtns();
    }
  }

  renderBtns() {
    return (
      <View style={styles.container}>
        <Button title="JsPerf" onPress={() => this.setState({ render: RENDER_JS })} />
        <View style={{ margin: 10 }}>
          <Button title="RenderPerf" onPress={() => this.setState({ render: RENDER_PERF })} />
        </View>
        <Button title="RenderPerfDeep" onPress={() => this.setState({ render: RENDER_PERF_DEEP })} />
      </View>
    );
  }

  startJsPerf() {
    return (
      <JsPerf />
    );
  }

  startRenderPerf(deep = false) {
    return (
      <RenderPerf deep />
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
    justifyContent: 'center'
  },
  title: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10
  }
});

AppRegistry.registerComponent('ReactNativePerf', () => ReactNativePerf);

Navigation.startSingleScreenApp({
  screen: {
    screen: 'ReactNativePerf',
    title: 'JSCore Perf Measurements'
  }
});
