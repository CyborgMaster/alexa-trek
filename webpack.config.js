// NOTE: paths are relative to each functions folder

var merge = require('webpack-merge');
var path = require('path');


var config = {
  entry: './src/index.coffee',
  target: 'node',
  output: {
    path: './lib',
    filename: 'index.js',
    libraryTarget: 'commonjs2'
  },
  resolve: {
    root: path.resolve('../../lib'),
    extensions: ["", ".js", '.coffee']
  },
  externals: {
    // aws-sdk does not (currently) build correctly with webpack. However,
    // Lambda includes it in its environment, so omit it from the bundle.
    // See: https://github.com/apex/apex/issues/217#issuecomment-194247472
    'aws-sdk': 'aws-sdk',

    // Redis isn't compilable by webpack, so we include it directly using
    // node-modules
    redis: 'redis'
  },
  module: {
    loaders: [
      { test: /\.coffee$/, loader: "coffee-loader" }
    ]
  }
};

var localConfig;
try {
  localConfig = require(process.cwd() + '/webpack.config.js');
} catch(err){
  if (err.code !== "MODULE_NOT_FOUND" && options && options.rethrow) {
    throw err;
  }
  localConfig = null;
}

if (localConfig !== null) {
  config = merge(config, localConfig);
}

module.exports = config;
