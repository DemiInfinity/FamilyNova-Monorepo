import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'FamilyNova - Safe Social Media for Kids | Parent-Monitored & School-Verified',
  description: 'The only social platform with two-tick verification (parent + school), real-time parental monitoring, and educational content. Safe social networking designed for kids, trusted by parents, verified by schools. Built in the UK.',
  keywords: 'safe social media for kids UK, parent monitored social media, kids social network, child safety online UK, school verified social media, GDPR compliant, cyberbullying prevention UK, UK children social media',
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

