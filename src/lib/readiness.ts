export type ConnectorStatus = "ready" | "pending" | "partial";

export type Connector = {
  id: string;
  name: string;
  status: ConnectorStatus;
  detail: string;
  category: "google" | "ads" | "code" | "social" | "data";
};

export type Skill = {
  id: string;
  name: string;
  group: "apps" | "agents" | "ops";
  summary: string;
};

export const SKILLS: Skill[] = [
  {
    id: "env-setup",
    name: "Environment setup",
    group: "ops",
    summary: "Cloud Agent install/start, builds, and snapshots",
  },
  {
    id: "apps-identity",
    name: "Apps identity",
    group: "apps",
    summary: "Signed-in viewer identity for private/team published apps",
  },
  {
    id: "apps-database",
    name: "Apps database",
    group: "apps",
    summary: "Postgres for published apps with local PGlite fallback",
  },
  {
    id: "canvas",
    name: "Canvas",
    group: "apps",
    summary: "Durable React canvases for reports and tools",
  },
  {
    id: "walkthrough-artifacts",
    name: "Walkthrough artifacts",
    group: "ops",
    summary: "Screenshots and recordings that prove changes work",
  },
  {
    id: "subscribe",
    name: "Subscriptions",
    group: "ops",
    summary: "Event-driven waits for CI, PRs, Slack, and Linear",
  },
  {
    id: "migrate-to-builds",
    name: "Migrate to builds",
    group: "ops",
    summary: "Verify prebuilt environment build compatibility",
  },
  {
    id: "agent-sdk-framework-map",
    name: "Agent SDK map",
    group: "agents",
    summary: "Layout, sessions, Node invariants, and host.kv memory",
  },
  {
    id: "agent-sdk-cli",
    name: "Agent SDK CLI",
    group: "agents",
    summary: "Safe BDK CLI usage with dry-run and JSON output",
  },
  {
    id: "agent-sdk-create-agent",
    name: "Create agent",
    group: "agents",
    summary: "Scaffold a new Agent SDK bot end to end",
  },
  {
    id: "agent-sdk-debug",
    name: "Debug agent",
    group: "agents",
    summary: "Diagnose playground, sessions, and webhook failures",
  },
  {
    id: "agent-sdk-deploy",
    name: "Deploy agent",
    group: "agents",
    summary: "Hosted Agent SDK deploy with service accounts",
  },
  {
    id: "agent-sdk-evals",
    name: "Agent evals",
    group: "agents",
    summary: "Author and run defineEval cases",
  },
  {
    id: "agent-sdk-hillclimb",
    name: "Hillclimb",
    group: "agents",
    summary: "Improve one agent with measured levers and locked wins",
  },
  {
    id: "agent-sdk-github",
    name: "GitHub agents",
    group: "agents",
    summary: "GitHub-driven Agent SDK hooks and test tiers",
  },
  {
    id: "agent-sdk-mcp-auth",
    name: "MCP auth",
    group: "agents",
    summary: "OAuth for defineConnection MCP tools",
  },
  {
    id: "agent-sdk-setup-slack",
    name: "Slack setup",
    group: "agents",
    summary: "Socket Mode Slack wiring for Agent SDK",
  },
  {
    id: "agent-sdk-setup-teams",
    name: "Teams setup",
    group: "agents",
    summary: "Microsoft Teams + Azure Bot wiring",
  },
  {
    id: "agent-sdk-otel",
    name: "OpenTelemetry",
    group: "agents",
    summary: "OTEL export for agent observability",
  },
  {
    id: "agent-sdk-migrate-v2",
    name: "Migrate v2",
    group: "agents",
    summary: "Move Agent SDK projects from architecture v1 to v2",
  },
];

export const CONNECTORS: Connector[] = [
  {
    id: "gmail",
    name: "Gmail",
    status: "ready",
    detail: "acshope119@gmail.com",
    category: "google",
  },
  {
    id: "google-drive",
    name: "Google Drive",
    status: "ready",
    detail: "Files, folders, Docs content",
    category: "google",
  },
  {
    id: "google-sheets",
    name: "Google Sheets",
    status: "ready",
    detail: "Spreadsheets, ranges, charts",
    category: "google",
  },
  {
    id: "google-calendar",
    name: "Google Calendar",
    status: "pending",
    detail: "Approve the auth prompt to finish",
    category: "google",
  },
  {
    id: "adspirer",
    name: "Adspirer",
    status: "partial",
    detail: "Google Ads live · Meta/TikTok/LinkedIn open",
    category: "ads",
  },
  {
    id: "adspirer-search-ads",
    name: "Adspirer Search Ads",
    status: "pending",
    detail: "Approve the auth prompt to finish",
    category: "ads",
  },
  {
    id: "x-ads",
    name: "X Ads",
    status: "pending",
    detail: "Approve the auth prompt to finish",
    category: "ads",
  },
  {
    id: "x",
    name: "X",
    status: "pending",
    detail: "Approve the auth prompt to finish",
    category: "social",
  },
  {
    id: "crustdata",
    name: "Crustdata",
    status: "pending",
    detail: "Approve the auth prompt to finish",
    category: "data",
  },
  {
    id: "cursor-github",
    name: "GitHub",
    status: "ready",
    detail: "Repos, PRs, Actions, code search",
    category: "code",
  },
  {
    id: "cursor-origin",
    name: "Origin",
    status: "ready",
    detail: "Origin repos, PRs, and checks",
    category: "code",
  },
  {
    id: "cursor-cloud",
    name: "Cursor Cloud",
    status: "ready",
    detail: "Publish apps, secrets, environments",
    category: "code",
  },
  {
    id: "cursor-subscriptions",
    name: "Subscriptions",
    status: "ready",
    detail: "CI, PR, Slack, Linear event waits",
    category: "code",
  },
];

export const STACK = [
  "Next.js 16",
  "TypeScript",
  "Tailwind CSS",
  "shadcn/ui",
  "Node 22",
] as const;

export function readinessScore(connectors: Connector[] = CONNECTORS) {
  const weight = { ready: 1, partial: 0.6, pending: 0 } as const;
  const total = connectors.reduce((sum, c) => sum + weight[c.status], 0);
  return Math.round((total / connectors.length) * 100);
}
