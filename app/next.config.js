/**
 * @type {import('next').NextConfig}
 **/

const nextConfig = {
  i18n: {
    // TODO: setup env vars w/ Alsia
    locales: ['en'],
    defaultLocale: 'en',
  },
  reactStrictMode: true,
}

module.exports = nextConfig
