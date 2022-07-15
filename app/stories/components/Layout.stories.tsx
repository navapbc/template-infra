import { ComponentMeta, ComponentStory } from '@storybook/react'

import LayoutComponent from '../../src/components/Layout'

export default {
  title: 'Components',
  component: LayoutComponent,
} as ComponentMeta<typeof LayoutComponent>

const Template: ComponentStory<typeof LayoutComponent> = () => (
  <LayoutComponent>
    <h1>"child"</h1>
  </LayoutComponent>
)

export const Layout = Template.bind({})
