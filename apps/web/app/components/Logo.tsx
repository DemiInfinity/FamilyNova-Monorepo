'use client'

import Image from 'next/image'

interface LogoProps {
  size?: 'sm' | 'md' | 'lg' | 'xl'
  variant?: 'kids' | 'parent'
  className?: string
}

export default function Logo({ size = 'md', variant = 'kids', className = '' }: LogoProps) {
  const sizeClasses = {
    sm: 'w-24 h-24',
    md: 'w-32 h-32',
    lg: 'w-48 h-48',
    xl: 'w-64 h-64'
  }
  
  return (
    <div className={`${sizeClasses[size]} ${className} relative`}>
      <Image
        src="/logo.png"
        alt="FamilyNova Logo"
        fill
        className="object-contain"
        priority
      />
    </div>
  )
}

