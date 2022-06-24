import '../public/css/styles.css' // Apply global styling to our stories
// this doesn't work:
// Error: Can't resolve '../uswds/img/hero.png' in '/srv/public/css'
// import '../public/css/styles.storybook.css' // Apply global styling to our stories

export const parameters = {
  actions: { argTypesRegex: '^on[A-Z].*' },
  controls: {
    matchers: {
      color: /(background|color)$/i,
      date: /Date$/,
    },
  },
}
