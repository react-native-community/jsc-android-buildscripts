import React, { Component } from 'react';
import {
  AppRegistry,
  StyleSheet,
  Text,
  View,
  Button
} from 'react-native';
const _ = require('lodash');

module.exports = class JSProfile extends Component {
  constructor(props) {
    super(props);
    this.state = {
      txt: ''
    };
  }

  componentDidMount() {
    setTimeout(() => this.start(), 1000);
  }

  render() {
    return (
      <View style={styles.container}>
        <Text style={styles.text}>JavaScript Synthetic Tests</Text>
        <Text style={styles.text}>Benchmarks Results: {this.state.txt}</Text>
      </View>
    );
  }

  async start() {
    await this.benchmark('Sunspider', () => require('./js/sunspider').run());
    await this.benchmark('Jetstream HashMap', () => require('./js/jetstream').run());
    await this.benchmark('Octane2', () => require('./js/octane2').run());
    await this.benchmark('SixSpeed', () => require('./js/sixspeed').run());
  }

  async benchmark(name, fn) {
    const start = Date.now();
    return new Promise((r) => {
      setTimeout(() => {
        fn();
        setTimeout(() => {
          this.setState({ txt: `${this.state.txt}\n${name}: ${Date.now() - start}` });
          r();
        }, 0);
      }, 0);
    });
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  text: {
    fontSize: 20,
    textAlign: 'center',
    margin: 30,
  }
});
