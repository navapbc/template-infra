// test/pages/index.test.js
import { axe } from 'jest-axe'
import { screen } from '@testing-library/react'
import Index from '../../src/pages/index'
import renderWithIntl from "../renderWithIntl"

describe('Index', () => {
  it('should render welcome text', () => {
    renderWithIntl(<Index />)

    const welcome = screen.getByText(/Welcome to your/i)

    expect(welcome).toBeInTheDocument()
    expect(welcome).toMatchSnapshot()
  })

  it('should pass accessibility scan', async () => {
    const { container } = renderWithIntl(<Index />)
    const results = await axe(container)

    expect(results).toHaveNoViolations()
  })
})
