// Apply global styling to our stories
import '../styles/styles.scss'
import i18n from 'i18next'
import { I18nextProvider, initReactI18next } from 'react-i18next'
import { withI18next } from 'storybook-addon-i18next'

import enCommon from '../public/locales/en/common.json'

import esCommon from '../public/locales/es/common.json'

export const parameters = {
  actions: { argTypesRegex: '^on[A-Z].*' },
  controls: {
    matchers: {
      color: /(background|color)$/i,
      date: /Date$/,
    },
  },
}

export const decorators = [
  (Story, Context) => {
    i18n.use(initReactI18next).init({
      fallbackLng: 'en',
      ns: ['common'],
      defaultNS: 'common',
      debug: true,
      resources: {
        en: { common: enCommon },
        es: { common: esCommon },
      },
      react: {
        // Add support for <em>.
        // See https://react.i18next.com/latest/trans-component#using-for-less-than-br-greater-than-and-other-simple-html-elements-in-translations-v-10-4-0
        transKeepBasicHtmlNodesFor: ['br', 'strong', 'i', 'p', 'em'],
      },
    })

    return <Story />
  },
  // Enable language support in Storybook using storybook-addon-i18n.
  withI18next({ i18n, languages: { en: 'English', es: 'Español' } }),
]
