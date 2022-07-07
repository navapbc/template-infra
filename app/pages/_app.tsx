import '../public/css/styles.css'
import type { AppProps } from 'next/app'
import { NextIntlProvider } from 'next-intl'

function MyApp({ Component, pageProps }: AppProps) {
  return (
    <NextIntlProvider messages={en}>
      <Component {...pageProps} />    
    </NextIntlProvider>
  ) 
  
}

export default MyApp
