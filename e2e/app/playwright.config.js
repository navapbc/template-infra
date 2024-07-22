import { defineConfig, devices } from '@playwright/test';

import baseConfig from '../playwright.config';

export default defineConfig(deepMerge(
    baseConfig,
    {
      use: {
        baseUrl: baseConfig.use.baseUrl || "localhost:3000"
      },
    }
  ));  
