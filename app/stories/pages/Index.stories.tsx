import { ComponentStory, ComponentMeta } from '@storybook/react'

import Index from '../../src/pages/index'

export default {
  title: 'Pages',
  component: Index,
} as ComponentMeta<typeof Index>

const Template: ComponentStory<typeof Index> = () => <Index />

export const Home = Template.bind({})
