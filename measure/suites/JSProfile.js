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
      sunspider: '...',
      jetstream: '...',
      octane2: '...',
      sixspeed: '...',
      done: false
    };
  }

  componentDidMount() {
    setTimeout(() => this.start(), 1000);
  }

  render() {
    return (
      <View style={styles.container}>
        <Text style={styles.text}>JavaScript Synthetic Tests</Text>
        <Text style={styles.text}>Benchmarks Results:</Text>
        <Text style={styles.text}>Sunspider: {this.state.sunspider}</Text>
        <Text style={styles.text}>Jetstream HashMap: {this.state.jetstream}</Text>
        <Text style={styles.text}>Octane2: {this.state.octane2}</Text>
        <Text style={styles.text}>SixSpeed: {this.state.sixspeed}</Text>
        <Text style={styles.text}>{this.state.done ? 'DONE' : ''}</Text>
      </View>
    );
  }

  async start() {
    await this.benchmark('sunspider', () => require('./js/sunspider').run());
    await this.benchmark('jetstream', () => require('./js/jetstream').run());
    await this.benchmark('octane2', () => require('./js/octane2').run());
    await this.benchmark('sixspeed', () => require('./js/sixspeed').run());
    this.setState({ done: true });
  }

  async benchmark(name, fn) {
    const start = Date.now();
    return new Promise((r) => {
      setTimeout(() => {
        fn();
        setTimeout(() => {
          const result = Date.now() - start;
          console.log(`JavaScriptCoreProfiler:${name}:${result}`);
          this.setState({
            [name]: result.toString()
          });
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
    margin: 16,
  }
});
