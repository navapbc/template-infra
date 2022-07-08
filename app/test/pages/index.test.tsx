// test/pages/index.test.js
import { axe } from 'jest-axe'
import { NextIntlProvider } from 'next-intl'
import { render, screen } from '@testing-library/react'
import en from '../../messages/en.json'
import Index from '@pages/index'

const renderWithIntl = (component: JSX.Element) => {
  return {
    ...render(
      <NextIntlProvider locale="en" messages={en}>
        {component}
      </NextIntlProvider>
    ),
  }
}

describe('Index', () => {
  it('should render welcome text', () => {
    renderWithIntl(<Index />)

    const welcome = screen.getByText(/Welcome!/i)

    expect(welcome).toBeInTheDocument()
    expect(welcome).toMatchSnapshot()
  })

  it('should pass accessibility scan', async () => {
    const { container } = renderWithIntl(<Index />)
    const results = await axe(container)

    expect(results).toHaveNoViolations()
  })
})
