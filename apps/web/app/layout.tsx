import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'FamilyNova - Safe Social Networking for Kids',
  description: 'A safe social networking platform for children with parent monitoring and moderation',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  )
}

