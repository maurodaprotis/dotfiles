// QB6 — this click only submits the request; the AI-composing moment happens
// later, in the pitch section, where the streaming animation plays. Typing dots
// here "would suggest text is being composed there". A plain Loader2 is correct
// even though this button lives inside an AI panel.
import { Loader2 } from 'lucide-react'

import { Button } from '@/components/ui/button'

export const GeneratePitchSubmit = ({
  isSubmitting,
  prompt,
  onSubmit,
}: {
  isSubmitting: boolean
  prompt: string
  onSubmit: () => void
}) => (
  <Button
    disabled={isSubmitting || !prompt.trim()}
    size="sm"
    onClick={onSubmit}
  >
    {isSubmitting ? <Loader2 className="size-4 animate-spin" /> : null}
    Generate
  </Button>
)
