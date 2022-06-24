const path = require('path')

module.exports = {
  stories: [
    '../stories/**/*.stories.mdx',
    '../stories/**/*.stories.@(js|jsx|ts|tsx)',
  ],
  addons: [
    '@storybook/addon-links',
    '@storybook/addon-essentials',
    '@storybook/addon-interactions',
    '@storybook/preset-scss',
  ],
  framework: '@storybook/react',
  core: {
    builder: '@storybook/builder-webpack5',
  },
  // // add a config.resolve.roots
  // // try this: https://github.com/storybookjs/storybook/issues/12844
  // webpackFinal: (config) => {
  //   // config.resolve.roots = [ path.resolve(__dirname, '../public'), 'node_modules', ];
  //   config.context = path.resolve(__dirname, '..');

  //   return config;
  // }
}
