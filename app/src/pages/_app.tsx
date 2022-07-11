import { AbstractIntlMessages, NextIntlProvider } from 'next-intl'
import type { AppProps } from 'next/app'
import { useRouter } from 'next/router'
import { useEffect, useState } from 'react'
import Layout from 'src/components/Layout'

import '../../styles/styles.scss'

function MyApp({ Component, pageProps }: AppProps) {
  const { locale } = useRouter()
  const [localeMessages, setLocaleMessages] = useState<AbstractIntlMessages>()

  useEffect(() => {
    const _getLocaleMessages = async (
      locale: string | undefined
    ): Promise<void> => {
      /* eslint-disable */
      const messages: AbstractIntlMessages =
        locale && (await import(`../messages/${locale}.json`))
      setLocaleMessages(messages)
    }

    _getLocaleMessages(locale).catch(console.error)
  }, [locale])

  return (
    localeMessages && (
      <NextIntlProvider messages={localeMessages}>
        <Layout>
          <Component {...pageProps} />
        </Layout>
      </NextIntlProvider>
    )
  )
}

export default MyApp
