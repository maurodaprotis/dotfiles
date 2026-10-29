import { AlertTriangle } from 'lucide-react'

import { Button } from '@/components/ui/button'

type CreditsFooterProps = {
  canAfford: boolean
  isSubmitting: boolean
  onConfirm: () => void
}

export const CreditsFooter = ({
  canAfford,
  isSubmitting,
  onConfirm,
}: CreditsFooterProps) => (
  <div className="flex items-center justify-between gap-3 border-t px-6 py-4">
    {!canAfford ? (
      <p className="flex items-start gap-2 text-xs text-error-foreground">
        <AlertTriangle className="mt-0.5 size-3.5 shrink-0" />
        <span>
          Something went wrong. Select fewer placements or purchase more
          credits.
        </span>
      </p>
    ) : (
      <span />
    )}
    <Button disabled={isSubmitting} onClick={onConfirm}>
      Unlock and launch
    </Button>
  </div>
)
