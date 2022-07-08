import type { NextPage } from 'next'
import { useTranslations } from 'next-intl'

const Index: NextPage = () => {
  const t = useTranslations('Index')

  return (
    <>
      {t('title')}
    </>
  )
}

export default Index
