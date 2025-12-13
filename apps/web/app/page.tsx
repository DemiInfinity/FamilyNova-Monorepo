'use client'

import Link from 'next/link'
import Logo from './components/Logo'

export default function Home() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-primary-blue to-primary-purple">
      <div className="container mx-auto px-4 py-16">
        <div className="max-w-4xl mx-auto text-center">
          <div className="flex justify-center mb-6">
            <Logo size="lg" variant="kids" className="text-white" />
          </div>
          <h1 className="text-5xl font-bold text-white mb-6">
            Welcome to FamilyNova
          </h1>
          <p className="text-xl text-white/90 mb-12">
            A safe social networking platform for children to learn, connect, and grow
            in a protected environment with parent monitoring and moderation.
          </p>
          
          <div className="grid md:grid-cols-2 gap-6 mt-12">
            <Link
              href="/kids"
              className="bg-white rounded-2xl p-8 shadow-lg hover:shadow-xl transition-shadow"
            >
              <div className="text-4xl mb-4">👶</div>
              <h2 className="text-2xl font-bold text-primary-blue mb-2">For Kids</h2>
              <p className="text-gray-600">
                Safe social networking with verified friends and educational content
              </p>
            </Link>
            
            <Link
              href="/parents"
              className="bg-white rounded-2xl p-8 shadow-lg hover:shadow-xl transition-shadow"
            >
              <div className="text-4xl mb-4">👨‍👩‍👧‍👦</div>
              <h2 className="text-2xl font-bold text-navy mb-2">For Parents</h2>
              <p className="text-gray-600">
                Monitor and moderate your children's online experience
              </p>
            </Link>
          </div>

          <div className="mt-16 bg-white rounded-2xl p-8 shadow-lg">
            <h3 className="text-2xl font-bold text-gray-800 mb-4">Key Features</h3>
            <div className="grid md:grid-cols-3 gap-6 text-left">
              <div>
                <div className="text-3xl mb-2">✓</div>
                <h4 className="font-semibold mb-2">Two-Tick Verification</h4>
                <p className="text-sm text-gray-600">
                  Parent and school verification for identity assurance
                </p>
              </div>
              <div>
                <div className="text-3xl mb-2">🛡️</div>
                <h4 className="font-semibold mb-2">Parent Monitoring</h4>
                <p className="text-sm text-gray-600">
                  Real-time monitoring and moderation tools
                </p>
              </div>
              <div>
                <div className="text-3xl mb-2">👥</div>
                <h4 className="font-semibold mb-2">Parent Connections</h4>
                <p className="text-sm text-gray-600">
                  Automatic connections with parents of your child's friends
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

