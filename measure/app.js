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
      <View style={{
        flex: 1,
        alignSelf: 'center',
        alignItems: 'center',
        justifyContent: 'center',
        paddingVertical: 32,
        paddingHorizontal: 16
      }}>
        {this.renderButtonsOrMeasure()}
        <Text>
          {new Date().toLocaleDateString('he-IL', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}
        </Text>
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
      <View >
        <View style={{ margin: 16 }}>
          <Button title="Profile JavaScript" onPress={() => this.setState({ render: RENDER_JS })} />
        </View>
        <View style={{ margin: 16 }}>
          <Button title="Profile Render Flat" onPress={() => this.setState({ render: RENDER_PERF })} />
        </View>
        <View style={{ margin: 16 }}>
          <Button title="Profile Render Deep" onPress={() => this.setState({ render: RENDER_PERF_DEEP })} />
        </View>
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

AppRegistry.registerComponent('MainScreen', () => MainScreen);
