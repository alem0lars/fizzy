// ───────────────────────────────────────────────────────────────── Requires ──

const path = require("path");

const webpack = require("webpack");
const HtmlWebpackPlugin = require("html-webpack-plugin");
const ExtractTextPlugin = require("extract-text-webpack-plugin");
const UglifyJSPlugin = require("uglifyjs-webpack-plugin");
const CleanPlugin = require("clean-webpack-plugin");
const BrowserSyncPlugin = require('browser-sync-webpack-plugin');

// ──────────────────────────────────────────────────────────────── Constants ──

const outputDir = path.resolve(__dirname, "build");

const scriptRelDir = path.join("src", "asset", "script");
const styleRelDir = path.join("src", "asset", "style");
const nodeModulesDir = "node_modules";

const isProduction = process.env.FIZZY_ENV === "production";

// ──────────────────────────────────────────────────────────── Configuration ──

const webpackConfig = {}

webpackConfig.entry = {
  main: [
    `./${scriptRelDir}/main.js`,  // Entry-point of scripts.
    `./${styleRelDir}/main.scss`, // Entry-point of styles.
  ],
};

webpackConfig.resolve = {
  modules: [
    path.resolve(__dirname, scriptRelDir),
    path.resolve(__dirname, styleRelDir),
    path.resolve(__dirname, nodeModulesDir),
  ],
};

webpackConfig.output = {
  // Location and name of the directory where the final build folder will be
  // placed.
  path: outputDir,
  // Name of the resulting file.
  filename: "asset/script/[name].bundle.js?[hash]",
  // TODO publicPath is needed?
};

if (!isProduction) {
  // Define type of source-maps.
  webpackConfig.devtool = "source-map";
}

webpackConfig.module = {};
webpackConfig.module.loaders = [
  {
    test: /\.js$/,
    exclude: new RegExp(nodeModulesDir),
    use: {
      loader: "babel-loader",
      options: {
        presets: ["env"],
      }
    },
  },
  {
    test: /\.scss$/,
    use: ExtractTextPlugin.extract({
      use: [
        { // Translate final CSS into CommonJS.
          loader: "css-loader",
          options: {
          },
        },
        { // Perform post processing on CSS.
          loader: "postcss-loader",
          options: {
            plugins: () => [].concat(
              require("autoprefixer")()
            ).concat(
              isProduction ? require("cssnano")() : []
            ),
          }
        },
        { // Compile Sass to CSS.
          loader: "sass-loader",
          options: {
            includePaths: [
              path.resolve(__dirname, nodeModulesDir),
            ],
          },
        }],
    }),
  },
  {
    test: /\.(ttf|eot|svg|woff(2)?)(\?v=[0-9]\.[0-9]\.[0-9])?$/,
    use: {
      loader: "url-loader",
    },
    options: {
      limit: 10000,
      name: "asset/font/[name].[ext]?[hash]",
    },
  },
  {
    test: /\.(jpeg|png|gif)$/,
    use: {
      loader: "url-loader",
    },
    options: {
      limit: 10000,
      name: "asset/image/[name].[ext]?[hash]",
    },
  },
];

webpackConfig.plugins = [
  // Add build-specific global variables to script files.
  new webpack.DefinePlugin({
    FIZZY_ENV: process.env.FIZZY_ENV,
  }),
  // Build HTML files.
  new HtmlWebpackPlugin({
    template: "./src/index.html",
  }),
  // Extract styles to separate file.
  new ExtractTextPlugin({
    filename: "asset/style/[name].bundle.css?[contenthash]",
  }),
  // Uglify javascript.
  new UglifyJSPlugin(),
  // Cleanup build directory before each build.
  new CleanPlugin([outputDir]),
  // Live reloading using browsersync.
  new BrowserSyncPlugin({
    server: {
      baseDir: [outputDir],
    },
    port: 3000,
    host: "localhost"
  }),
];

// ────────────────────────────────────────────────────────────────── Exports ──

module.exports = webpackConfig;
