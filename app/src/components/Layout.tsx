import { useTranslation } from 'next-i18next'
import { ReactElement } from 'react'

type Props = {
  children: ReactElement
}

const Layout = ({ children }: Props): ReactElement => {
  const { t } = useTranslation('common')

  return (
    <div className="container">
      <header className="header">
        <em>{t('Layout.header')}</em>
      </header>
      <main className="main">{children}</main>
      <footer className="footer">
        <em>{t('Layout.footer')}</em>
      </footer>
    </div>
  )
}

export default Layout
