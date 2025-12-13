'use client'

import Link from 'next/link'
import Navbar from '../components/Navbar'
import Footer from '../components/Footer'

export default function SafetyPage() {
  return (
    <div className="min-h-screen bg-gray-50">
      <Navbar />

      <div className="container mx-auto px-4 py-16">
        <div className="max-w-4xl mx-auto">
          <h1 className="text-4xl md:text-5xl font-bold text-gray-900 mb-6">
            Safety & Security
          </h1>
          <p className="text-xl text-gray-600 mb-12">
            FamilyNova is built with child safety as our top priority. Learn about our comprehensive safety features and security measures.
          </p>

          <div className="space-y-8">
            <section className="bg-white p-8 rounded-lg border border-gray-200">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">Two-Tick Verification System</h2>
              <div className="space-y-4 text-gray-700">
                <p>
                  Every child on FamilyNova must be verified twice before they can fully use the platform:
                </p>
                <div className="bg-blue-50 p-6 rounded-lg">
                  <h3 className="font-semibold text-gray-900 mb-2">Tick 1: Parent Verification</h3>
                  <p className="mb-4">
                    Parents create and verify their child's account, ensuring parental oversight from day one. This prevents children from creating accounts without their parents' knowledge.
                  </p>
                  <h3 className="font-semibold text-gray-900 mb-2">Tick 2: School Verification</h3>
                  <p>
                    Schools provide unique verification codes that children enter to complete their identity verification. This ensures every child is who they claim to be and prevents fake accounts.
                  </p>
                </div>
                <p className="mt-4">
                  <strong>Result:</strong> Complete identity assurance. No anonymous accounts. No fake identities. A trusted community where every user is verified.
                </p>
              </div>
            </section>

            <section className="bg-white p-8 rounded-lg border border-gray-200">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">Parent Monitoring & Moderation</h2>
              <div className="space-y-4 text-gray-700">
                <p>
                  Parents have complete visibility and control over their children's online experience:
                </p>
                <ul className="list-disc list-inside space-y-2 ml-4">
                  <li><strong>Real-Time Monitoring:</strong> See all messages, posts, and friend connections as they happen</li>
                  <li><strong>Message Moderation:</strong> Review and approve/flag messages before they're delivered (for children under 13)</li>
                  <li><strong>Post Approval:</strong> Review and approve posts before they appear in the news feed (for children under 13)</li>
                  <li><strong>Profile Change Approval:</strong> Approve or reject profile changes requested by children</li>
                  <li><strong>Friend Request Oversight:</strong> See who your child is connecting with</li>
                </ul>
              </div>
            </section>

            <section className="bg-white p-8 rounded-lg border border-gray-200">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">Age-Based Monitoring</h2>
              <div className="space-y-4 text-gray-700">
                <p>
                  We recognise that children's needs change as they grow. Our monitoring system adapts:
                </p>
                <div className="grid md:grid-cols-2 gap-6">
                  <div className="bg-blue-50 p-6 rounded-lg">
                    <h3 className="font-semibold text-gray-900 mb-3">Full Monitoring (Under 13)</h3>
                    <ul className="list-disc list-inside space-y-1 text-sm">
                      <li>All messages require parent approval</li>
                      <li>All posts require parent approval</li>
                      <li>Complete visibility into all activity</li>
                      <li>Profile changes require approval</li>
                      <li>Maximum protection for younger children</li>
                    </ul>
                  </div>
                  <div className="bg-green-50 p-6 rounded-lg">
                    <h3 className="font-semibold text-gray-900 mb-3">Partial Monitoring (13+)</h3>
                    <ul className="list-disc list-inside space-y-1 text-sm">
                      <li>Only flagged messages reviewed</li>
                      <li>Posts go live immediately</li>
                      <li>Parents can view activity</li>
                      <li>More independence with safety net</li>
                      <li>Respects growing autonomy</li>
                    </ul>
                  </div>
                </div>
              </div>
            </section>

            <section className="bg-white p-8 rounded-lg border border-gray-200">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">Content Filtering & Moderation</h2>
              <div className="space-y-4 text-gray-700">
                <ul className="list-disc list-inside space-y-2 ml-4">
                  <li><strong>Automated Filtering:</strong> Advanced algorithms detect inappropriate content, bullying, and harmful language</li>
                  <li><strong>Parent Review:</strong> All flagged content is reviewed by parents before delivery</li>
                  <li><strong>Zero Tolerance:</strong> Bullying, hate speech, and inappropriate behaviour result in immediate account restrictions</li>
                  <li><strong>Educational Content:</strong> Built-in resources teach children about online safety and digital citizenship</li>
                  <li><strong>Reporting System:</strong> Children can report concerning content or behaviour</li>
                </ul>
              </div>
            </section>

            <section className="bg-white p-8 rounded-lg border border-gray-200">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">Parent-to-Parent Connections</h2>
              <div className="space-y-4 text-gray-700">
                <p>
                  When children become friends, their parents are automatically connected. This creates a community safety net:
                </p>
                <ul className="list-disc list-inside space-y-2 ml-4">
                  <li>Parents can communicate directly with each other</li>
                  <li>Shared responsibility for monitoring children's interactions</li>
                  <li>Community-based safety approach</li>
                  <li>Parents can discuss concerns about their children's friendships</li>
                </ul>
              </div>
            </section>

            <section className="bg-white p-8 rounded-lg border border-gray-200">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">Data Security</h2>
              <div className="space-y-4 text-gray-700">
                <p>We implement industry-leading security measures:</p>
                <ul className="list-disc list-inside space-y-2 ml-4">
                  <li><strong>Encryption:</strong> All data is encrypted in transit (HTTPS/TLS) and at rest</li>
                  <li><strong>Secure Authentication:</strong> Strong password requirements and secure login systems</li>
                  <li><strong>Access Controls:</strong> Limited access to personal data on a need-to-know basis</li>
                  <li><strong>Regular Audits:</strong> Security audits and penetration testing</li>
                  <li><strong>Secure Infrastructure:</strong> Data stored in secure, UK-based data centres</li>
                  <li><strong>Backup & Recovery:</strong> Regular backups with secure disaster recovery procedures</li>
                </ul>
              </div>
            </section>

            <section className="bg-white p-8 rounded-lg border border-gray-200">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">Privacy Protection</h2>
              <div className="space-y-4 text-gray-700">
                <ul className="list-disc list-inside space-y-2 ml-4">
                  <li><strong>No Third-Party Data Sharing:</strong> We never sell or share data with advertisers</li>
                  <li><strong>GDPR & UK GDPR Compliant:</strong> Full compliance with UK and EU data protection laws</li>
                  <li><strong>Parent Controlled:</strong> Parents have full control over their children's data</li>
                  <li><strong>Data Minimisation:</strong> We only collect data necessary for the platform to function</li>
                  <li><strong>Right to Deletion:</strong> Users can request data deletion at any time</li>
                  <li><strong>Transparency:</strong> Clear information about how data is used</li>
                </ul>
              </div>
            </section>

            <section className="bg-white p-8 rounded-lg border border-gray-200">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">Reporting & Support</h2>
              <div className="space-y-4 text-gray-700">
                <p>
                  If you encounter any safety concerns or inappropriate behaviour:
                </p>
                <ul className="list-disc list-inside space-y-2 ml-4">
                  <li><strong>In-App Reporting:</strong> Use the report feature to flag concerning content or behaviour</li>
                  <li><strong>Parent Dashboard:</strong> Parents can review and moderate all reported content</li>
                  <li><strong>Support Team:</strong> Contact our safety team at safety@familynova.co.uk</li>
                  <li><strong>Emergency Contacts:</strong> For immediate safety concerns, contact local authorities</li>
                </ul>
              </div>
            </section>

            <section className="bg-white p-8 rounded-lg border border-gray-200">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">Safety Tips for Parents</h2>
              <div className="space-y-4 text-gray-700">
                <ul className="list-disc list-inside space-y-2 ml-4">
                  <li>Regularly review your child's activity through the parent dashboard</li>
                  <li>Have conversations with your child about online safety</li>
                  <li>Connect with other parents when your children become friends</li>
                  <li>Use the monitoring features appropriate for your child's age</li>
                  <li>Report any concerning behaviour immediately</li>
                  <li>Keep your parent account secure with a strong password</li>
                </ul>
              </div>
            </section>

            <section className="bg-white p-8 rounded-lg border border-gray-200">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">Safety Tips for Children</h2>
              <div className="space-y-4 text-gray-700">
                <ul className="list-disc list-inside space-y-2 ml-4">
                  <li>Only connect with people you know in real life</li>
                  <li>Be kind and respectful in all your messages and posts</li>
                  <li>Don't share personal information like your address or phone number</li>
                  <li>Tell a parent or trusted adult if something makes you uncomfortable</li>
                  <li>Use the report feature if you see bullying or inappropriate content</li>
                  <li>Remember that everything you share can be seen by your parents</li>
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

