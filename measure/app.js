import React, { Component } from 'react';
import {
  AppRegistry,
  StyleSheet,
  Text,
  View,
  Button
} from 'react-native';
const _ = require('lodash');

const JSProfile = require('./suites/JSProfile');
const RenderProfile = require('./suites/RenderProfile');

const RENDER_JS = 1;
const RENDER_PERF = 2;
const RENDER_PERF_DEEP = 4;

class MainScreen extends Component {
  constructor(props) {
    super(props);
    this.state = {
      render: undefined
    };
  }

  render() {
    return (
      <View style={styles.container}>
        {this.renderButtonsOrMeasure()}
      </View>
    );
  }

  renderButtonsOrMeasure() {
    switch (this.state.render) {
      case RENDER_JS: return this.startJsProfile();
      case RENDER_PERF: return this.startRenderProfile();
      case RENDER_PERF_DEEP: return this.startRenderProfile(true);
      default: return this.renderBtns();
    }
  }

  renderBtns() {
    return (
      <View style={styles.container}>
        <Button uppercase={false} title="Profile JavaScript" onPress={() => this.setState({ render: RENDER_JS })} />
        <Button uppercase={false} title="Profile Render Flat" onPress={() => this.setState({ render: RENDER_PERF })} />
        <Button uppercase={false} title="Profile Render Deep" onPress={() => this.setState({ render: RENDER_PERF_DEEP })} />
      </View>
    );
  }

  startJsProfile() {
    return (
      <JSProfile />
    );
  }

  startRenderProfile(deep = false) {
    return (
      <RenderProfile deep={deep} />
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignSelf: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
    justifyContent: 'space-between',
    paddingVertical: 50,
    paddingHorizontal: 10
  }
});

AppRegistry.registerComponent('MainScreen', () => MainScreen);
