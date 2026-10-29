import { AnimatePresence, motion } from 'motion/react'

type StepNavProps = {
  step: number
  children: React.ReactNode
}

export const StepNav = ({ step, children }: StepNavProps) => (
  <div className="relative overflow-hidden">
    <AnimatePresence mode="wait">
      <motion.div
        key={step}
        animate={{ opacity: 1, x: 0 }}
        exit={{ opacity: 0, x: -80 }}
        initial={{ opacity: 0, x: 80 }}
        transition={{ duration: 0.28 }}
      >
        {children}
      </motion.div>
    </AnimatePresence>
  </div>
)
