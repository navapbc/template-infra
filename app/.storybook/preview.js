// Apply global styling to our stories
import { NextIntlProvider } from 'next-intl'

import en from '../messages/en.json'
import '../public/uswds/css/styles.css'

export const decorators = [
  (Story) => (
    <NextIntlProvider locale="en" messages={en}>
      <Story />
    </NextIntlProvider>
  ),
]

export const parameters = {
  actions: { argTypesRegex: '^on[A-Z].*' },
  controls: {
    matchers: {
      color: /(background|color)$/i,
      date: /Date$/,
    },
  },
}
