import { cn } from "@/lib/utils";
import type { ConnectorStatus } from "@/lib/readiness";

const styles: Record<ConnectorStatus, string> = {
  ready: "bg-emerald-500 shadow-[0_0_0_3px_rgba(16,185,129,0.18)]",
  partial: "bg-amber-500 shadow-[0_0_0_3px_rgba(245,158,11,0.18)]",
  pending: "bg-zinc-400",
  declined: "bg-zinc-300",
};

export function StatusDot({
  status,
  className,
}: {
  status: ConnectorStatus;
  className?: string;
}) {
  return (
    <span
      aria-hidden
      className={cn(
        "inline-block size-2.5 shrink-0 rounded-full",
        styles[status],
        className,
      )}
    />
  );
}
