import { UserPlus } from 'lucide-react'

import { Button } from '@/components/ui/button'

type Member = { id: number; name: string; role: string }

export const TeamTable = ({
  members,
  onInvite,
}: {
  members: Array<Member>
  onInvite: () => void
}) => (
  <section className="rounded-md border border-border">
    <header className="flex items-center justify-between border-b border-border px-4 py-3">
      <h2 className="text-sm font-medium">Team Members</h2>
      <Button size="sm" variant="outline" onClick={onInvite}>
        <UserPlus className="w-4 h-4" />
        Invite...
      </Button>
    </header>
    <ul>
      {members.map((member) => (
        <li
          key={member.id}
          className="flex items-center justify-between px-4 py-2 text-sm"
        >
          <span>{member.name}</span>
          <span className="text-muted-foreground">{member.role}</span>
        </li>
      ))}
    </ul>
  </section>
)
