// test/pages/index.test.js
import { screen } from '@testing-library/react'
import { axe } from 'jest-axe'

import Layout from '../../src/components/Layout'
import renderWithIntl from '../renderWithIntl'

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
