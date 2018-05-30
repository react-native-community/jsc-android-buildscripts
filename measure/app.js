import React, { Component } from 'react';
import {
  AppRegistry,
  StyleSheet,
  Text,
  View,
  Button,
  ToastAndroid
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

  componentDidMount() {
    const opts = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' };
    const date = new Date();
    const he = date.toLocaleDateString('he', opts);
    const ja = date.toLocaleDateString('ja', opts);
    const de = date.toLocaleDateString('de', opts);
    const ar = date.toLocaleDateString('ar', opts);
    setTimeout(() => ToastAndroid.show(`Different Locales:\n${he}\n${ja}\n${de}\n${ar}`, ToastAndroid.LONG), 1000);
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
