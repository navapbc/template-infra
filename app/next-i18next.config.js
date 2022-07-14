module.exports = {
  i18n: {
    defaultLocale: 'en',
    locales: ['en', 'es'],
    react: {
      // Add support for <em>.
      // See https://react.i18next.com/latest/trans-component#using-for-less-than-br-greater-than-and-other-simple-html-elements-in-translations-v-10-4-0
      transKeepBasicHtmlNodesFor: ['br', 'strong', 'i', 'p', 'em'],
    },
  },
}
