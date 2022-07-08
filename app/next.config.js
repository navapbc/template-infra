/** @type {import('next').NextConfig} */

const nextConfig = {
  i18n: {
    // NOTE: NextJS will automatically detect with local the user preders based on the 'Accept-Language' header and the current domain. User will be redirected to detected locale's subpath -- i.e. 'example.com/es'
    locales: ['en', 'es'],
    defaultLocale: 'en',
  },
  reactStrictMode: true,
}

module.exports = nextConfig
