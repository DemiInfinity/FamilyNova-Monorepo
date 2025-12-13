'use client'

import Link from 'next/link'
import Navbar from '../components/Navbar'
import Footer from '../components/Footer'

export default function TermsPage() {
  return (
    <div className="min-h-screen bg-gray-50">
      <Navbar />

      <div className="container mx-auto px-4 py-16">
        <div className="max-w-4xl mx-auto">
          <h1 className="text-4xl md:text-5xl font-bold text-gray-900 mb-6">
            Terms of Service
          </h1>
          <p className="text-lg text-gray-600 mb-4">
            Last updated: {new Date().toLocaleDateString('en-GB', { year: 'numeric', month: 'long', day: 'numeric' })}
          </p>
          <p className="text-lg text-gray-600 mb-12">
            Please read these Terms of Service carefully before using FamilyNova. By using our platform, you agree to these terms.
          </p>

          <div className="space-y-8">
            <section className="bg-white p-8 rounded-lg border border-gray-200">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">1. Acceptance of Terms</h2>
              <p className="text-gray-700">
                By accessing or using FamilyNova, you agree to be bound by these Terms of Service and our Privacy Policy. If you do not agree, please do not use our platform.
              </p>
            </section>

            <section className="bg-white p-8 rounded-lg border border-gray-200">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">2. Description of Service</h2>
              <p className="text-gray-700 mb-4">
                FamilyNova is a safe social networking platform designed for children, with parent monitoring and school verification. The platform includes:
              </p>
              <ul className="list-disc list-inside space-y-2 text-gray-700 ml-4">
                <li>Social networking features for verified children</li>
                <li>Parent monitoring and moderation tools</li>
                <li>School verification and educational content delivery</li>
                <li>Messaging, news feed, and friend connections</li>
              </ul>
            </section>

            <section className="bg-white p-8 rounded-lg border border-gray-200">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">3. Account Requirements</h2>
              <div className="space-y-4 text-gray-700">
                <div>
                  <h3 className="font-semibold text-gray-900 mb-2">For Children:</h3>
                  <ul className="list-disc list-inside space-y-1 ml-4">
                    <li>Must be between 8 and 16 years old</li>
                    <li>Account must be created by a parent or legal guardian</li>
                    <li>Must complete two-tick verification (parent + school)</li>
                    <li>Must follow all platform rules and guidelines</li>
                  </ul>
                </div>
                <div>
                  <h3 className="font-semibold text-gray-900 mb-2">For Parents:</h3>
                  <ul className="list-disc list-inside space-y-1 ml-4">
                    <li>Must be 18 years or older</li>
                    <li>Must be the parent or legal guardian of children on the platform</li>
                    <li>Responsible for monitoring and moderating their children's activity</li>
                    <li>Must provide accurate information</li>
                  </ul>
                </div>
                <div>
                  <h3 className="font-semibold text-gray-900 mb-2">For Schools:</h3>
                  <ul className="list-disc list-inside space-y-1 ml-4">
                    <li>Must be a registered educational institution in the UK</li>
                    <li>Responsible for verifying student identities</li>
                    <li>Must provide accurate school information</li>
                  </ul>
                </div>
              </div>
            </section>

            <section className="bg-white p-8 rounded-lg border border-gray-200">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">4. User Conduct</h2>
              <div className="space-y-4 text-gray-700">
                <p>Users agree not to:</p>
                <ul className="list-disc list-inside space-y-2 ml-4">
                  <li>Post, share, or send harmful, abusive, or inappropriate content</li>
                  <li>Engage in bullying, harassment, or hate speech</li>
                  <li>Impersonate others or create fake accounts</li>
                  <li>Share personal information (address, phone number, etc.)</li>
                  <li>Attempt to bypass safety features or monitoring</li>
                  <li>Use the platform for illegal activities</li>
                  <li>Share verification codes with unauthorised users</li>
                  <li>Interfere with the platform's security or functionality</li>
                </ul>
              </div>
            </section>

            <section className="bg-white p-8 rounded-lg border border-gray-200">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">5. Parent Responsibilities</h2>
              <div className="space-y-4 text-gray-700">
                <p>Parents are responsible for:</p>
                <ul className="list-disc list-inside space-y-2 ml-4">
                  <li>Creating and managing their children's accounts</li>
                  <li>Monitoring their children's activity on the platform</li>
                  <li>Moderating messages and posts as appropriate for their child's age</li>
                  <li>Ensuring their children follow platform rules</li>
                  <li>Maintaining the security of their parent account</li>
                  <li>Reporting any safety concerns to FamilyNova</li>
                </ul>
              </div>
            </section>

            <section className="bg-white p-8 rounded-lg border border-gray-200">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">6. School Responsibilities</h2>
              <div className="space-y-4 text-gray-700">
                <p>Schools are responsible for:</p>
                <ul className="list-disc list-inside space-y-2 ml-4">
                  <li>Verifying student identities accurately</li>
                  <li>Generating and distributing verification codes securely</li>
                  <li>Creating appropriate educational content</li>
                  <li>Maintaining the security of their school account</li>
                  <li>Reporting any misuse of verification codes</li>
                </ul>
              </div>
            </section>

            <section className="bg-white p-8 rounded-lg border border-gray-200">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">7. Content Ownership</h2>
              <div className="space-y-4 text-gray-700">
                <p>
                  Users retain ownership of content they create and share on FamilyNova. However, by using the platform, users grant FamilyNova a license to:
                </p>
                <ul className="list-disc list-inside space-y-2 ml-4">
                  <li>Display and distribute content within the platform</li>
                  <li>Moderate and review content for safety</li>
                  <li>Store content as necessary for platform operation</li>
                </ul>
                <p className="mt-4">
                  FamilyNova does not claim ownership of user-generated content.
                </p>
              </div>
            </section>

            <section className="bg-white p-8 rounded-lg border border-gray-200">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">8. Account Termination</h2>
              <div className="space-y-4 text-gray-700">
                <p>We reserve the right to suspend or terminate accounts that:</p>
                <ul className="list-disc list-inside space-y-2 ml-4">
                  <li>Violate these Terms of Service</li>
                  <li>Engage in harmful or illegal behaviour</li>
                  <li>Attempt to bypass safety features</li>
                  <li>Provide false information during verification</li>
                </ul>
                <p className="mt-4">
                  Users may also delete their accounts at any time through account settings.
                </p>
              </div>
            </section>

            <section className="bg-white p-8 rounded-lg border border-gray-200">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">9. Limitation of Liability</h2>
              <div className="space-y-4 text-gray-700">
                <p>
                  FamilyNova provides the platform "as is" and does not guarantee uninterrupted or error-free service. We are not liable for:
                </p>
                <ul className="list-disc list-inside space-y-2 ml-4">
                  <li>Any indirect, incidental, or consequential damages</li>
                  <li>Loss of data or content</li>
                  <li>Unauthorised access to accounts (if users maintain account security)</li>
                </ul>
              </div>
            </section>

            <section className="bg-white p-8 rounded-lg border border-gray-200">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">10. Changes to Terms</h2>
              <p className="text-gray-700">
                We may update these Terms of Service from time to time. Users will be notified of significant changes. Continued use of the platform after changes constitutes acceptance of the new terms.
              </p>
            </section>

            <section className="bg-white p-8 rounded-lg border border-gray-200">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">11. Governing Law</h2>
              <p className="text-gray-700">
                These Terms of Service are governed by the laws of England and Wales. Any disputes will be subject to the exclusive jurisdiction of the courts of England and Wales.
              </p>
            </section>

            <section className="bg-white p-8 rounded-lg border border-gray-200">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">12. Contact</h2>
              <div className="space-y-4 text-gray-700">
                <p>For questions about these Terms of Service, please contact:</p>
                <ul className="list-none space-y-2 ml-4">
                  <li><strong>Email:</strong> legal@familynova.co.uk</li>
                  <li><strong>Address:</strong> FamilyNova, United Kingdom</li>
                </ul>
              </div>
            </section>
          </div>

          <div className="mt-12 text-center">
            <Link
              href="/"
              className="text-blue-600 hover:text-blue-700 font-medium"
            >
              ← Back to Home
            </Link>
          </div>
        </div>
      </div>
      <Footer />
    </div>
  )
}

