// QB4 — attribution is all-or-nothing. A failed or empty generation shows
// nothing, not even the timestamp: "a bare timestamp over a pitch that was
// never written is just as misleading." There is deliberately no
// timestamp-only fallback here.
import { LevAI } from '@/components/Icons/LevAI'

export const PitchAttribution = ({
  pitchHtml,
  generatedAtLabel,
}: {
  pitchHtml: string | null
  generatedAtLabel: string | null
}) => {
  const hasContent = !!pitchHtml && pitchHtml.trim().length > 0

  if (!hasContent) return null

  return (
    <p className="flex items-center gap-1.5 text-xs text-muted-foreground">
      <LevAI aria-hidden className="size-3.5 shrink-0" />
      Generated {generatedAtLabel} by Lev Agent
    </p>
  )
}
