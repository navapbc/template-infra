const nextConfig = require('../next.config')

module.exports = {
  stories: [
    '../stories/**/*.stories.@(mdx|js|jsx|ts|tsx)',
  ],
  addons: [
    '@storybook/addon-links',
    '@storybook/addon-essentials',
    '@storybook/addon-interactions',
  ],
  framework: '@storybook/react',
  core: {
    // Use webpack5 instead of webpack4.
    // Use [lazy compilation](https://storybook.js.org/docs/react/builders/webpack#lazy-compilation) for faster sass compiling.
    builder: {
      name: 'webpack5',
      options: {
        lazyCompilation: true,
      },
    },
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

    return config
  },
}
