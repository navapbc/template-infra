// test/pages/index.test.js

import { render, screen } from '@testing-library/react'
import { axe } from 'jest-axe'
import Home from '@pages/index'

describe('Home', () => {
  it('should render the heading', () => {
    render(<Home />)

    const heading = screen.getByText(/Next.js Template!/i)

    expect(heading).toBeInTheDocument()
    expect(heading).toMatchSnapshot()
  })

  it('should pass accessibility scan', async () => {
    const { container } = render(<Home />)
    const results = await axe(container)

    expect(results).toHaveNoViolations()
  })
})
