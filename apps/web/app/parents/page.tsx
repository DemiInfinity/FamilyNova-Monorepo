'use client'

import Link from 'next/link'
import Logo from '../components/Logo'

export default function ParentsPage() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-navy via-teal to-indigo">
      <div className="container mx-auto px-4 py-16">
        <div className="max-w-2xl mx-auto">
          <Link href="/" className="text-white mb-8 inline-block">
            ← Back to Home
          </Link>
          
          <div className="bg-white rounded-2xl p-8 shadow-xl">
            <div className="flex justify-center mb-6">
              <Logo size="md" variant="parent" />
            </div>
            <h1 className="text-4xl font-bold text-navy mb-4">
              Parent Portal
            </h1>
            <p className="text-gray-600 mb-8">
              Monitor and protect your children's online experience
            </p>
            
            <div className="space-y-4">
              <input
                type="email"
                placeholder="Email"
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-teal focus:border-transparent"
              />
              <input
                type="password"
                placeholder="Password"
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-teal focus:border-transparent"
              />
              <button className="w-full bg-teal text-white py-3 rounded-lg font-semibold hover:bg-teal/90 transition">
                Login
              </button>
              <button className="w-full border-2 border-teal text-teal py-3 rounded-lg font-semibold hover:bg-teal/10 transition">
                Create Account
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

