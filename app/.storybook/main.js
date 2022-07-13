const nextConfig = require('../next.config')

module.exports = {
  stories: ['../stories/**/*.stories.@(mdx|js|jsx|ts|tsx)'],
  addons: [
    '@storybook/addon-essentials',
    'storybook-addon-i18next',
  ],
  framework: '@storybook/react',
  core: {
    // Use webpack5 instead of webpack4.
    builder: 'webpack5',
    disableTelemetry: true,
  },
  // Tell storybook where to find USWDS static assets
  staticDirs: ['../public'],

  // Configure Storybook's final Webpack configuration in order to re-use the Next.js config/dependencies.
  webpackFinal: (config) => {
    config.module?.rules?.push({
      test: /\.scss$/,
      use: [
        'style-loader',
        'css-loader',

        {
          /**
           * Next.js sets this automatically for us, but we need to manually set it here for Storybook.
           * The main thing this enables is autoprefixer, so any experimental CSS properties work.
           */
          loader: 'postcss-loader',
          options: {
            postcssOptions: {
              plugins: ['postcss-preset-env'],
            },
          },
        },

        {
          loader: 'sass-loader',
          options: {
            sassOptions: nextConfig.sassOptions,
          },
        },
      ],
      exclude: /node_modules/,
    })
    config.resolve.fallback = {
      fs: false,
      path: false,
      os: false,
    }

    return config
  },
}
