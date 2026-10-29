import { useQuery } from '@apollo/client'

import { VaultFilesQuery } from './VaultFiles.graphql'

export const VaultEmptyState = ({ vaultId }: { vaultId: number }) => {
  const filesQuery = useQuery(VaultFilesQuery, { variables: { vaultId } })
  const files = filesQuery.data?.vaultFiles ?? []

  if (files.length > 0) return null

  return (
    <div className="flex min-h-[160px] w-full flex-col items-center justify-center gap-2 rounded-lg bg-muted/30 text-center">
      <p className="text-sm text-muted-foreground">No files yet</p>
      <p className="text-xs text-muted-foreground">
        Files power Memos, Vaults, and AI.
      </p>
    </div>
  )
}
