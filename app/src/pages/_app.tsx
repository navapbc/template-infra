import '../../public/uswds/css/styles.css'
import type { AppProps } from 'next/app'
import { AbstractIntlMessages, NextIntlProvider } from 'next-intl'
import { useEffect, useState } from 'react'
import { useRouter } from 'next/router'
import Layout from 'src/components/Layout'

function MyApp({ Component, pageProps }: AppProps) {
  const { locale } = useRouter()
  const [ localeMessages, setLocaleMessages ] = useState<undefined | AbstractIntlMessages>(undefined);

  useEffect(() => {
    const _getLocaleMessages = async (locale: string | undefined): Promise<void> => {
      const messages: undefined | AbstractIntlMessages = await import(`../messages/${locale}.json`)
      setLocaleMessages(messages)
    }

    _getLocaleMessages(locale).catch(console.error)
  }, [])

  return localeMessages && (
    <Layout>
      <NextIntlProvider messages={localeMessages}>
        <Component {...pageProps} />
      </NextIntlProvider>
    </Layout>
  )
}

export default MyApp