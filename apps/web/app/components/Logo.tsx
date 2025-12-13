'use client'

interface LogoProps {
  size?: 'sm' | 'md' | 'lg'
  variant?: 'kids' | 'parent'
  className?: string
}

export default function Logo({ size = 'md', variant = 'kids', className = '' }: LogoProps) {
  const sizeClasses = {
    sm: 'w-16 h-16',
    md: 'w-24 h-24',
    lg: 'w-32 h-32'
  }
  
  const colorClasses = variant === 'kids' 
    ? 'text-primary-blue' 
    : 'text-navy'
  
  return (
    <div className={`${sizeClasses[size]} ${colorClasses} ${className}`}>
      {/* Using emoji as placeholder - TODO: Replace with actual FamilyNova logo SVG/image */}
      <div className="text-6xl flex items-center justify-center h-full">
        {variant === 'kids' ? '👥' : '🛡️'}
      </div>
      {/* TODO: Replace with: <img src="/logo.svg" alt="FamilyNova" /> */}
    </div>
  )
}

