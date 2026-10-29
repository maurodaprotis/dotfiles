import { useState } from 'react'

import { Input } from '@/components/ui/input'
import { Popover, PopoverContent, PopoverTrigger } from '@/components/ui/popover'

type Result = { id: string; label: string }

export const PlaceSearchDropdown = ({
  results,
  onPick,
}: {
  results: Array<Result>
  onPick: (id: string) => void
}) => {
  const [open, setOpen] = useState(false)
  const [activeIndex, setActiveIndex] = useState(0)

  return (
    <Popover open={open} onOpenChange={setOpen}>
      <PopoverTrigger asChild>
        <Input
          placeholder="Search places"
          onFocus={() => setOpen(true)}
        />
      </PopoverTrigger>
      <PopoverContent align="start" className="w-80 p-1">
        {results.map((result, index) => (
          <button
            key={result.id}
            className={
              index === activeIndex
                ? 'flex w-full rounded-sm bg-muted px-2 py-1.5 text-left text-sm hover:bg-muted'
                : 'flex w-full rounded-sm px-2 py-1.5 text-left text-sm hover:bg-muted'
            }
            type="button"
            onClick={() => onPick(result.id)}
            onMouseEnter={() => setActiveIndex(index)}
          >
            {result.label}
          </button>
        ))}
      </PopoverContent>
    </Popover>
  )
}
