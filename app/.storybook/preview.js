// Apply global styling to our stories
import '../styles/styles.scss'
import { NextIntlProvider } from 'next-intl'
import en from '../src/messages/en.json'

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
