'use client'

import Link from 'next/link'
import Logo from '../components/Logo'

export default function KidsPage() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-primary-blue via-primary-green to-primary-purple">
      <div className="container mx-auto px-4 py-16">
        <div className="max-w-2xl mx-auto">
          <Link href="/" className="text-white mb-8 inline-block">
            ← Back to Home
          </Link>
          
          <div className="bg-white rounded-2xl p-8 shadow-xl">
            <div className="flex justify-center mb-6">
              <Logo size="md" variant="kids" />
            </div>
            <h1 className="text-4xl font-bold text-primary-blue mb-4">
              Kids Portal
            </h1>
            <p className="text-gray-600 mb-8">
              Login or create an account to connect with your friends safely!
            </p>
            
            <div className="space-y-4">
              <input
                type="email"
                placeholder="Email"
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-blue focus:border-transparent"
              />
              <input
                type="password"
                placeholder="Password"
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-blue focus:border-transparent"
              />
              <button className="w-full bg-primary-blue text-white py-3 rounded-lg font-semibold hover:bg-primary-blue/90 transition">
                Login
              </button>
              <button className="w-full border-2 border-primary-blue text-primary-blue py-3 rounded-lg font-semibold hover:bg-primary-blue/10 transition">
                Create Account
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

