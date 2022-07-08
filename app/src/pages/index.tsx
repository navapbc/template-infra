import type { NextPage } from 'next'
import { useTranslations } from 'next-intl'

const Index: NextPage = () => {
  const t = useTranslations('Index')

  return (
    <h1>
      {t('title')}
      <a href="https://github.com/navapbc/template-application-nextjs">
        {t('titleLink')}
      </a>
    </h1>
  )
}

export default Index
