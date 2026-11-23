# Forge — Professional App Developer Studio

Forge is a readiness workspace for shipping production apps with Cursor Cloud Agents. It tracks loaded skills, connected MCP services, and a default Next.js stack.

## What's included

- **Next.js 16** + TypeScript + Tailwind CSS + shadcn/ui
- Inventory of **20 Cursor skills** (apps, Agent SDK, cloud ops)
- Live **connector readiness** for Gmail, Drive, Sheets, Adspirer, GitHub, Origin, and more

## Run locally

```bash
npm install
npm run dev
```

Open [http://localhost:3847](http://localhost:3847).

## Scripts

| Command        | Purpose              |
| -------------- | -------------------- |
| `npm run dev`  | Dev server on 3847   |
| `npm run build`| Production build     |
| `npm run start`| Serve production     |
| `npm run lint` | ESLint               |

## Next steps

Tell the agent what to build. Remaining connectors that still need auth (Google Calendar, X, X Ads, Crustdata, Adspirer Search Ads) can be finished from Cursor's connector prompts.
