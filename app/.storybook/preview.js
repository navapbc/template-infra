// Apply global styling to our stories
import '../styles/styles.scss'

export const parameters = {
  actions: { argTypesRegex: '^on[A-Z].*' },
  controls: {
    matchers: {
      color: /(background|color)$/i,
      date: /Date$/
    }
  },
  locale: "en",
  locales: {
    en: "English",
    es: "Español",
    fr: "Français",
    ja: "日本語",
  },
};
