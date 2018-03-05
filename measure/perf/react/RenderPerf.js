import React, { Component } from 'react';
import {
  AppRegistry,
  StyleSheet,
  Text,
  View
} from 'react-native';
const _ = require('lodash');

const SCALE = 1000;

class RenderPerf extends Component {
  render() {
    let start = Date.now();

    const r = (
      <View style={styles.container} onLayout={(params) => this.onLayout(start, params)}>
        <Text style={styles.welcome}>RenderPerf {this.props.deep ? 'deep' : 'flat'} test</Text>
        {this.props.deep ? this.renderDeep(SCALE) : this.renderLots(SCALE)}
      </View>
    );

    alert(`render: ${Date.now() - start}`);

    return r;
  }

  renderLots(count) {
    const views = [];
    _.times(count, (i) => {
      views.push((
        <Text style={styles.instructions} key={i}>Helloooooo</Text>
      ));
    });

    return (
      <View style={styles.container}>
        {views}
      </View>
    );
  }

  renderDeep(i) {
    if (i == 0) {
      return (
        <Text style={styles.instructions}>Helloooooo</Text>
      );
    } else {
      return (
        <View style={styles.container}>
          {this.renderDeep(i - 1)}
        </View>
      );
    }
  }

  onLayout(startTime, params) {
    if (params.nativeEvent.layout.width) {
      alert(`onLayout: ${Date.now() - startTime}`);
    }
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
    marginBottom: 1,
  },
});

module.exports = RenderPerf;
