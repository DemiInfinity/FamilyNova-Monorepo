'use client'

import Link from 'next/link'
import Navbar from './components/Navbar'
import Footer from './components/Footer'

export default function Home() {
  return (
    <div className="min-h-screen bg-gray-50">
      <Navbar />

      {/* Hero Section - Simple and Clean */}
      <section className="bg-white border-b border-gray-200">
        <div className="container mx-auto px-4 py-20 md:py-32">
          <div className="max-w-3xl mx-auto text-center">
            <h1 className="text-5xl md:text-6xl font-bold text-gray-900 mb-6 leading-tight">
              Safe Social Media for Kids
            </h1>
            <p className="text-xl text-gray-600 mb-8 max-w-2xl mx-auto">
              Parent-monitored, school-verified social networking designed to keep kids safe while they learn and connect. Built in the UK, trusted by families.
            </p>
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <Link
                href="/schools"
                className="bg-blue-600 text-white px-8 py-3 rounded-lg font-medium hover:bg-blue-700 transition-colors"
              >
                Schools Sign Up
              </Link>
              <Link
                href="#how-it-works"
                className="bg-gray-100 text-gray-900 px-8 py-3 rounded-lg font-medium hover:bg-gray-200 transition-colors"
              >
                Learn More
              </Link>
            </div>
            <p className="mt-6 text-sm text-gray-500">
              Available on iOS and Android • Free for families • GDPR & UK GDPR Compliant
            </p>
          </div>
        </div>
      </section>

      {/* Features Section - Clean Grid */}
      <section id="features" className="py-20 bg-white">
        <div className="container mx-auto px-4">
          <div className="max-w-4xl mx-auto">
            <h2 className="text-3xl md:text-4xl font-bold text-gray-900 mb-12 text-center">
              How FamilyNova Works
            </h2>
            
            <div className="grid md:grid-cols-3 gap-8">
              <div className="p-6">
                <div className="text-3xl mb-4">👨‍👩‍👧‍👦</div>
                <h3 className="text-xl font-semibold text-gray-900 mb-2">Parent Verification</h3>
                <p className="text-gray-600">
                  Parents create and verify their child's account, ensuring oversight from day one.
                </p>
              </div>
              
              <div className="p-6">
                <div className="text-3xl mb-4">🏫</div>
                <h3 className="text-xl font-semibold text-gray-900 mb-2">School Verification</h3>
                <p className="text-gray-600">
                  Schools provide verification codes, completing the two-tick identity system.
                </p>
              </div>
              
              <div className="p-6">
                <div className="text-3xl mb-4">🛡️</div>
                <h3 className="text-xl font-semibold text-gray-900 mb-2">Safe Connections</h3>
                <p className="text-gray-600">
                  Kids connect with verified friends while parents monitor and schools provide educational content.
                </p>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Key Features - Simple List */}
      <section id="how-it-works" className="py-20 bg-gray-50">
        <div className="container mx-auto px-4">
          <div className="max-w-3xl mx-auto">
            <h2 className="text-3xl md:text-4xl font-bold text-gray-900 mb-12 text-center">
              Key Features
            </h2>
            
            <div className="space-y-6">
              <div className="bg-white p-6 rounded-lg border border-gray-200">
                <h3 className="text-lg font-semibold text-gray-900 mb-2">Two-Tick Verification</h3>
                <p className="text-gray-600">
                  Every child is verified by both their parent and school, ensuring complete identity assurance and preventing fake accounts.
                </p>
              </div>
              
              <div className="bg-white p-6 rounded-lg border border-gray-200">
                <h3 className="text-lg font-semibold text-gray-900 mb-2">Parent Monitoring</h3>
                <p className="text-gray-600">
                  Real-time visibility into your child's messages, posts, and connections. Age-based monitoring (full for under 13, partial for 13+).
                </p>
              </div>
              
              <div className="bg-white p-6 rounded-lg border border-gray-200">
                <h3 className="text-lg font-semibold text-gray-900 mb-2">School Integration</h3>
                <p className="text-gray-600">
                  Schools can create educational content, assign homework, and verify students—all integrated into the social platform.
                </p>
              </div>
              
              <div className="bg-white p-6 rounded-lg border border-gray-200">
                <h3 className="text-lg font-semibold text-gray-900 mb-2">Parent Connections</h3>
                <p className="text-gray-600">
                  Automatically connect with other parents when your children become friends, creating a community safety net.
                </p>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Research Section - Clean Stats */}
      <section id="research" className="py-20 bg-white">
        <div className="container mx-auto px-4">
          <div className="max-w-4xl mx-auto">
            <h2 className="text-3xl md:text-4xl font-bold text-gray-900 mb-12 text-center">
              Why FamilyNova
            </h2>
            
            <div className="grid md:grid-cols-2 gap-8 mb-12">
              <div className="p-6 bg-gray-50 rounded-lg">
                <div className="text-4xl font-bold text-blue-600 mb-2">87%</div>
                <p className="text-gray-700">
                  of UK parents want better tools to monitor and guide their children's social media use.
                </p>
              </div>
              
              <div className="p-6 bg-gray-50 rounded-lg">
                <div className="text-4xl font-bold text-blue-600 mb-2">92%</div>
                <p className="text-gray-700">
                  of UK school administrators support identity verification systems for student safety.
                </p>
              </div>
            </div>

            <div className="bg-gray-50 p-8 rounded-lg border border-gray-200">
              <h3 className="text-xl font-semibold text-gray-900 mb-4">The Problem</h3>
              <p className="text-gray-700 mb-4">
                Over half of UK children have experienced cyberbullying. Traditional social media platforms lack effective moderation and verification systems for young users.
              </p>
              <h3 className="text-xl font-semibold text-gray-900 mb-4 mt-6">Our Solution</h3>
              <p className="text-gray-700">
                FamilyNova combines parent monitoring, school verification, and educational content in one platform. Every interaction is supervised, every identity is verified, and every child is protected.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* App Download Section */}
      <section className="py-20 bg-gray-50">
        <div className="container mx-auto px-4">
          <div className="max-w-3xl mx-auto text-center">
            <h2 className="text-3xl md:text-4xl font-bold text-gray-900 mb-6">
              Download the Apps
            </h2>
            <p className="text-lg text-gray-600 mb-8">
              FamilyNova is available on iOS and Android. Parents and kids use our mobile apps, while schools access the web portal.
            </p>
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <div className="bg-white p-6 rounded-lg border border-gray-200">
                <div className="text-2xl mb-2">📱</div>
                <h3 className="font-semibold text-gray-900 mb-2">Kids App</h3>
                <p className="text-sm text-gray-600 mb-4">Available on iOS & Android</p>
                <div className="text-xs text-gray-500">Coming soon to app stores</div>
              </div>
              <div className="bg-white p-6 rounded-lg border border-gray-200">
                <div className="text-2xl mb-2">👨‍👩‍👧‍👦</div>
                <h3 className="font-semibold text-gray-900 mb-2">Parent App</h3>
                <p className="text-sm text-gray-600 mb-4">Available on iOS & Android</p>
                <div className="text-xs text-gray-500">Coming soon to app stores</div>
              </div>
              <div className="bg-white p-6 rounded-lg border border-gray-200">
                <div className="text-2xl mb-2">🏫</div>
                <h3 className="font-semibold text-gray-900 mb-2">School Portal</h3>
                <p className="text-sm text-gray-600 mb-4">Web-based dashboard</p>
                <Link 
                  href="/schools"
                  className="inline-block mt-2 bg-blue-600 text-white px-4 py-2 rounded-lg text-sm hover:bg-blue-700 transition-colors"
                >
                  Access Portal
                </Link>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* CTA Section - Simple */}
      <section className="py-20 bg-white border-t border-gray-200">
        <div className="container mx-auto px-4">
          <div className="max-w-2xl mx-auto text-center">
            <h2 className="text-3xl md:text-4xl font-bold text-gray-900 mb-6">
              Ready to Get Started?
            </h2>
            <p className="text-lg text-gray-600 mb-8">
              Schools can sign up now. Parents and kids can download the mobile apps.
            </p>
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <Link
                href="/schools"
                className="bg-blue-600 text-white px-8 py-3 rounded-lg font-medium hover:bg-blue-700 transition-colors"
              >
                School Portal
              </Link>
            </div>
          </div>
        </div>
      </section>

      <Footer />
    </div>
  )
}
