import { useState } from 'react'

import { Button } from '@/components/ui/button'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'
import { Input } from '@/components/ui/input'

type RenameVaultDialogProps = {
  open: boolean
  onOpenChange: (open: boolean) => void
  onCreate: (note: string) => Promise<void>
}

export const RenameVaultDialog = ({
  open,
  onOpenChange,
  onCreate,
}: RenameVaultDialogProps) => {
  const [note, setNote] = useState('')

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Create a Vault</DialogTitle>
          <DialogDescription>
            This will create a new Vault. Add an optional note describing it.
          </DialogDescription>
        </DialogHeader>
        <Input
          placeholder="Add a note"
          value={note}
          onChange={(event) => setNote(event.target.value)}
        />
        <DialogFooter>
          <Button variant="outline" onClick={() => onOpenChange(false)}>
            Cancel
          </Button>
          <Button
            onClick={async () => {
              await onCreate(note)
              onOpenChange(false)
            }}
          >
            OK
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}
