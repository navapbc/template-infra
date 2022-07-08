import { ReactElement } from 'react'
import { useTranslations } from 'next-intl'
import styles from '../../styles/Layout.module.scss'

type Props = {
  page?: ReactElement
}

const Layout = ({ page }: Props) => {
  const t = useTranslations('Layout')

  return (
    <>
      <header className={styles.header}>
        <em>{t('header')}</em>
      </header>
      <main className={styles.container}>
        {page}
      </main>
      <footer className={styles.footer}>
        <em>{t('footer')}</em>
      </footer>
    </>
  )
}

export default Layout
