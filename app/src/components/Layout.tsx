import { useTranslations } from 'next-intl'
import { ReactElement } from 'react'

type Props = {
  children: ReactElement
}

const Layout = ({ children }: Props) => {
  const t = useTranslations('Layout')

  return (
    <div className="container">
      <header className="header">
        <em>{t('header')}</em>
      </header>
      <main className="main">{children}</main>
      <footer className="footer">
        <em>{t('footer')}</em>
      </footer>
    </div>
  )
}

export default Layout
