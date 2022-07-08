import { ReactElement } from 'react'

type Props = {
  children: ReactElement
}

const Layout = ({ children }: Props) => {
  return (
    <>
      <header>
        <em className='usa-logo__text'>Template header</em>
      </header>
        <body>{children}</body>
      <footer className="usa-footer usa-footer--slim">
        <em>Template footer</em>
      </footer>
    </>
  )
}