'use client'

import Link from 'next/link'
import Navbar from '../components/Navbar'
import Footer from '../components/Footer'

export default function KidsPage() {
  return (
    <div className="min-h-screen bg-gray-50">
      <Navbar />
      <div className="container mx-auto px-4 py-20">
        <div className="max-w-2xl mx-auto text-center">
          <div className="text-6xl mb-6">📱</div>
          <h1 className="text-4xl font-bold text-gray-900 mb-4">
            Kids App Available on Mobile
          </h1>
          <p className="text-lg text-gray-600 mb-8">
            The FamilyNova Kids app is available on iOS and Android. Please download it from the App Store or Google Play Store.
          </p>
          <div className="bg-white p-8 rounded-lg border border-gray-200 mb-8">
            <h2 className="text-xl font-semibold text-gray-900 mb-4">Download the App</h2>
            <div className="space-y-4">
              <div className="flex items-center justify-center space-x-4">
                <div className="text-2xl">🍎</div>
                <div>
                  <div className="font-medium text-gray-900">iOS App</div>
                  <div className="text-sm text-gray-500">Coming soon to App Store</div>
                </div>
              </div>
              <div className="flex items-center justify-center space-x-4">
                <div className="text-2xl">🤖</div>
                <div>
                  <div className="font-medium text-gray-900">Android App</div>
                  <div className="text-sm text-gray-500">Coming soon to Google Play</div>
                </div>
              </div>
            </div>
          </div>
          <Link
            href="/"
            className="text-blue-600 hover:text-blue-700 font-medium"
          >
            ← Back to Home
          </Link>
        </div>
      </div>
      <Footer />
    </div>
  )
}
