import baseConfig from '../playwright.config';
import { defineConfig } from '@playwright/test';

export default defineConfig(deepMerge(
    baseConfig,
    {
      use: {
        baseUrl: baseConfig.use.baseUrl || "localhost:3000"
      },
    }
  ));
