import { NextIntlProvider } from 'next-intl'
import { render } from '@testing-library/react'
import en from '../src/messages/en.json'

const renderWithIntl = (component: JSX.Element) => {
  return {
    ...render(
      <NextIntlProvider locale="en" messages={en}>
        {component}
      </NextIntlProvider>
    ),
  }
}

export default renderWithIntl
