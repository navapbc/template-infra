/** @type {import('next').NextConfig} */

const nextConfig = {
  i18n: {
    // NOTE: NextJS will automatically detect with local the user preders based on the 'Accept-Language' header and the current domain. User will be redirected to detected locale's subpath -- i.e. 'example.com/es'
    locales: ['en', 'es'],
    defaultLocale: 'en',
  },
  reactStrictMode: true,
  sassOptions: {
    includePaths: [
      "./node_modules/@uswds",
      "./node_modules/@uswds/uswds/packages",
    ]
  },
}

module.exports = nextConfig
