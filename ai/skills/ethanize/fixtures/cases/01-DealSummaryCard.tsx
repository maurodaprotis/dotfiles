import { Building2 } from 'lucide-react'

import { Card, CardContent } from '@/components/ui/card'

type DealSummaryCardProps = {
  name: string
  sponsorName: string
  loanAmount: number
  onOpen: () => void
}

export const DealSummaryCard = ({
  name,
  sponsorName,
  loanAmount,
  onOpen,
}: DealSummaryCardProps) => (
  <Card
    className="cursor-pointer rounded-lg border shadow-sm hover:shadow-md"
    onClick={onOpen}
  >
    <CardContent className="flex items-center gap-3 p-4">
      <Building2 className="text-gray-500" size={20} />
      <div className="flex flex-col">
        <span className="text-sm font-medium">{name}</span>
        <span className="text-xs text-foreground/60">{sponsorName}</span>
      </div>
      <span className="ml-auto text-sm font-medium">
        ${loanAmount.toLocaleString()}
      </span>
    </CardContent>
  </Card>
)
