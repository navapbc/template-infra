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

### Tsconfig additions to auto-generated file

- `target: es6` -- nextJS set this valule to `es5` by default. 
- `allowJS: true` -- allows ts checks on javascript files. 
- `checkJS: true` -- works in tandem with `allowJS`. Alternative to adding `// @ts-check` at top of Js files-- instructs ts to check all js files. 
- `jsx: react-jsx` -- [Documentation on this option](https://www.typescriptlang.org/docs/handbook/jsx.html). This value updates the JSX mode that TS whips with. Updating this from "preserve" helped get jest tests into a passing state. TODO: figure out why.
- `incremental: true` -- enables incremental typechecking. Incremental typechecking creates a series of `.tsbuildinfo` files to dave information from last compilation. This expedites type checking during build. 
- `baseUrl: "."` & `paths: { @pages/*: [pages/*] }` -- These two, in tandem, setup module path aliases for cleaner imports. To utilize this, import files like: `import Home from "@pages/index";`

### Package.json packages explained 
