import { Download, Trash2 } from 'lucide-react'

import { Button } from '@/components/ui/button'

type ResourceRowProps = {
  fileName: string
  onDownload: () => void
  onDelete: () => void
}

export const ResourceRow = ({
  fileName,
  onDownload,
  onDelete,
}: ResourceRowProps) => (
  <li className="group flex items-center gap-2 rounded-md px-2 py-1.5 hover:bg-muted">
    <span className="flex-1 text-sm">{fileName}</span>
    <div className="flex items-center gap-1 opacity-0 transition-opacity group-hover:opacity-100">
      <Button aria-label="Download" size="icon-sm" variant="ghost" onClick={onDownload}>
        <Download size={16} />
      </Button>
      <Button aria-label="Delete" size="icon-sm" variant="ghost" onClick={onDelete}>
        <Trash2 size={16} />
      </Button>
    </div>
  </li>
)
