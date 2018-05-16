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
  constructor(props) {
    this.startTime = Date.now();
    this.onLayout = this.onLayout.bind(this);
  }

  render() {
    return (
      <View style={styles.container} onLayout={this.onLayout}>
        <Text style={styles.welcome}>RenderPerf {this.props.deep ? 'deep' : 'flat'} test</Text>
        {this.props.deep ? this.renderDeep(SCALE) : this.renderLots(SCALE)}
      </View>
    );
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

  onLayout(params) {
    if (params.nativeEvent.layout.width) {
      alert(`onLayout: ${Date.now() - this.startTime}`);
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
