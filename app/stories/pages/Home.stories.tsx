import { ComponentMeta, ComponentStory } from '@storybook/react'

import HomePage from '../../pages/index'

export default {
  title: 'Pages',
  component: HomePage,
} as ComponentMeta<typeof HomePage>

const Template: ComponentStory<typeof HomePage> = () => <HomePage />

export const Home = Template.bind({})
