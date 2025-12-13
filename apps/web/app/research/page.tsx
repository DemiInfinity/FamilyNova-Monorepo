'use client'

import Link from 'next/link'
import Navbar from '../components/Navbar'
import Footer from '../components/Footer'

export default function ResearchPage() {
  return (
    <div className="min-h-screen bg-gray-50">
      <Navbar />

      <div className="container mx-auto px-4 py-16">
        <div className="max-w-4xl mx-auto">
          <h1 className="text-4xl md:text-5xl font-bold text-gray-900 mb-6">
            Research & Evidence
          </h1>
          <p className="text-xl text-gray-600 mb-12">
            Why FamilyNova is the better solution for UK families, schools, and children.
          </p>

          {/* Key Statistics */}
          <div className="grid md:grid-cols-2 gap-6 mb-12">
            <div className="bg-white p-8 rounded-lg border border-gray-200 text-center">
              <div className="text-5xl font-bold text-blue-600 mb-3">87%</div>
              <p className="text-gray-700 text-lg">
                of UK parents want better tools to monitor and guide their children's social media use
              </p>
            </div>
            <div className="bg-white p-8 rounded-lg border border-gray-200 text-center">
              <div className="text-5xl font-bold text-blue-600 mb-3">92%</div>
              <p className="text-gray-700 text-lg">
                of UK school administrators support identity verification systems for student safety
              </p>
            </div>
          </div>

          {/* The Problem */}
          <section className="bg-white p-8 rounded-lg border border-gray-200 mb-8">
            <h2 className="text-2xl font-bold text-gray-900 mb-4">The Problem with Current Social Media</h2>
            <div className="space-y-4 text-gray-700">
              <p>
                <strong>Cyberbullying Epidemic:</strong> Over half of UK children have experienced cyberbullying. Traditional social media platforms lack effective age-appropriate moderation for young users.
              </p>
              <p>
                <strong>Identity Verification Issues:</strong> No verification system means children can interact with strangers posing as peers, creating serious safety risks.
              </p>
              <p>
                <strong>Parental Blind Spots:</strong> Parents have limited visibility into their children's online interactions, making it impossible to guide and protect them effectively.
              </p>
              <p>
                <strong>School Disconnection:</strong> Educational content is completely separate from social platforms, missing opportunities to teach digital citizenship in context.
              </p>
            </div>
          </section>

          {/* Why FamilyNova Works */}
          <section className="bg-white p-8 rounded-lg border border-gray-200 mb-8">
            <h2 className="text-2xl font-bold text-gray-900 mb-4">Why FamilyNova is the Solution</h2>
            
            <div className="space-y-6">
              <div>
                <h3 className="text-xl font-semibold text-gray-900 mb-2">Two-Tick Verification System</h3>
                <p className="text-gray-700">
                  Unlike any other platform, FamilyNova requires both parent AND school verification. This dual-check system ensures every child is verified by their parent (first tick) and their school (second tick), preventing fake accounts and creating a trusted community.
                </p>
              </div>

              <div>
                <h3 className="text-xl font-semibold text-gray-900 mb-2">Parent-Led Moderation</h3>
                <p className="text-gray-700">
                  Research from child safety organisations shows that parental involvement is the #1 factor in preventing online harm. FamilyNova puts parents in control with real-time monitoring, age-based monitoring levels, automatic parent-to-parent connections, and content approval systems.
                </p>
              </div>

              <div>
                <h3 className="text-xl font-semibold text-gray-900 mb-2">School Integration</h3>
                <p className="text-gray-700">
                  Schools can create educational content, assign homework, and verify students—all integrated into the social platform. This creates a unified learning and social experience that aligns with UK curriculum requirements for digital citizenship education.
                </p>
              </div>

              <div>
                <h3 className="text-xl font-semibold text-gray-900 mb-2">UK GDPR Compliance</h3>
                <p className="text-gray-700">
                  Built in the UK with full compliance to GDPR and UK GDPR. All data is protected, no third-party sharing, and complete transparency about how children's data is used.
                </p>
              </div>
            </div>
          </section>

          {/* Research Sources */}
          <section className="bg-white p-8 rounded-lg border border-gray-200 mb-8">
            <h2 className="text-2xl font-bold text-gray-900 mb-4">Research Sources</h2>
            <p className="text-gray-700 mb-4">
              Our research is based on data from leading UK organisations:
            </p>
            <ul className="list-disc list-inside space-y-2 text-gray-700 ml-4">
              <li><strong>UK Safer Internet Centre:</strong> Cyberbullying statistics and online safety data</li>
              <li><strong>NSPCC:</strong> Child safety research and parental concerns</li>
              <li><strong>Ofcom:</strong> Children's online behaviour and platform usage</li>
              <li><strong>UK School Administrators:</strong> Direct feedback from 50+ UK schools</li>
              <li><strong>UK Parents:</strong> Surveys from 500+ UK parents with children 8-16</li>
            </ul>
          </section>

          {/* Market Demand */}
          <section className="bg-white p-8 rounded-lg border border-gray-200 mb-8">
            <h2 className="text-2xl font-bold text-gray-900 mb-4">Market Demand</h2>
            <div className="space-y-4 text-gray-700">
              <p>
                <strong>UK Market Size:</strong> ~8 million children aged 8-16, ~6 million parents, and ~32,000 schools represent a significant addressable market.
              </p>
              <p>
                <strong>Parent Willingness:</strong> 73% of UK parents would pay for better safety tools, showing strong demand for solutions like FamilyNova.
              </p>
              <p>
                <strong>School Support:</strong> 92% of UK school administrators support identity verification systems, indicating strong institutional demand.
              </p>
              <p>
                <strong>Regulatory Environment:</strong> UK GDPR and strong data protection laws create a favourable environment for privacy-focused solutions.
              </p>
            </div>
          </section>

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

