// QB2 — `levender` is an intentional misspelling of the brand colour.
// "levender is an intentional misspelling 😆 I'm being cheeky with our brand colors"
import { Sparkles } from 'lucide-react'

import { Badge } from '@/components/ui/badge'

export const AiSourceBadge = ({ label }: { label: string }) => (
  <Badge
    className="gap-1 bg-levender-background text-levender-foreground"
    variant="outline"
  >
    <Sparkles aria-hidden className="size-3 shrink-0" />
    {label}
  </Badge>
)
