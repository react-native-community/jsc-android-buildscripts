import React, { Component } from 'react';
import {
  AppRegistry,
  StyleSheet,
  Text,
  View,
  Button
} from 'react-native';
const _ = require('lodash');

module.exports = class JsPerf extends Component {
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
        <Text style={styles.welcome}>JsPerf!</Text>

        <View style={styles.instructions} />

        <Text style={styles.welcome}>benchmarks results: {this.state.txt}</Text>
      </View>
    );
  }

  async start() {
    await this.benchmark('sunspider', () => require('./js/sunspider').run());
    await this.benchmark('jetstream', () => require('./js/jetstream').run());
    await this.benchmark('octane2', () => require('./js/octane2').run());
    await this.benchmark('sixspeed', () => require('./js/sixspeed').run());
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
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 30,
  },
});
