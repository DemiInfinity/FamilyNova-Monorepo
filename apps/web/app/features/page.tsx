'use client'

import Link from 'next/link'
import Navbar from '../components/Navbar'
import Footer from '../components/Footer'

export default function FeaturesPage() {
  return (
    <div className="min-h-screen bg-gray-50">
      <Navbar />

      <div className="container mx-auto px-4 py-16">
        <div className="max-w-4xl mx-auto">
          <h1 className="text-4xl md:text-5xl font-bold text-gray-900 mb-6">
            Features
          </h1>
          <p className="text-xl text-gray-600 mb-12">
            Everything you need to keep kids safe while they learn and connect online.
          </p>

          <div className="space-y-12">
            {/* Two-Tick Verification */}
            <section className="bg-white p-8 rounded-lg border border-gray-200">
              <div className="flex items-start space-x-4">
                <div className="text-4xl">✅</div>
                <div>
                  <h2 className="text-2xl font-bold text-gray-900 mb-4">Two-Tick Verification System</h2>
                  <p className="text-gray-700 mb-4">
                    Every child on FamilyNova is verified twice for complete identity assurance:
                  </p>
                  <ul className="list-disc list-inside space-y-2 text-gray-700 ml-4">
                    <li><strong>First Tick - Parent Verification:</strong> Parents create and verify their child's account, ensuring oversight from day one</li>
                    <li><strong>Second Tick - School Verification:</strong> Schools provide unique verification codes that children enter to complete their identity verification</li>
                  </ul>
                  <p className="text-gray-700 mt-4">
                    This dual-check system ensures no anonymous accounts, no fake identities, and a completely trusted community.
                  </p>
                </div>
              </div>
            </section>

            {/* Parent Monitoring */}
            <section className="bg-white p-8 rounded-lg border border-gray-200">
              <div className="flex items-start space-x-4">
                <div className="text-4xl">👨‍👩‍👧‍👦</div>
                <div>
                  <h2 className="text-2xl font-bold text-gray-900 mb-4">Parent Monitoring & Moderation</h2>
                  <p className="text-gray-700 mb-4">
                    Parents have complete visibility and control over their children's online experience:
                  </p>
                  <ul className="list-disc list-inside space-y-2 text-gray-700 ml-4">
                    <li><strong>Real-Time Monitoring:</strong> See all messages, posts, and friend connections as they happen</li>
                    <li><strong>Age-Based Monitoring:</strong> Full monitoring for children under 13, partial monitoring for 13+</li>
                    <li><strong>Content Approval:</strong> Review and approve posts before they go live for younger children</li>
                    <li><strong>Message Moderation:</strong> Review flagged messages and moderate conversations</li>
                    <li><strong>Profile Change Approval:</strong> Approve or reject profile changes requested by children</li>
                  </ul>
                </div>
              </div>
            </section>

            {/* School Integration */}
            <section className="bg-white p-8 rounded-lg border border-gray-200">
              <div className="flex items-start space-x-4">
                <div className="text-4xl">🏫</div>
                <div>
                  <h2 className="text-2xl font-bold text-gray-900 mb-4">School Integration</h2>
                  <p className="text-gray-700 mb-4">
                    Schools can create educational content and verify students all in one platform:
                  </p>
                  <ul className="list-disc list-inside space-y-2 text-gray-700 ml-4">
                    <li><strong>Educational Content:</strong> Create homework, lessons, quizzes, and resources</li>
                    <li><strong>Student Verification:</strong> Generate unique codes for students to verify their identity</li>
                    <li><strong>Homework Management:</strong> Assign homework that appears in the kids' education tab</li>
                    <li><strong>Parent Visibility:</strong> Parents can see their children's homework assignments and completion status</li>
                    <li><strong>Digital Citizenship:</strong> Built-in educational content about online safety</li>
                  </ul>
                </div>
              </div>
            </section>

            {/* Parent Connections */}
            <section className="bg-white p-8 rounded-lg border border-gray-200">
              <div className="flex items-start space-x-4">
                <div className="text-4xl">👥</div>
                <div>
                  <h2 className="text-2xl font-bold text-gray-900 mb-4">Automatic Parent Connections</h2>
                  <p className="text-gray-700 mb-4">
                    When children become friends, their parents are automatically connected:
                  </p>
                  <ul className="list-disc list-inside space-y-2 text-gray-700 ml-4">
                    <li><strong>Community Safety Net:</strong> Parents can communicate with each other about their children's friendships</li>
                    <li><strong>Shared Responsibility:</strong> Multiple parents monitoring creates a safer environment</li>
                    <li><strong>Direct Communication:</strong> Message other parents directly through the app</li>
                  </ul>
                </div>
              </div>
            </section>

            {/* Safe Social Networking */}
            <section className="bg-white p-8 rounded-lg border border-gray-200">
              <div className="flex items-start space-x-4">
                <div className="text-4xl">💬</div>
                <div>
                  <h2 className="text-2xl font-bold text-gray-900 mb-4">Safe Social Networking for Kids</h2>
                  <p className="text-gray-700 mb-4">
                    Children can connect with friends in a protected environment:
                  </p>
                  <ul className="list-disc list-inside space-y-2 text-gray-700 ml-4">
                    <li><strong>Verified Friends Only:</strong> Only interact with other verified children</li>
                    <li><strong>News Feed:</strong> Share posts about their day (with parent approval for younger children)</li>
                    <li><strong>Messaging:</strong> Chat with friends with parent monitoring</li>
                    <li><strong>Friend Search:</strong> Find and add verified friends</li>
                    <li><strong>Profile Management:</strong> Edit profile with parent approval</li>
                  </ul>
                </div>
              </div>
            </section>

            {/* Privacy & Safety */}
            <section className="bg-white p-8 rounded-lg border border-gray-200">
              <div className="flex items-start space-x-4">
                <div className="text-4xl">🛡️</div>
                <div>
                  <h2 className="text-2xl font-bold text-gray-900 mb-4">Privacy & Safety</h2>
                  <p className="text-gray-700 mb-4">
                    Built with child safety and privacy as the top priority:
                  </p>
                  <ul className="list-disc list-inside space-y-2 text-gray-700 ml-4">
                    <li><strong>GDPR & UK GDPR Compliant:</strong> Full compliance with UK and EU data protection laws</li>
                    <li><strong>No Third-Party Data Sharing:</strong> Your data stays private</li>
                    <li><strong>Parent Controlled:</strong> Parents have full control over their children's accounts</li>
                    <li><strong>No Ads:</strong> Clean, focused experience without advertising</li>
                    <li><strong>Secure Communication:</strong> All messages and data are encrypted</li>
                  </ul>
                </div>
              </div>
            </section>
          </div>

          <div className="mt-12 text-center">
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

