import React, { Component } from 'react';
import {
  AppRegistry,
  StyleSheet,
  Text,
  View
} from 'react-native';
const _ = require('lodash');

const SCALE = 1000;

module.exports = class RenderProfile extends Component {
  constructor(props) {
    super(props);
    this.startTime = Date.now();
    this.onLayout = this.onLayout.bind(this);
  }

  render() {
    return (
      <View style={styles.container} onLayout={this.onLayout}>
        <Text style={styles.title}>{this.props.deep ? 'Deep' : 'Flat'} Render Test</Text>
        {this.props.deep ? this.renderDeep(SCALE) : this.renderLots(SCALE)}
      </View>
    );
  }

  renderLots(count) {
    const views = [];
    _.times(count, (i) => {
      views.push((
        <Text style={styles.text} key={i}>DONE</Text>
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
        <Text style={styles.text}>DONE</Text>
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
      const result = Date.now() - this.startTime;
      alert(`DONE: ${result}`);
      console.log(`JavaScriptCoreProfiler:Render${this.props.deep ? 'Deep' : 'Flat'}Result:${result}`)
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
  title: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  text: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 1,
  },
});
