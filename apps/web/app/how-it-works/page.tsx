'use client'

import Link from 'next/link'
import Navbar from '../components/Navbar'
import Footer from '../components/Footer'

export default function HowItWorksPage() {
  return (
    <div className="min-h-screen bg-gray-50">
      <Navbar />

      <div className="container mx-auto px-4 py-16">
        <div className="max-w-4xl mx-auto">
          <h1 className="text-4xl md:text-5xl font-bold text-gray-900 mb-6">
            How FamilyNova Works
          </h1>
          <p className="text-xl text-gray-600 mb-12">
            A simple, secure process designed for families and schools.
          </p>

          {/* Step-by-Step Process */}
          <div className="space-y-8 mb-16">
            {/* Step 1 */}
            <div className="bg-white p-8 rounded-lg border border-gray-200">
              <div className="flex items-start space-x-6">
                <div className="flex-shrink-0">
                  <div className="w-16 h-16 bg-blue-600 text-white rounded-full flex items-center justify-center text-2xl font-bold">
                    1
                  </div>
                </div>
                <div>
                  <h2 className="text-2xl font-bold text-gray-900 mb-3">Parent Creates Account</h2>
                  <p className="text-gray-700 mb-4">
                    Parents sign up for FamilyNova and create accounts for their children. This ensures parental oversight from the very beginning.
                  </p>
                  <ul className="list-disc list-inside space-y-2 text-gray-700 ml-4">
                    <li>Download the Parent app on iOS or Android</li>
                    <li>Create your parent account</li>
                    <li>Add your children's information</li>
                    <li>Set up monitoring preferences based on your child's age</li>
                  </ul>
                </div>
              </div>
            </div>

            {/* Step 2 */}
            <div className="bg-white p-8 rounded-lg border border-gray-200">
              <div className="flex items-start space-x-6">
                <div className="flex-shrink-0">
                  <div className="w-16 h-16 bg-blue-600 text-white rounded-full flex items-center justify-center text-2xl font-bold">
                    2
                  </div>
                </div>
                <div>
                  <h2 className="text-2xl font-bold text-gray-900 mb-3">School Verification</h2>
                  <p className="text-gray-700 mb-4">
                    Schools register on the web portal and generate unique verification codes for their students.
                  </p>
                  <ul className="list-disc list-inside space-y-2 text-gray-700 ml-4">
                    <li>Schools sign up on the web portal</li>
                    <li>Generate unique verification codes for each student</li>
                    <li>Distribute codes to students (via email, printed, or in-person)</li>
                    <li>Children enter the code in their app to complete verification</li>
                  </ul>
                </div>
              </div>
            </div>

            {/* Step 3 */}
            <div className="bg-white p-8 rounded-lg border border-gray-200">
              <div className="flex items-start space-x-6">
                <div className="flex-shrink-0">
                  <div className="w-16 h-16 bg-blue-600 text-white rounded-full flex items-center justify-center text-2xl font-bold">
                    3
                  </div>
                </div>
                <div>
                  <h2 className="text-2xl font-bold text-gray-900 mb-3">Child Completes Verification</h2>
                  <p className="text-gray-700 mb-4">
                    Children download the Kids app and enter their school verification code to complete the two-tick verification process.
                  </p>
                  <ul className="list-disc list-inside space-y-2 text-gray-700 ml-4">
                    <li>Download the Kids app on iOS or Android</li>
                    <li>Log in with credentials created by parent</li>
                    <li>Enter the 6-digit verification code from school</li>
                    <li>Account is now fully verified (parent ✓ + school ✓)</li>
                  </ul>
                </div>
              </div>
            </div>

            {/* Step 4 */}
            <div className="bg-white p-8 rounded-lg border border-gray-200">
              <div className="flex items-start space-x-6">
                <div className="flex-shrink-0">
                  <div className="w-16 h-16 bg-blue-600 text-white rounded-full flex items-center justify-center text-2xl font-bold">
                    4
                  </div>
                </div>
                <div>
                  <h2 className="text-2xl font-bold text-gray-900 mb-3">Safe Connections & Learning</h2>
                  <p className="text-gray-700 mb-4">
                    Once verified, children can connect with friends, learn, and share—all under parent supervision.
                  </p>
                  <ul className="list-disc list-inside space-y-2 text-gray-700 ml-4">
                    <li>Connect with other verified friends</li>
                    <li>Send messages (monitored by parents based on age)</li>
                    <li>Share posts (with parent approval for younger children)</li>
                    <li>Complete homework from school</li>
                    <li>Learn about online safety</li>
                  </ul>
                </div>
              </div>
            </div>
          </div>

          {/* Monitoring Levels */}
          <div className="bg-white p-8 rounded-lg border border-gray-200 mb-12">
            <h2 className="text-2xl font-bold text-gray-900 mb-6">Age-Based Monitoring</h2>
            <div className="grid md:grid-cols-2 gap-6">
              <div className="p-6 bg-blue-50 rounded-lg">
                <h3 className="text-xl font-semibold text-gray-900 mb-3">Full Monitoring (Under 13)</h3>
                <ul className="list-disc list-inside space-y-2 text-gray-700">
                  <li>All messages require parent approval</li>
                  <li>All posts require parent approval</li>
                  <li>Complete visibility into all activity</li>
                  <li>Profile changes require approval</li>
                </ul>
              </div>
              <div className="p-6 bg-green-50 rounded-lg">
                <h3 className="text-xl font-semibold text-gray-900 mb-3">Partial Monitoring (13+)</h3>
                <ul className="list-disc list-inside space-y-2 text-gray-700">
                  <li>Only flagged messages reviewed</li>
                  <li>Posts go live immediately</li>
                  <li>Parents can view activity but don't block</li>
                  <li>More independence with safety net</li>
                </ul>
              </div>
            </div>
          </div>

          {/* CTA */}
          <div className="text-center">
            <Link
              href="/schools"
              className="bg-blue-600 text-white px-8 py-3 rounded-lg font-medium hover:bg-blue-700 transition-colors inline-block"
            >
              Get Started
            </Link>
          </div>
        </div>
      </div>
      <Footer />
    </div>
  )
}

