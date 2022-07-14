// Apply global styling to our stories
import '../styles/styles.scss'
// Import i18next config.
import i18n from './i18next.js'

export const parameters = {
  actions: { argTypesRegex: '^on[A-Z].*' },
  controls: {
    matchers: {
      color: /(background|color)$/i,
      date: /Date$/
    }
  },
  // Configure i18next and locale/dropdown options.
  i18n,
  locale: 'en',
  locales: {
    en: 'English',
    es: 'Español'
  }
}
