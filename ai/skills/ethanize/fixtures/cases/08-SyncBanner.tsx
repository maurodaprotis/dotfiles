import { Info } from 'lucide-react'

type SyncBannerProps = {
  lastSyncedLabel: string
  syncedCount: number
}

export const SyncBanner = ({ lastSyncedLabel, syncedCount }: SyncBannerProps) => (
  <div
    className="flex items-start gap-2 rounded-md border bg-muted/40 px-3 py-2"
    role="alert"
  >
    <Info className="mt-0.5 size-4 shrink-0 text-muted-foreground" />
    <div className="flex flex-col gap-0.5">
      <span className="text-sm font-medium">
        {syncedCount} contacts synced
      </span>
      <span className="text-xs text-muted-foreground">
        Last checked {lastSyncedLabel}
      </span>
    </div>
  </div>
)
