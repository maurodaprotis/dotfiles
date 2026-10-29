import { CheckCircle2 } from 'lucide-react'

import { Badge } from '@/components/ui/badge'

type LenderRowProps = {
  companyName: string
  contactEmail: string
  isVerified: boolean
  status: string
}

export const LenderRow = ({
  companyName,
  contactEmail,
  isVerified,
  status,
}: LenderRowProps) => (
  <div className="flex items-center gap-3 px-4 py-2">
    <div className="flex flex-1 flex-col">
      <span className="truncate text-sm font-medium">{companyName}</span>
      <span className="truncate text-xs text-muted-foreground">
        {contactEmail}
      </span>
    </div>
    {isVerified && <CheckCircle2 className="text-green-600" size={16} />}
    <Badge variant="outline">{status}</Badge>
  </div>
)
