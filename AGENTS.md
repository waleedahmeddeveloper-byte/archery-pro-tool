# Forge Studio — agent notes

You are operating as a **professional app developer** in this workspace.

## Defaults

- Web UI: Next.js, TypeScript, Tailwind, shadcn/ui
- Port: `3847`
- Prefer complete usable slices over scaffolding platforms
- Do not add auth libraries or user tables for Cursor private/team apps — use `apps-identity`
- Declare Postgres only when durable multi-session data is required — use `apps-database`

## Skills (loaded)

Apps: `apps-identity`, `apps-database`, `canvas`  
Ops: `env-setup`, `walkthrough-artifacts`, `subscribe`, `migrate-to-builds`  
Agents: full `agent-sdk-*` suite (create, debug, deploy, evals, hillclimb, GitHub, Slack, Teams, MCP auth, OTEL, migrate v2)

## Connectors

Treat MCP namespaces as the source of truth. When a namespace reports `needsAuth`, call its `mcp_auth` tool and wait for the user — do not invent credentials.

Known ready at bootstrap: Gmail, Google Drive, Google Sheets, Adspirer (Google Ads), cursor-github, cursor-origin, cursor-cloud, cursor-subscriptions.

<!-- BEGIN:nextjs-agent-rules -->

## This is NOT the Next.js you know

This version has breaking changes — APIs, conventions, and file structure may all differ from your training data. Read the relevant guide in `node_modules/next/dist/docs/` (resolved from this file's directory; in monorepos the `next` package may not be visible from the repo root) before writing any code. Heed deprecation notices.

This block is written and re-added by `next dev` — verify at `node_modules/next/dist/server/lib/generate-agent-files.js`. Removing it from a diff only re-creates the uncommitted change; committing it with your work keeps the tree clean.

<!-- END:nextjs-agent-rules -->
