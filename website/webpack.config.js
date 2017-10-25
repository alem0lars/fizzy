// ───────────────────────────────────────────────────────────────── Requires ──

const path = require("path");

const webpack = require("webpack");
const HtmlWebpackPlugin = require("html-webpack-plugin");
const ExtractTextPlugin = require("extract-text-webpack-plugin");
const UglifyJSPlugin = require("uglifyjs-webpack-plugin");
const CompressionPlugin = require("compression-webpack-plugin");
const CleanPlugin = require("clean-webpack-plugin");
const BrowserSyncPlugin = require("browser-sync-webpack-plugin");

// ──────────────────────────────────────────────────────────────── Constants ──

const isProduction = process.env.FIZZY_ENV === "production";

const scriptRelDir = path.join("asset", "script");
const styleRelDir = path.join("asset", "style");
const imageRelDir = path.join("asset", "image");
const fontRelDir = path.join("asset", "font");
const nodeModulesRelDir = "node_modules";

const srcDir = path.resolve(__dirname, "src");
const outputDir = path.resolve(__dirname, "build");

const nodeModulesDir = path.resolve(__dirname, nodeModulesRelDir);

// ──────────────────────────────────────────────────────────── Configuration ──

function appendIfProd(base, other) {
  if (isProduction) {
    return base + other;
  } else {
    return base;
  }
}

// ──────────────────────────────────────────────────────────── Configuration ──

const webpackConfig = {}

webpackConfig.entry = {
  main: [
    `./${scriptRelDir}/main.jsx`, // Entry-point of scripts.
    `./${styleRelDir}/main.scss`, // Entry-point of styles.
  ],
};

webpackConfig.context = srcDir;

webpackConfig.resolve = {
  modules: [
    path.join(srcDir, scriptRelDir),
    path.join(srcDir, styleRelDir),
    path.join(srcDir, imageRelDir),
    path.join(srcDir, fontRelDir),
    path.join(__dirname, nodeModulesRelDir),
  ],
};

webpackConfig.output = {
  // Location and name of the directory where the final build folder will be
  // placed.
  path: outputDir,
  // Name of the resulting file.
  filename: appendIfProd("asset/script/[name].bundle.js", "?[hash]"),
  // Prepend `/` to all paths so they are absolutized.
  publicPath: "/",
};

if (!isProduction) {
  // Define type of source-maps.
  webpackConfig.devtool = "source-map";
}

webpackConfig.module = {};
webpackConfig.module.loaders = [
  {
    test: /\.jsx?$/,
    exclude: new RegExp(nodeModulesRelDir),
    use: {
      loader: "babel-loader",
      options: {
        presets: ["env", "react"],
      }
    },
  },
  {
    test: /\.scss|css$/,
    use: ExtractTextPlugin.extract({
      use: [
        { // Translate final CSS into CommonJS.
          loader: "css-loader",
          options: {
            sourceMap: true,
          },
        },
        { // Perform post processing on CSS.
          loader: "postcss-loader",
          options: {
            sourceMap: true,
            plugins: () => [].concat(
              require("autoprefixer")()
            ).concat(
              isProduction ? require("cssnano")() : []
            ),
          }
        },
        { // Resolve `url(..)` statements based on source files location.
          loader: "resolve-url-loader",
          options: {
            sourceMap: true,
          }
        },
        { // Compile Sass to CSS.
          loader: "sass-loader",
          options: {
            sourceMap: true,
            includePaths: [nodeModulesDir],
          },
        }],
    }),
  },
  {
    test: /\.(ttf|eot|svg|woff(2)?)(\?v=[0-9]\.[0-9]\.[0-9])?$/,
    use: {
      loader: "url-loader",
      options: {
        limit: 10 * 1024,
        name: appendIfProd("[path][name].[ext]", "?[hash]"),
      },
    },
  },
  {
    test: /\.jpeg|png|gif$/,
    use: {
      loader: "url-loader",
      options: {
        limit: 10 * 1024,
        name: appendIfProd("[path][name].[ext]", "?[hash]"),
      },
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
    template: "./index.html",
  }),
  // Extract styles to separate file.
  new ExtractTextPlugin({
    filename: appendIfProd(`${styleRelDir}/[name].bundle.css`, "?[contenthash]"),
  }),
  // Uglify javascript.
  new UglifyJSPlugin(),
  // Compress files.
  new CompressionPlugin(),
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
