This is a [Next.js](https://nextjs.org/) project bootstrapped with [`create-next-app`](https://github.com/vercel/next.js/tree/canary/packages/create-next-app). This README has been modified from the auto-generated one.

## Getting Started

First, install dependencies:

```bash
yarn
```

Second, run the development server:

```bash
yarn dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

You can start editing the page by modifying `pages/index.tsx`. The page auto-updates as you edit the file.

A starter [API route](https://nextjs.org/docs/api-routes/introduction) can be accessed on [http://localhost:3000/api/hello](http://localhost:3000/api/hello). This endpoint can be edited in `pages/api/hello.ts`.

The `pages/api` directory is mapped to `/api/*`. Files in this directory are treated as [API routes](https://nextjs.org/docs/api-routes/introduction) instead of React pages.

## Local Linter and Typechecker Setup

### Setting up up linting and typechecking for local development

For linting, this application is leveraging `eslint`, `prettier` and Nava's [eslint-config-nava](https://github.com/navapbc/eslint-config-nava). Although, these will be run on CI and prior to commit, it is still recommended that we tell our code editor to auto-fix eslint and prettier errors on save.

In VSCode, do so by creating a `.vscode/settings.json` file with:

```
{
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  },
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode"
}
```

For typechecking, this application is leveraging Next.js' [incremental typechecking](https://nextjs.org/docs/basic-features/typescript#incremental-type-checking). NextJS will run type checking as a part of `next build`-- Although it is still recommended that we set up type checking using our code editor for development. In VSCode, do so by adding the following to your `.vscode/settings.json` file

```
"typescript.validate.enable": true
```

Note: make sure TypeScript and Javascript Language Features are enabled in VS Code Extensions.

### Eslint rules explained

- "@typescript-eslint/no-unused-vars": "error"
  - Disallows unused variables-- prevents dead code accumulation.
- "@typescript-eslint/no-explicit-any": "error"
  - Disallows usage of `any` type. The usage of `any` defeats the purpose of typescript. Consider using `unknown` type instead instead.
- "react/resct-in-jsx-scope": "off"
  - suppress errors for missing 'import React' in files because NextJS does this for us.
- "space-before-function-paren": ["error", "never"]
  - suppresses errors for lack of space before function parenthesis to allow for `function()`

### Tsconfig additions to auto-generated file

- `target: es6` -- nextJS set this valule to `es5` by default.
- `allowJS: true` -- allows ts checks on javascript files.
- `checkJS: true` -- works in tandem with `allowJS`. Alternative to adding `// @ts-check` at top of Js files-- instructs ts to check all js files.
- `jsx: react-jsx` -- [Documentation on this option](https://www.typescriptlang.org/docs/handbook/jsx.html). This value updates the JSX mode that TS whips with. Updating this from "preserve" helped get jest tests into a passing state. TODO: figure out why.
- `incremental: true` -- enables incremental typechecking. Incremental typechecking creates a series of `.tsbuildinfo` files to dave information from last compilation. This expedites type checking during build.
- `baseUrl: "."` & `paths: { @pages/*: [pages/*] }` -- These two, in tandem, setup module path aliases for cleaner imports. To utilize this, import files like: `import Home from "@pages/index";`

### Package.json

#### Scripts

- `format`: instructs prettier to rewrite files with fixes for formatting violations.
- `format-check`: instructs prettier to only check files for violations without fixing them.
- `test`: runs `jest --ci --coverage`. [--ci option](https://jestjs.io/docs/cli#--ci) is provided to prevent automatic creation of snapshots. This requires Jest to be run with `--updateSnapshot`. [--coverage option](https://jestjs.io/docs/cli#--coverageboolean) is provided to instruct jest to collect and report test coverage in output.
- `ts:check`: runs `tsc --noEmit`. [--noEmit option](https://www.typescriptlang.org/tsconfig#noEmit) is provided to prevent type checker compiler from outputting files.

#### Dependencies

- `@typescript-eslint/parser`: implemented in .eslint.json via `"parser": "@typescript-eslint/parser"`. This [plugin](https://www.npmjs.com/package/@typescript-eslint/parser) works in tandem with other plugins to help facilitate the usage of ESlint with TypeScript.
- `@types/jest-axe`: This package contains type definitions for [jest-axe](https://www.npmjs.com/package/jest-axe).

#### Dev Dependencies

- `@babel/preset-typescript`: This [module](https://babeljs.io/docs/en/babel-preset-typescript) allows us to use babel to transpile TypeScript into Javascript, specifically for [jest testing](https://jestjs.io/docs/getting-started#using-typescript) in our case. Implemented in .babelrc > presets.
- `@testing-library/dom`: This [module](https://github.com/testing-library/dom-testing-library) provides querying fo.
- `@testing-library/jest-dom`: This [module](https://testing-library.com/docs/ecosystem-jest-dom/) is a companion for testing-library/dom-- it provides DOM element matchers for jest.
- `@testing-library/react`: This [module](https://testing-library.com/docs/react-testing-library/intro/) works in tandem with testing-library/dom to add APIs for testing React components.
- `babel-jest`: This [module](https://www.npmjs.com/package/babel-jest) works to compile JavaScript/Typescript code using babel for testing. Automatically implemented if `jest-cli` is used.
- `eslint`: This [module](https://www.npmjs.com/package/eslint) provides linting. Configuration implemented in .eslintrc.
- `eslint-config-nava`: This [module](https://github.com/navapbc/eslint-config-nava) contains nava's preferred configurations for eslint. It is implemented in .eslintrc > extensions > nava.
- `eslint-config-next`: This [module](https://nextjs.org/docs/basic-features/eslint) is automatically installed by nextJS, it includes out of the eslint configuration. Implemented in .eslintrc.json > extends > next.
- `eslint-config-prettier`: This [module](https://github.com/prettier/eslint-config-prettier) turns off eslint rules that may conflict with prettier. Implemented in .eslintrc > extends > prettier.
- `jest-environment-jsdom`: This [module](https://www.npmjs.com/package/jest-environment-jsdom) simulates the DOM for testing. Implemented in jest.config.js > testEnvironment.
- `prettier`: This [module](https://prettier.io/) is used for code formatting. Implemented in .prettierrc.json.
- `ts-jest`: This [module](https://www.npmjs.com/package/ts-jest) lets ys yse hest to test our project written in TypeScript. Implemented in jest.config.js > preset > ts-jest
