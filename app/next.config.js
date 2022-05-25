/** @type {import('next').NextConfig} */

const nextConfig = {
  i18n: {
    // TODO: implement i18n internationalization-- look into nextJS subpath routing
    locales: ['en-US', 'es-ES'],
    defaultLocale: 'en-US',
  },
  reactStrictMode: true,
};

module.exports = nextConfig;
