// ───────────────────────────────────────────────────────────────── Requires ──

const path = require("path");

const webpack = require("webpack");
const CleanPlugin = require("clean-webpack-plugin");
const ExtractTextPlugin = require("extract-text-webpack-plugin");
const UglifyJSPlugin = require("uglifyjs-webpack-plugin");

// ──────────────────────────────────────────────────────────────── Constants ──

const outputDir = path.resolve(__dirname, "tmp", "dist");

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
  path: outputDir,
  filename: "asset/script/[name].bundle.js",
  // TODO publicPath is needed?
};

if (!isProduction) {
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
      use: [{ // Translate final CSS into CommonJS.
        loader: "css-loader",
        options: {
        },
      }, { // Perform post processing on CSS.
        loader: "postcss-loader",
        options: {
          plugins: () => [].concat(
            require("autoprefixer")()
          ).concat(
            isProduction ? require('cssnano')() : []
          ),
        }
      }, { // Compile Sass to CSS.
        loader: "sass-loader",
        options: {
          includePaths: [
            path.resolve(__dirname, nodeModulesDir),
          ],
        },
      }],
    }),
  },
];

webpackConfig.plugins = [
  // Add build-specific global variables to script files.
  new webpack.DefinePlugin({
    FIZZY_ENV: process.env.FIZZY_ENV,
  }),
  // Extract styles to separate file.
  new ExtractTextPlugin({
    filename: "asset/style/[name].bundle.css",
  }),
  // Cleanup before building.
  new CleanPlugin([outputDir]),
  new UglifyJSPlugin(),
];

// ────────────────────────────────────────────────────────────────── Exports ──

module.exports = webpackConfig;
