import i18n from 'i18next'
import { initReactI18next } from 'react-i18next'

import enCommon from '../public/locales/en/common.json'
import esCommon from '../public/locales/es/common.json'

// Setup react-i18next for tests. Load actual content along with some mocked content.
i18n.use(initReactI18next).init({
  fallbackLng: 'en',
  ns: ['common'],
  defaultNS: 'common',
  resources: {
    en: {
      common: enCommon
    },
    es: { common: esCommon }
  }
})

// Export i18n so tests can manually set the lanuage with:
// i18n.changeLanguage('es')
export default i18n
