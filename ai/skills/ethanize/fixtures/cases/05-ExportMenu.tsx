import { MoreVertical } from 'lucide-react'

import { DropdownMenu } from '@/components/shared/DropdownMenu'
import { Button } from '@/components/ui/button'

type ExportMenuProps = {
  onExportCsv: () => void
  onExportPdf: () => void
}

export const ExportMenu = ({ onExportCsv, onExportPdf }: ExportMenuProps) => (
  <DropdownMenu.Root>
    <DropdownMenu.Trigger asChild>
      <Button aria-label="Export Options" size="icon-sm" variant="ghost">
        <MoreVertical size={16} />
      </Button>
    </DropdownMenu.Trigger>
    <DropdownMenu.Content align="end">
      <DropdownMenu.Item onSelect={onExportCsv}>
        Download Spreadsheet
      </DropdownMenu.Item>
      <DropdownMenu.Item onSelect={onExportPdf}>
        Export Deal Report
      </DropdownMenu.Item>
    </DropdownMenu.Content>
  </DropdownMenu.Root>
)
