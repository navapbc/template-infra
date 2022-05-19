This is a [Next.js](https://nextjs.org/) project bootstrapped with [`create-next-app`](https://github.com/vercel/next.js/tree/canary/packages/create-next-app).

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

## Linter and Typechecker

This application is leveraging `eslint` and nava's internal [eslint-config-nava](https://github.com/navapbc/eslint-config-nava). Although, it is still recommended that you tell your IDE to auto-fix eslint errors on save. In VSCode, to do so, create a .vscode/settings.json file with:

```
{
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  }
}
```