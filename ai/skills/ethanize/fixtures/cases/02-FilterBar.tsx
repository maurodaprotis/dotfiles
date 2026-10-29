import { twMerge } from 'tailwind-merge'

type FilterBarProps = {
  options: Array<{ id: string; label: string }>
  activeId: string
  onSelect: (id: string) => void
}

export const FilterBar = ({ options, activeId, onSelect }: FilterBarProps) => (
  <div className="flex items-center gap-1 border-b px-2">
    {options.map((option) => (
      <button
        key={option.id}
        className={twMerge(
          'rounded-md px-3 py-1.5 text-[13px] transition-all duration-200',
          option.id === activeId
            ? 'bg-muted font-medium text-foreground'
            : 'text-muted-foreground hover:bg-muted hover:px-4'
        )}
        type="button"
        onClick={() => onSelect(option.id)}
      >
        {option.label}
      </button>
    ))}
  </div>
)
