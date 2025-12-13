'use client'

import Link from 'next/link'
import Navbar from '../components/Navbar'
import Footer from '../components/Footer'

export default function PricingPage() {
  return (
    <div className="min-h-screen bg-gray-50">
      <Navbar />

      <div className="container mx-auto px-4 py-16">
        <div className="max-w-6xl mx-auto">
          <div className="text-center mb-16">
            <h1 className="text-4xl md:text-5xl font-bold text-gray-900 mb-6">
              Simple, Transparent Pricing
            </h1>
            <p className="text-xl text-gray-600 max-w-2xl mx-auto">
              Choose the plan that's right for your family or school. All plans include our core safety features.
            </p>
          </div>

          {/* Family Plans */}
          <div className="mb-20">
            <h2 className="text-3xl font-bold text-gray-900 mb-8 text-center">For Families</h2>
            <div className="grid md:grid-cols-2 gap-8 max-w-4xl mx-auto">
              {/* Free Plan */}
              <div className="bg-white p-8 rounded-lg border-2 border-gray-200">
                <div className="text-center mb-6">
                  <h3 className="text-2xl font-bold text-gray-900 mb-2">Free</h3>
                  <div className="mb-4">
                    <span className="text-4xl font-bold text-gray-900">£0</span>
                    <span className="text-gray-600">/month</span>
                  </div>
                  <p className="text-gray-600 text-sm">Perfect for getting started</p>
                </div>
                <ul className="space-y-3 mb-8">
                  <li className="flex items-start">
                    <span className="text-green-500 mr-2">✓</span>
                    <span className="text-gray-700">1-2 child accounts</span>
                  </li>
                  <li className="flex items-start">
                    <span className="text-green-500 mr-2">✓</span>
                    <span className="text-gray-700">Basic monitoring & moderation</span>
                  </li>
                  <li className="flex items-start">
                    <span className="text-green-500 mr-2">✓</span>
                    <span className="text-gray-700">Two-tick verification</span>
                  </li>
                  <li className="flex items-start">
                    <span className="text-green-500 mr-2">✓</span>
                    <span className="text-gray-700">Parent connections</span>
                  </li>
                  <li className="flex items-start">
                    <span className="text-green-500 mr-2">✓</span>
                    <span className="text-gray-700">Access to educational content</span>
                  </li>
                  <li className="flex items-start">
                    <span className="text-green-500 mr-2">✓</span>
                    <span className="text-gray-700">Community support</span>
                  </li>
                </ul>
                <Link
                  href="/parents"
                  className="block w-full bg-gray-100 text-gray-900 text-center py-3 rounded-lg font-medium hover:bg-gray-200 transition-colors"
                >
                  Get Started Free
                </Link>
              </div>

              {/* Pro Plan */}
              <div className="bg-white p-8 rounded-lg border-2 border-blue-500 relative">
                <div className="absolute top-0 right-0 bg-blue-500 text-white px-4 py-1 rounded-bl-lg text-sm font-medium">
                  Most Popular
                </div>
                <div className="text-center mb-6">
                  <h3 className="text-2xl font-bold text-gray-900 mb-2">Pro Family</h3>
                  <div className="mb-2">
                    <span className="text-4xl font-bold text-gray-900">£9.99</span>
                    <span className="text-gray-600">/month</span>
                  </div>
                  <p className="text-sm text-gray-500 mb-2">or £99/year (save 17%)</p>
                  <p className="text-gray-600 text-sm">For families who want more</p>
                </div>
                <ul className="space-y-3 mb-8">
                  <li className="flex items-start">
                    <span className="text-green-500 mr-2">✓</span>
                    <span className="text-gray-700"><strong>Unlimited</strong> child accounts</span>
                  </li>
                  <li className="flex items-start">
                    <span className="text-green-500 mr-2">✓</span>
                    <span className="text-gray-700"><strong>Advanced</strong> monitoring & analytics</span>
                  </li>
                  <li className="flex items-start">
                    <span className="text-green-500 mr-2">✓</span>
                    <span className="text-gray-700">Detailed activity reports</span>
                  </li>
                  <li className="flex items-start">
                    <span className="text-green-500 mr-2">✓</span>
                    <span className="text-gray-700">Enhanced safety features</span>
                  </li>
                  <li className="flex items-start">
                    <span className="text-green-500 mr-2">✓</span>
                    <span className="text-gray-700">Extended data retention</span>
                  </li>
                  <li className="flex items-start">
                    <span className="text-green-500 mr-2">✓</span>
                    <span className="text-gray-700">Priority support</span>
                  </li>
                  <li className="flex items-start">
                    <span className="text-green-500 mr-2">✓</span>
                    <span className="text-gray-700">Early access to new features</span>
                  </li>
                  <li className="flex items-start">
                    <span className="text-green-500 mr-2">✓</span>
                    <span className="text-gray-700">Family activity dashboard</span>
                  </li>
                </ul>
                <Link
                  href="/parents"
                  className="block w-full bg-blue-600 text-white text-center py-3 rounded-lg font-medium hover:bg-blue-700 transition-colors"
                >
                  Start Pro Trial
                </Link>
              </div>
            </div>
          </div>

          {/* School Plans */}
          <div>
            <h2 className="text-3xl font-bold text-gray-900 mb-8 text-center">For Schools</h2>
            <div className="grid md:grid-cols-3 gap-8">
              {/* Free Trial */}
              <div className="bg-white p-8 rounded-lg border-2 border-gray-200">
                <div className="text-center mb-6">
                  <h3 className="text-2xl font-bold text-gray-900 mb-2">Free Trial</h3>
                  <div className="mb-4">
                    <span className="text-4xl font-bold text-gray-900">£0</span>
                    <span className="text-gray-600">/month</span>
                  </div>
                  <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-3 mb-4">
                    <p className="text-sm font-medium text-yellow-800">30-day free trial</p>
                    <p className="text-xs text-yellow-700 mt-1">Then £49/month</p>
                  </div>
                  <p className="text-gray-600 text-sm">Try all features risk-free</p>
                </div>
                <ul className="space-y-3 mb-8">
                  <li className="flex items-start">
                    <span className="text-green-500 mr-2">✓</span>
                    <span className="text-gray-700">Up to 50 students</span>
                  </li>
                  <li className="flex items-start">
                    <span className="text-green-500 mr-2">✓</span>
                    <span className="text-gray-700">Student verification</span>
                  </li>
                  <li className="flex items-start">
                    <span className="text-green-500 mr-2">✓</span>
                    <span className="text-gray-700">Educational content creation</span>
                  </li>
                  <li className="flex items-start">
                    <span className="text-green-500 mr-2">✓</span>
                    <span className="text-gray-700">Homework assignments</span>
                  </li>
                  <li className="flex items-start">
                    <span className="text-green-500 mr-2">✓</span>
                    <span className="text-gray-700">Basic analytics</span>
                  </li>
                  <li className="flex items-start">
                    <span className="text-green-500 mr-2">✓</span>
                    <span className="text-gray-700">Email support</span>
                  </li>
                </ul>
                <Link
                  href="/schools"
                  className="block w-full bg-gray-100 text-gray-900 text-center py-3 rounded-lg font-medium hover:bg-gray-200 transition-colors"
                >
                  Start Free Trial
                </Link>
              </div>

              {/* School Pro */}
              <div className="bg-white p-8 rounded-lg border-2 border-blue-500 relative">
                <div className="absolute top-0 right-0 bg-blue-500 text-white px-4 py-1 rounded-bl-lg text-sm font-medium">
                  Best Value
                </div>
                <div className="text-center mb-6">
                  <h3 className="text-2xl font-bold text-gray-900 mb-2">School Pro</h3>
                  <div className="mb-2">
                    <span className="text-4xl font-bold text-gray-900">£49</span>
                    <span className="text-gray-600">/month</span>
                  </div>
                  <p className="text-sm text-gray-500 mb-2">or £490/year (save 17%)</p>
                  <p className="text-gray-600 text-sm">For schools of all sizes</p>
                </div>
                <ul className="space-y-3 mb-8">
                  <li className="flex items-start">
                    <span className="text-green-500 mr-2">✓</span>
                    <span className="text-gray-700"><strong>Unlimited</strong> students</span>
                  </li>
                  <li className="flex items-start">
                    <span className="text-green-500 mr-2">✓</span>
                    <span className="text-gray-700">Advanced verification management</span>
                  </li>
                  <li className="flex items-start">
                    <span className="text-green-500 mr-2">✓</span>
                    <span className="text-gray-700">Unlimited educational content</span>
                  </li>
                  <li className="flex items-start">
                    <span className="text-green-500 mr-2">✓</span>
                    <span className="text-gray-700">Advanced analytics & reporting</span>
                  </li>
                  <li className="flex items-start">
                    <span className="text-green-500 mr-2">✓</span>
                    <span className="text-gray-700">Bulk student management</span>
                  </li>
                  <li className="flex items-start">
                    <span className="text-green-500 mr-2">✓</span>
                    <span className="text-gray-700">Priority support</span>
                  </li>
                  <li className="flex items-start">
                    <span className="text-green-500 mr-2">✓</span>
                    <span className="text-gray-700">Custom branding (optional)</span>
                  </li>
                </ul>
                <Link
                  href="/schools"
                  className="block w-full bg-blue-600 text-white text-center py-3 rounded-lg font-medium hover:bg-blue-700 transition-colors"
                >
                  Get Started
                </Link>
              </div>

              {/* Enterprise */}
              <div className="bg-white p-8 rounded-lg border-2 border-gray-200">
                <div className="text-center mb-6">
                  <h3 className="text-2xl font-bold text-gray-900 mb-2">Enterprise</h3>
                  <div className="mb-4">
                    <span className="text-4xl font-bold text-gray-900">Custom</span>
                  </div>
                  <p className="text-gray-600 text-sm">For districts & large organisations</p>
                </div>
                <ul className="space-y-3 mb-8">
                  <li className="flex items-start">
                    <span className="text-green-500 mr-2">✓</span>
                    <span className="text-gray-700">Multi-school management</span>
                  </li>
                  <li className="flex items-start">
                    <span className="text-green-500 mr-2">✓</span>
                    <span className="text-gray-700">Custom integrations</span>
                  </li>
                  <li className="flex items-start">
                    <span className="text-green-500 mr-2">✓</span>
                    <span className="text-gray-700">Dedicated account manager</span>
                  </li>
                  <li className="flex items-start">
                    <span className="text-green-500 mr-2">✓</span>
                    <span className="text-gray-700">Custom features & development</span>
                  </li>
                  <li className="flex items-start">
                    <span className="text-green-500 mr-2">✓</span>
                    <span className="text-gray-700">SLA guarantees</span>
                  </li>
                  <li className="flex items-start">
                    <span className="text-green-500 mr-2">✓</span>
                    <span className="text-gray-700">On-site training</span>
                  </li>
                  <li className="flex items-start">
                    <span className="text-green-500 mr-2">✓</span>
                    <span className="text-gray-700">24/7 priority support</span>
                  </li>
                </ul>
                <Link
                  href="/schools"
                  className="block w-full bg-gray-100 text-gray-900 text-center py-3 rounded-lg font-medium hover:bg-gray-200 transition-colors"
                >
                  Contact Sales
                </Link>
              </div>
            </div>
          </div>

          {/* FAQ Section */}
          <div className="mt-20 max-w-3xl mx-auto">
            <h2 className="text-3xl font-bold text-gray-900 mb-8 text-center">Frequently Asked Questions</h2>
            <div className="space-y-6">
              <div className="bg-white p-6 rounded-lg border border-gray-200">
                <h3 className="font-semibold text-gray-900 mb-2">Can I switch plans later?</h3>
                <p className="text-gray-700 text-sm">
                  Yes! You can upgrade, downgrade, or cancel your plan at any time. Changes take effect immediately.
                </p>
              </div>
              <div className="bg-white p-6 rounded-lg border border-gray-200">
                <h3 className="font-semibold text-gray-900 mb-2">What happens after the school free trial?</h3>
                <p className="text-gray-700 text-sm">
                  After 30 days, your school will automatically be moved to the School Pro plan (£49/month) unless you cancel. You can cancel anytime during the trial with no charges.
                </p>
              </div>
              <div className="bg-white p-6 rounded-lg border border-gray-200">
                <h3 className="font-semibold text-gray-900 mb-2">Is the free family plan really free forever?</h3>
                <p className="text-gray-700 text-sm">
                  Yes! The free plan includes all core safety features and will always be free. We believe every family should have access to safe social networking for their children.
                </p>
              </div>
              <div className="bg-white p-6 rounded-lg border border-gray-200">
                <h3 className="font-semibold text-gray-900 mb-2">Do you offer discounts for annual plans?</h3>
                <p className="text-gray-700 text-sm">
                  Yes! Annual plans save you 17% compared to monthly billing. Both Pro Family and School Pro offer annual options.
                </p>
              </div>
              <div className="bg-white p-6 rounded-lg border border-gray-200">
                <h3 className="font-semibold text-gray-900 mb-2">What payment methods do you accept?</h3>
                <p className="text-gray-700 text-sm">
                  We accept all major credit cards, debit cards, and direct bank transfers for annual plans. All payments are processed securely.
                </p>
              </div>
              <div className="bg-white p-6 rounded-lg border border-gray-200">
                <h3 className="font-semibold text-gray-900 mb-2">Can I get a refund?</h3>
                <p className="text-gray-700 text-sm">
                  Yes, we offer a 30-day money-back guarantee for all paid plans. If you're not satisfied, contact us for a full refund.
                </p>
              </div>
            </div>
          </div>

          {/* CTA Section */}
          <div className="mt-16 text-center">
            <h2 className="text-2xl font-bold text-gray-900 mb-4">Ready to Get Started?</h2>
            <p className="text-gray-600 mb-8">Join thousands of families and schools using FamilyNova</p>
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <Link
                href="/schools"
                className="bg-blue-600 text-white px-8 py-3 rounded-lg font-medium hover:bg-blue-700 transition-colors"
              >
                Start School Trial
              </Link>
              <Link
                href="/parents"
                className="bg-gray-100 text-gray-900 px-8 py-3 rounded-lg font-medium hover:bg-gray-200 transition-colors"
              >
                Sign Up Free
              </Link>
            </div>
          </div>
        </div>
      </div>
      <Footer />
    </div>
  )
}

