// QB5 — the tick is ID-matched or absent. An attribute fallback was the bug:
// "two user-input observations are indistinguishable by attributes and a
// shared-type key ticks both." A row with no id shows no checkmark, on purpose.
import { Check } from 'lucide-react'

import { DropdownMenu } from '@/components/shared/DropdownMenu'

type Source = { id: number | null; label: string; sourceType: string }

export const SourceMenu = ({
  sources,
  selectedId,
  onSelect,
}: {
  sources: Array<Source>
  selectedId: number | null
  onSelect: (id: number | null) => void
}) => (
  <DropdownMenu.Content align="start" className="min-w-56">
    {sources.map((source, index) => {
      const isSelected = source.id !== null && source.id === selectedId

      return (
        <DropdownMenu.Item
          key={source.id ?? `unsaved-${index}`}
          onSelect={() => onSelect(source.id)}
        >
          <span className="flex-1 truncate">{source.label}</span>
          {isSelected ? <Check className="size-4 shrink-0" /> : null}
        </DropdownMenu.Item>
      )
    })}
  </DropdownMenu.Content>
)
