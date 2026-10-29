// BC1 — this menu item inherits `cursor-default` from the installed Airy
// primitive at src/components/ui/dropdown-menu.tsx. That file is a PROTECTED
// PATH (QB1): "installed from the Airy registry ... per AGENTS.md we don't edit
// it in the consuming app. Real fix belongs upstream in Airy if we want it."
//
// The correct outcome for this fixture is a [flag] that says "belongs upstream",
// or an app-owned wrapper override. It is NEVER an edit to the primitive.
import { DropdownMenu } from '@/components/shared/DropdownMenu'

export const DealActionsMenu = ({
  onArchive,
  onDuplicate,
}: {
  onArchive: () => void
  onDuplicate: () => void
}) => (
  <DropdownMenu.Content align="end" className="min-w-48">
    <DropdownMenu.Item onSelect={onDuplicate}>Duplicate deal</DropdownMenu.Item>
    <DropdownMenu.Item onSelect={onArchive}>Archive deal</DropdownMenu.Item>
  </DropdownMenu.Content>
)
