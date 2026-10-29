import { Loader2 } from 'lucide-react'

type PitchPanelProps = {
  isGenerating: boolean
  pitchHtml: string | null
}

export const PitchPanel = ({ isGenerating, pitchHtml }: PitchPanelProps) => {
  if (isGenerating) {
    return (
      <div className="flex min-h-[160px] flex-col items-center justify-center gap-3 rounded-lg bg-muted/30">
        <Loader2 className="size-5 animate-spin text-muted-foreground" />
        <p className="text-sm text-muted-foreground">Generating your pitch...</p>
      </div>
    )
  }

  return (
    <div
      className="prose-sm text-sm leading-6"
      dangerouslySetInnerHTML={{ __html: pitchHtml ?? '' }}
    />
  )
}
