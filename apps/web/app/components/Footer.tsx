'use client'

import Link from 'next/link'
import Logo from './Logo'

export default function Footer() {
  return (
    <footer className="bg-white border-t border-gray-200 py-12">
      <div className="container mx-auto px-4">
        <div className="max-w-4xl mx-auto">
          <div className="grid md:grid-cols-4 gap-8 mb-8">
            <div>
              <div className="flex items-center space-x-2 mb-4">
                <Logo size="sm" variant="kids" />
                <span className="text-lg font-bold text-gray-900">FamilyNova</span>
              </div>
              <p className="text-sm text-gray-600">
                Safe social networking for kids, monitored by parents, verified by schools.
              </p>
            </div>
            <div>
              <h4 className="font-semibold text-gray-900 mb-4">Product</h4>
              <ul className="space-y-2 text-sm text-gray-600">
                <li><Link href="/features" className="hover:text-gray-900">Features</Link></li>
                <li><Link href="/how-it-works" className="hover:text-gray-900">How It Works</Link></li>
                <li><Link href="/research" className="hover:text-gray-900">Research</Link></li>
              </ul>
            </div>
            <div>
              <h4 className="font-semibold text-gray-900 mb-4">For Schools</h4>
              <ul className="space-y-2 text-sm text-gray-600">
                <li><Link href="/schools" className="hover:text-gray-900">School Portal</Link></li>
                <li><Link href="/schools/dashboard" className="hover:text-gray-900">Dashboard</Link></li>
              </ul>
            </div>
            <div>
              <h4 className="font-semibold text-gray-900 mb-4">Legal & Safety</h4>
              <ul className="space-y-2 text-sm text-gray-600">
                <li><Link href="/privacy" className="hover:text-gray-900">Privacy Policy</Link></li>
                <li><Link href="/safety" className="hover:text-gray-900">Safety & Security</Link></li>
                <li><Link href="/terms" className="hover:text-gray-900">Terms of Service</Link></li>
                <li><Link href="/gdpr" className="hover:text-gray-900">GDPR & UK GDPR</Link></li>
              </ul>
            </div>
          </div>
          <div className="pt-8 border-t border-gray-200 text-center text-sm text-gray-500">
            <p>&copy; 2024 FamilyNova. All rights reserved.</p>
            <p className="mt-2">Built in the United Kingdom • GDPR & UK GDPR Compliant</p>
          </div>
        </div>
      </div>
    </footer>
  )
}

