import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Progress } from "@/components/ui/progress";
import { Separator } from "@/components/ui/separator";
import { StatusDot } from "@/components/status-dot";
import {
  CONNECTORS,
  SKILLS,
  STACK,
  readinessScore,
  type ConnectorStatus,
} from "@/lib/readiness";

const statusLabel: Record<ConnectorStatus, string> = {
  ready: "Ready",
  partial: "Partial",
  pending: "Needs auth",
};

export default function Home() {
  const score = readinessScore();
  const readyCount = CONNECTORS.filter((c) => c.status === "ready").length;
  const pendingCount = CONNECTORS.filter((c) => c.status === "pending").length;
  const skillGroups = ["apps", "agents", "ops"] as const;
  const groupTitle = {
    apps: "Published apps",
    agents: "Agent SDK",
    ops: "Cloud ops",
  };

  return (
    <main className="forge-wash relative min-h-screen overflow-hidden">
      <div className="forge-grid pointer-events-none absolute inset-0 opacity-70" />
      <div className="pointer-events-none absolute inset-x-0 top-0 h-px bg-gradient-to-r from-transparent via-[oklch(0.42_0.09_230/0.45)] to-transparent pulse-line" />

      <div className="relative mx-auto flex min-h-screen max-w-6xl flex-col px-5 pb-20 pt-8 sm:px-8 lg:px-10">
        <header className="reveal flex items-center justify-between gap-4">
          <div className="flex items-baseline gap-3">
            <span className="font-display text-2xl font-extrabold tracking-tight text-[oklch(0.18_0.03_250)] sm:text-3xl">
              FORGE
            </span>
            <span className="hidden text-sm text-muted-foreground sm:inline">
              Professional App Developer Studio
            </span>
          </div>
          <Badge variant="secondary" className="rounded-md font-medium">
            Node 22 · Next 16
          </Badge>
        </header>

        <section className="reveal reveal-delay-1 mt-16 flex flex-1 flex-col justify-center gap-8 pb-16 lg:mt-20 lg:max-w-3xl">
          <h1 className="font-display text-4xl font-extrabold leading-[1.05] tracking-tight text-[oklch(0.18_0.03_250)] sm:text-5xl lg:text-6xl">
            Skills installed.
            <br />
            Connectors live.
            <br />
            Ready to ship.
          </h1>
          <p className="max-w-xl text-base leading-relaxed text-muted-foreground sm:text-lg">
            This workspace is trained as a professional app developer:{" "}
            {SKILLS.length} Cursor skills loaded, {readyCount} connectors online,
            and a production Next.js stack primed for your next product.
          </p>
          <div className="flex flex-wrap items-center gap-3">
            <Button asChild size="lg" className="rounded-md px-6">
              <a href="#connectors">Review connectors</a>
            </Button>
            <Button asChild variant="outline" size="lg" className="rounded-md px-6">
              <a href="#skills">Browse skills</a>
            </Button>
          </div>
        </section>

        <section className="reveal reveal-delay-2 grid gap-10 border-t border-border/80 pt-12 lg:grid-cols-[1.1fr_0.9fr]">
          <div>
            <p className="text-xs font-semibold uppercase tracking-[0.16em] text-[oklch(0.42_0.09_230)]">
              Readiness
            </p>
            <div className="mt-4 flex items-end gap-3">
              <span className="font-display text-5xl font-extrabold tabular-nums text-[oklch(0.18_0.03_250)]">
                {score}%
              </span>
              <span className="mb-2 text-sm text-muted-foreground">
                connector coverage
              </span>
            </div>
            <Progress value={score} className="mt-4 h-2 max-w-md" />
            <p className="mt-3 text-sm text-muted-foreground">
              {readyCount} ready · {CONNECTORS.filter((c) => c.status === "partial").length}{" "}
              partial · {pendingCount} awaiting your auth approval
            </p>
          </div>
          <div>
            <p className="text-xs font-semibold uppercase tracking-[0.16em] text-[oklch(0.42_0.09_230)]">
              Default stack
            </p>
            <ul className="mt-4 flex flex-wrap gap-2">
              {STACK.map((item) => (
                <li
                  key={item}
                  className="rounded-md border border-border bg-white/70 px-3 py-1.5 text-sm font-medium text-foreground backdrop-blur"
                >
                  {item}
                </li>
              ))}
            </ul>
            <p className="mt-4 text-sm leading-relaxed text-muted-foreground">
              Shipping defaults: TypeScript web apps with shadcn primitives,
              publish-app hosting, optional identity and Postgres when the product
              needs them.
            </p>
          </div>
        </section>

        <Separator className="my-14" />

        <section id="connectors" className="reveal reveal-delay-3 scroll-mt-8">
          <div className="mb-8 flex flex-col gap-2 sm:flex-row sm:items-end sm:justify-between">
            <div>
              <h2 className="font-display text-3xl font-bold tracking-tight">
                Connectors
              </h2>
              <p className="mt-2 max-w-2xl text-sm text-muted-foreground sm:text-base">
                Approve any remaining auth prompts in Cursor to bring the last
                services online. Google Workspace, X, and Crustdata are ready.
              </p>
            </div>
          </div>
          <ul className="divide-y divide-border border-y border-border">
            {CONNECTORS.map((connector) => (
              <li
                key={connector.id}
                className="flex flex-col gap-2 py-4 sm:flex-row sm:items-center sm:justify-between sm:gap-6"
              >
                <div className="flex min-w-0 items-start gap-3">
                  <StatusDot status={connector.status} className="mt-1.5" />
                  <div className="min-w-0">
                    <p className="font-medium text-foreground">{connector.name}</p>
                    <p className="truncate text-sm text-muted-foreground">
                      {connector.detail}
                    </p>
                  </div>
                </div>
                <Badge
                  variant={connector.status === "ready" ? "default" : "secondary"}
                  className="w-fit shrink-0 rounded-md"
                >
                  {statusLabel[connector.status]}
                </Badge>
              </li>
            ))}
          </ul>
        </section>

        <section id="skills" className="mt-16 scroll-mt-8">
          <div className="mb-8">
            <h2 className="font-display text-3xl font-bold tracking-tight">
              Skills
            </h2>
            <p className="mt-2 max-w-2xl text-sm text-muted-foreground sm:text-base">
              All {SKILLS.length} available Cursor skills are loaded into this
              session for apps, Agent SDK work, and cloud operations.
            </p>
          </div>
          <div className="grid gap-10 md:grid-cols-3">
            {skillGroups.map((group) => (
              <div key={group}>
                <p className="text-xs font-semibold uppercase tracking-[0.16em] text-[oklch(0.42_0.09_230)]">
                  {groupTitle[group]}
                </p>
                <ul className="mt-4 space-y-4">
                  {SKILLS.filter((s) => s.group === group).map((skill) => (
                    <li key={skill.id}>
                      <p className="text-sm font-semibold text-foreground">
                        {skill.name}
                      </p>
                      <p className="mt-0.5 text-sm leading-snug text-muted-foreground">
                        {skill.summary}
                      </p>
                    </li>
                  ))}
                </ul>
              </div>
            ))}
          </div>
        </section>

        <section className="mt-16 rounded-xl border border-border bg-white/60 p-6 backdrop-blur sm:p-8">
          <h2 className="font-display text-2xl font-bold tracking-tight">
            What to build next
          </h2>
          <p className="mt-2 max-w-2xl text-sm leading-relaxed text-muted-foreground sm:text-base">
            Tell me the product — a dashboard, marketing site, Agent SDK bot,
            internal tool, or API — and I will implement a complete usable slice
            on this stack with connectors already in play.
          </p>
          <div className="mt-5 flex flex-wrap gap-2 text-sm text-muted-foreground">
            <span className="rounded-md border border-border bg-background px-3 py-1.5">
              Gmail + Drive workflows
            </span>
            <span className="rounded-md border border-border bg-background px-3 py-1.5">
              Sheets-backed ops tools
            </span>
            <span className="rounded-md border border-border bg-background px-3 py-1.5">
              Google Ads / Adspirer
            </span>
            <span className="rounded-md border border-border bg-background px-3 py-1.5">
              Hosted Cursor apps
            </span>
          </div>
        </section>

        <footer className="mt-16 border-t border-border pt-6 text-sm text-muted-foreground">
          Forge Studio · trained for professional app development
        </footer>
      </div>
    </main>
  );
}
