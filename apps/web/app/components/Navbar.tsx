'use client'

import Link from 'next/link'
import Logo from './Logo'
import { useState } from 'react'

export default function Navbar() {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false)

  return (
    <nav className="bg-white border-b border-gray-200 sticky top-0 z-50">
      <div className="container mx-auto px-4">
        <div className="flex items-center justify-between h-16">
          {/* Logo */}
          <Link href="/" className="flex items-center space-x-3">
            <Logo size="sm" variant="kids" />
            <span className="text-xl font-bold text-gray-900">FamilyNova</span>
          </Link>

          {/* Desktop Navigation */}
          <div className="hidden md:flex items-center space-x-8">
            <Link href="/features" className="text-gray-700 hover:text-gray-900 transition-colors">
              Features
            </Link>
            <Link href="/how-it-works" className="text-gray-700 hover:text-gray-900 transition-colors">
              How It Works
            </Link>
            <Link href="/pricing" className="text-gray-700 hover:text-gray-900 transition-colors">
              Pricing
            </Link>
            <Link href="/research" className="text-gray-700 hover:text-gray-900 transition-colors">
              Research
            </Link>
            <Link 
              href="/schools" 
              className="bg-blue-600 text-white px-6 py-2 rounded-full hover:bg-blue-700 transition-colors font-medium"
            >
              School Portal
            </Link>
          </div>

          {/* Mobile Menu Button */}
          <button
            onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
            className="md:hidden p-2 rounded-md text-gray-700 hover:bg-gray-100"
          >
            <svg className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              {mobileMenuOpen ? (
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
              ) : (
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
              )}
            </svg>
          </button>
        </div>

        {/* Mobile Menu */}
        {mobileMenuOpen && (
          <div className="md:hidden py-4 border-t border-gray-200">
            <Link href="/features" className="block py-2 text-gray-700 hover:text-gray-900">
              Features
            </Link>
            <Link href="/how-it-works" className="block py-2 text-gray-700 hover:text-gray-900">
              How It Works
            </Link>
            <Link href="/pricing" className="block py-2 text-gray-700 hover:text-gray-900">
              Pricing
            </Link>
            <Link href="/research" className="block py-2 text-gray-700 hover:text-gray-900">
              Research
            </Link>
            <Link 
              href="/schools" 
              className="block mt-4 bg-blue-600 text-white px-6 py-2 rounded-full text-center hover:bg-blue-700 transition-colors font-medium"
            >
              School Portal
            </Link>
          </div>
        )}
      </div>
    </nav>
  )
}

