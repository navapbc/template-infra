/** @type {import('next').NextConfig} */

const { i18n } = require('./next-i18next.config');

const nextConfig = {
  i18n,
  reactStrictMode: true,
  sassOptions: {
    includePaths: [
      './node_modules/@uswds',
      './node_modules/@uswds/uswds/packages',
    ],
  },
}

module.exports = nextConfig
