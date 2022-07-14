import type { GetServerSideProps, NextPage } from 'next'
import { serverSideTranslations } from 'next-i18next/serverSideTranslations'
import { useTranslation } from 'next-i18next'

const Home: NextPage = () => {
  const { t } = useTranslation('common')

  return (
    <h1>
      {t('Index.title')}
      <a href="https://github.com/navapbc/template-application-nextjs">
        {t('Index.titleLink')}
      </a>
    </h1>
  )
}

export const getServerSideProps: GetServerSideProps = async ({ locale }) => {
  return {
    props: {
      ...(await serverSideTranslations(locale || 'en', ['common']))
    }
  }
}

export default Home
