// QB3 — the count is inventory (what the action *could* affect), deliberately
// the max across all choices, not a preview of the pending mutation.
// "this is intentional -- we want to show the count of available mutations"
import { Rocket } from 'lucide-react'

import { Tooltip } from '@/components/shared/Tooltip'
import { Button } from '@/components/ui/button'

export const BulkLaunchAction = ({
  choices,
  isUnlocking,
  onLaunch,
}: {
  choices: Array<{ launchPlacements: Array<{ id: number }> }>
  isUnlocking: boolean
  onLaunch: () => void
}) => {
  const bulkLaunchCount = Math.max(
    ...choices.map((choice) => choice.launchPlacements.length),
    0
  )

  return (
    <Tooltip asChild content="Launch">
      <Button
        aria-label={`Launch ${bulkLaunchCount} placements`}
        className="gap-2 px-2"
        disabled={isUnlocking}
        size="sm"
        variant="ghost"
        onClick={onLaunch}
      >
        <Rocket size={16} />
        <span className="text-xs text-muted-foreground">{bulkLaunchCount}</span>
      </Button>
    </Tooltip>
  )
}
