import { ComponentMeta, ComponentStory } from '@storybook/react'

import Layout from '../../src/components/Layout'

export default {
  title: 'Components',
  component: Layout,
} as ComponentMeta<typeof Layout>

const Template: ComponentStory<typeof Layout> = () => <Layout />

export const Home = Template.bind({})
