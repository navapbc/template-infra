// test/pages/index.test.js
import { screen, render } from '@testing-library/react'
import { axe } from 'jest-axe'

import Layout from '../../src/components/Layout'

describe('Layout', () => {
  it('should render placeholder header text', () => {
    render(<Layout><h1>"child"</h1></Layout>)

    const header = screen.getByText(/Template Header/i)

    expect(header).toBeInTheDocument()
    expect(header).toMatchSnapshot()
  })

  it('should pass accessibility scan', async () => {
    const { container } = render(<Layout><h1>"child"</h1></Layout>)
    const results = await axe(container)

    expect(results).toHaveNoViolations()
  })
})