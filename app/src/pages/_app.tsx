import '../../styles/styles.scss'
import type { AppProps } from 'next/app'
import { appWithTranslation } from 'next-i18next'
import Layout from '../components/Layout'

function MyApp({ Component, pageProps }: AppProps) {
  return (
    <Layout>
      <Component {...pageProps} />
    </Layout>
  )
}

export default appWithTranslation(MyApp)
