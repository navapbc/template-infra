// test/pages/index.test.js
import { axe } from 'jest-axe'
import { screen } from '@testing-library/react'
import renderWithIntl from '../renderWithIntl'
import Layout from '../../src/components/Layout'

describe('Layout', () => {
  it('should render placeholder header text', () => {
    renderWithIntl(<Layout />)

    const header = screen.getByText(/Template Header/i)

    expect(header).toBeInTheDocument()
    expect(header).toMatchSnapshot()
  })

  it('should pass accessibility scan', async () => {
    const { container } = renderWithIntl(<Layout />)
    const results = await axe(container)

    expect(results).toHaveNoViolations()
  })
})
