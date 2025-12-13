'use client'

import Link from 'next/link'
import Navbar from '../components/Navbar'
import Footer from '../components/Footer'

export default function PrivacyPage() {
  return (
    <div className="min-h-screen bg-gray-50">
      <Navbar />

      <div className="container mx-auto px-4 py-16">
        <div className="max-w-4xl mx-auto">
          <h1 className="text-4xl md:text-5xl font-bold text-gray-900 mb-6">
            Privacy Policy
          </h1>
          <p className="text-lg text-gray-600 mb-4">
            Last updated: {new Date().toLocaleDateString('en-GB', { year: 'numeric', month: 'long', day: 'numeric' })}
          </p>
          <p className="text-lg text-gray-600 mb-12">
            FamilyNova is committed to protecting your privacy and the privacy of children using our platform. This policy explains how we collect, use, and protect personal information in compliance with GDPR and UK GDPR.
          </p>

          <div className="space-y-8">
            <section className="bg-white p-8 rounded-lg border border-gray-200">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">1. Information We Collect</h2>
              <div className="space-y-4 text-gray-700">
                <div>
                  <h3 className="font-semibold text-gray-900 mb-2">For Children's Accounts:</h3>
                  <ul className="list-disc list-inside space-y-1 ml-4">
                    <li>Display name, email address, and password</li>
                    <li>School information and grade</li>
                    <li>Date of birth (to determine monitoring level)</li>
                    <li>Profile information and preferences</li>
                    <li>Messages, posts, and content shared on the platform</li>
                    <li>Friend connections and interactions</li>
                  </ul>
                </div>
                <div>
                  <h3 className="font-semibold text-gray-900 mb-2">For Parent Accounts:</h3>
                  <ul className="list-disc list-inside space-y-1 ml-4">
                    <li>Name, email address, and password</li>
                    <li>Children's account information (as account creators)</li>
                    <li>Monitoring and moderation activity</li>
                    <li>Parent-to-parent communication</li>
                  </ul>
                </div>
                <div>
                  <h3 className="font-semibold text-gray-900 mb-2">For School Accounts:</h3>
                  <ul className="list-disc list-inside space-y-1 ml-4">
                    <li>School name, email address, and password</li>
                    <li>Contact information (phone, website)</li>
                    <li>Educational content created</li>
                    <li>Student verification codes generated</li>
                  </ul>
                </div>
              </div>
            </section>

            <section className="bg-white p-8 rounded-lg border border-gray-200">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">2. How We Use Your Information</h2>
              <div className="space-y-4 text-gray-700">
                <p>We use the information we collect to:</p>
                <ul className="list-disc list-inside space-y-2 ml-4">
                  <li>Provide and maintain the FamilyNova platform</li>
                  <li>Verify user identities through our two-tick verification system</li>
                  <li>Enable parent monitoring and moderation features</li>
                  <li>Facilitate safe communication between verified users</li>
                  <li>Deliver educational content from schools</li>
                  <li>Ensure platform safety and prevent abuse</li>
                  <li>Comply with legal obligations under GDPR and UK GDPR</li>
                </ul>
              </div>
            </section>

            <section className="bg-white p-8 rounded-lg border border-gray-200">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">3. Data Protection & GDPR Compliance</h2>
              <div className="space-y-4 text-gray-700">
                <p>
                  FamilyNova is fully compliant with the General Data Protection Regulation (GDPR) and UK GDPR. We are committed to:
                </p>
                <ul className="list-disc list-inside space-y-2 ml-4">
                  <li><strong>Lawful Basis:</strong> Processing is necessary for the performance of our service and with explicit consent</li>
                  <li><strong>Data Minimisation:</strong> We only collect data necessary for the platform to function</li>
                  <li><strong>Purpose Limitation:</strong> Data is only used for stated purposes</li>
                  <li><strong>Storage Limitation:</strong> Data is retained only as long as necessary</li>
                  <li><strong>Security:</strong> All data is encrypted and stored securely</li>
                  <li><strong>Transparency:</strong> Clear information about data processing</li>
                </ul>
              </div>
            </section>

            <section className="bg-white p-8 rounded-lg border border-gray-200">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">4. Children's Privacy</h2>
              <div className="space-y-4 text-gray-700">
                <p>
                  FamilyNova is designed specifically for children's safety. We have additional protections in place:
                </p>
                <ul className="list-disc list-inside space-y-2 ml-4">
                  <li>All children's accounts require parent verification and consent</li>
                  <li>Parents have full visibility and control over their children's data</li>
                  <li>No third-party data sharing or advertising</li>
                  <li>Age-appropriate monitoring and content filtering</li>
                  <li>School verification adds an additional layer of identity assurance</li>
                  <li>Children can request data deletion through their parents</li>
                </ul>
              </div>
            </section>

            <section className="bg-white p-8 rounded-lg border border-gray-200">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">5. Data Sharing</h2>
              <div className="space-y-4 text-gray-700">
                <p>
                  We do not sell, rent, or share personal information with third parties except:
                </p>
                <ul className="list-disc list-inside space-y-2 ml-4">
                  <li>With explicit consent from parents (for children's data)</li>
                  <li>When required by law or legal process</li>
                  <li>To protect the safety and security of users</li>
                  <li>With service providers who help us operate the platform (under strict confidentiality agreements)</li>
                </ul>
                <p className="mt-4">
                  <strong>We never share data with advertisers or marketing companies.</strong>
                </p>
              </div>
            </section>

            <section className="bg-white p-8 rounded-lg border border-gray-200">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">6. Your Rights</h2>
              <div className="space-y-4 text-gray-700">
                <p>Under GDPR and UK GDPR, you have the right to:</p>
                <ul className="list-disc list-inside space-y-2 ml-4">
                  <li><strong>Access:</strong> Request a copy of your personal data</li>
                  <li><strong>Rectification:</strong> Correct inaccurate or incomplete data</li>
                  <li><strong>Erasure:</strong> Request deletion of your data</li>
                  <li><strong>Restriction:</strong> Limit how we process your data</li>
                  <li><strong>Portability:</strong> Receive your data in a structured format</li>
                  <li><strong>Objection:</strong> Object to certain types of processing</li>
                  <li><strong>Withdraw Consent:</strong> Withdraw consent at any time</li>
                </ul>
                <p className="mt-4">
                  To exercise these rights, please contact us at privacy@familynova.co.uk
                </p>
              </div>
            </section>

            <section className="bg-white p-8 rounded-lg border border-gray-200">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">7. Data Security</h2>
              <div className="space-y-4 text-gray-700">
                <p>We implement industry-standard security measures:</p>
                <ul className="list-disc list-inside space-y-2 ml-4">
                  <li>Encryption of data in transit (HTTPS/TLS)</li>
                  <li>Encryption of sensitive data at rest</li>
                  <li>Secure authentication and access controls</li>
                  <li>Regular security audits and updates</li>
                  <li>Limited access to personal data on a need-to-know basis</li>
                  <li>Secure backup and disaster recovery procedures</li>
                </ul>
              </div>
            </section>

            <section className="bg-white p-8 rounded-lg border border-gray-200">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">8. Data Retention</h2>
              <div className="space-y-4 text-gray-700">
                <p>We retain personal data only as long as necessary:</p>
                <ul className="list-disc list-inside space-y-2 ml-4">
                  <li>Active accounts: Data is retained while the account is active</li>
                  <li>Deleted accounts: Data is deleted within 30 days of account deletion</li>
                  <li>Legal requirements: Some data may be retained longer if required by law</li>
                  <li>Backup data: Securely deleted within 90 days</li>
                </ul>
              </div>
            </section>

            <section className="bg-white p-8 rounded-lg border border-gray-200">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">9. International Transfers</h2>
              <div className="space-y-4 text-gray-700">
                <p>
                  FamilyNova is based in the United Kingdom. All data is stored and processed within the UK/EU, ensuring full GDPR compliance. We do not transfer personal data outside the UK/EU without appropriate safeguards.
                </p>
              </div>
            </section>

            <section className="bg-white p-8 rounded-lg border border-gray-200">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">10. Changes to This Policy</h2>
              <div className="space-y-4 text-gray-700">
                <p>
                  We may update this Privacy Policy from time to time. We will notify users of significant changes via email or through the platform. The "Last updated" date at the top indicates when changes were made.
                </p>
              </div>
            </section>

            <section className="bg-white p-8 rounded-lg border border-gray-200">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">11. Contact Us</h2>
              <div className="space-y-4 text-gray-700">
                <p>
                  If you have questions about this Privacy Policy or wish to exercise your rights, please contact us:
                </p>
                <ul className="list-none space-y-2 ml-4">
                  <li><strong>Email:</strong> privacy@familynova.co.uk</li>
                  <li><strong>Data Protection Officer:</strong> dpo@familynova.co.uk</li>
                  <li><strong>Address:</strong> FamilyNova, United Kingdom</li>
                </ul>
                <p className="mt-4">
                  You also have the right to lodge a complaint with the Information Commissioner's Office (ICO) if you believe we have not handled your data correctly.
                </p>
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

