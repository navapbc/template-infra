// Load environment variables from .env file if it exists
import * as dotenv from 'dotenv';

import { defineConfig, devices } from "@playwright/test";

dotenv.config();

/**
 * See https://playwright.dev/docs/test-configuration.
 */
export default defineConfig({
  // Timeout for each test in milliseconds
  timeout: 20000,
  testDir: "./tests", // Ensure this points to the correct test directory
  // Run tests in files in parallel
  fullyParallel: true,
  // Fail the build on CI if you accidentally left test.only in the source code.
  forbidOnly: !!process.env.CI,
  // Retry on CI only
  retries: process.env.CI ? 2 : 0,
  // Opt out of parallel tests on CI.
  workers: process.env.CI ? 1 : undefined,
  // Reporter to use. See https://playwright.dev/docs/test-reporters
  reporter: "html",
  // Shared settings for all the projects below. See https://playwright.dev/docs/api/class-testoptions.
  use: {
    // Base URL to use in actions like `await page.goto('/')`.
    baseURL: process.env.BASE_URL,

    // Collect trace when retrying the failed test. See https://playwright.dev/docs/trace-viewer
    trace: "on-first-retry",
    screenshot: "on",
    video: "on-first-retry",
  },

  // Configure projects for major browsers
  // Supported browsers: https://playwright.dev/docs/browsers#:~:text=Configure%20Browsers%E2%80%8B,Google%20Chrome%20and%20Microsoft%20Edge.
  projects: [
    {
      name: "chromium",
      use: { ...devices["Desktop Chrome"] },
    },

    // Test against mobile viewports.
    {
      name: "Mobile Chrome",
      use: { ...devices["Pixel 7"] },
    },
  ],

});
