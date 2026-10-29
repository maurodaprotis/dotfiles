import { Eye, Trash2 } from 'lucide-react'

import { Button } from '@/components/ui/button'

type Attachment = { id: number; displayName: string }

export const AttachmentActions = ({
  attachments,
  onPreview,
  onRemove,
}: {
  attachments: Array<Attachment>
  onPreview: (id: number) => void
  onRemove: (id: number) => void
}) => (
  <ul className="flex flex-col">
    {attachments.map((attachment) => (
      <li key={attachment.id} className="flex items-center gap-2 py-1">
        <span className="flex-1 text-xs">{attachment.displayName}</span>
        <Button
          aria-label="View document"
          className="w-6 p-0"
          variant="ghost"
          onClick={() => onPreview(attachment.id)}
        >
          <Eye className="size-4" />
        </Button>
        <Button
          aria-label="Remove document"
          className="w-6 p-0"
          variant="ghost"
          onClick={() => onRemove(attachment.id)}
        >
          <Trash2 className="size-4" />
        </Button>
      </li>
    ))}
  </ul>
)
