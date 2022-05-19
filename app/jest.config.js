// @ts-check

/** @type {import('ts-jest/dist/types').InitialOptionsTsJest} */

module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'jsdom',
  moduleNameMapper: {
    '\\.(css|scss)$': '<rootDir>/__mocks__/styleMock.js',
    '^@pages(.*)$': '<rootDir>/pages$1'
  },
  setupFilesAfterEnv: ['<rootDir>/test/jest.setup.js'],
  transform: {
    '^.+\\.tsx?$': 'ts-jest',
  },
  transformIgnorePatterns: [
    '/.next/',
    '/node_modules/',
    '^.+\\.module\\.(css|sass|scss)$'
  ]
}; 