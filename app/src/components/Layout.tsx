import { ReactElement } from 'react'
import { useTranslations } from 'next-intl'
import styles from '../../styles/Layout.module.scss'

type Props = {
  children: ReactElement
}

const Layout = ({ children }: Props) => {
  const t = useTranslations('Layout')

  return (
    <>
      <header className={styles.header}>
        <em>{t('header')}</em>
      </header>
      <main className={styles.container}>{children}</main>
      <footer className={styles.footer}>
        <em>{t('footer')}</em>
      </footer>
    </>
  )
}

export default Layout
