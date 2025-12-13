'use client'

import Link from 'next/link'
import Navbar from '../components/Navbar'
import Footer from '../components/Footer'

export default function GDPRPage() {
  return (
    <div className="min-h-screen bg-gray-50">
      <Navbar />

      <div className="container mx-auto px-4 py-16">
        <div className="max-w-4xl mx-auto">
          <h1 className="text-4xl md:text-5xl font-bold text-gray-900 mb-6">
            GDPR & UK GDPR Compliance
          </h1>
          <p className="text-xl text-gray-600 mb-12">
            FamilyNova is fully compliant with the General Data Protection Regulation (GDPR) and UK GDPR. We are committed to protecting your personal data and respecting your privacy rights.
          </p>

          <div className="space-y-8">
            <section className="bg-white p-8 rounded-lg border border-gray-200">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">What is GDPR & UK GDPR?</h2>
              <div className="space-y-4 text-gray-700">
                <p>
                  The General Data Protection Regulation (GDPR) is a comprehensive data protection law that came into effect in the European Union in 2018. UK GDPR is the UK's version of GDPR, which applies after Brexit and maintains the same high standards of data protection.
                </p>
                <p>
                  Both regulations give individuals greater control over their personal data and require organisations to handle data responsibly, transparently, and securely.
                </p>
              </div>
            </section>

            <section className="bg-white p-8 rounded-lg border border-gray-200">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">Our Commitment to Compliance</h2>
              <div className="space-y-4 text-gray-700">
                <p>
                  As a UK-based platform handling children's personal data, FamilyNova takes GDPR and UK GDPR compliance seriously. We have implemented comprehensive measures to ensure full compliance:
                </p>
                <div className="bg-blue-50 p-6 rounded-lg mt-4">
                  <ul className="list-disc list-inside space-y-2">
                    <li>All data processing is lawful, fair, and transparent</li>
                    <li>Data is collected only for specified, legitimate purposes</li>
                    <li>We minimise data collection to what is necessary</li>
                    <li>Data is kept accurate and up-to-date</li>
                    <li>Data is stored securely and retained only as long as necessary</li>
                    <li>We respect and facilitate all user rights</li>
                  </ul>
                </div>
              </div>
            </section>

            <section className="bg-white p-8 rounded-lg border border-gray-200">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">Lawful Basis for Processing</h2>
              <div className="space-y-4 text-gray-700">
                <p>We process personal data under the following lawful bases:</p>
                <div className="space-y-4">
                  <div>
                    <h3 className="font-semibold text-gray-900 mb-2">1. Consent</h3>
                    <p>
                      For children's accounts, we obtain explicit consent from parents (legal guardians) before processing any personal data. Parents provide consent when creating their child's account.
                    </p>
                  </div>
                  <div>
                    <h3 className="font-semibold text-gray-900 mb-2">2. Contract Performance</h3>
                    <p>
                      Processing is necessary to provide the FamilyNova service, including account management, messaging, and content delivery.
                    </p>
                  </div>
                  <div>
                    <h3 className="font-semibold text-gray-900 mb-2">3. Legal Obligation</h3>
                    <p>
                      We may process data to comply with legal obligations, such as child protection laws and data protection regulations.
                    </p>
                  </div>
                  <div>
                    <h3 className="font-semibold text-gray-900 mb-2">4. Legitimate Interests</h3>
                    <p>
                      We process data for legitimate interests such as platform security, fraud prevention, and ensuring child safety, always balancing these against individual rights.
                    </p>
                  </div>
                </div>
              </div>
            </section>

            <section className="bg-white p-8 rounded-lg border border-gray-200">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">Your Rights Under GDPR & UK GDPR</h2>
              <div className="space-y-4 text-gray-700">
                <p>You have the following rights regarding your personal data:</p>
                <div className="grid md:grid-cols-2 gap-4">
                  <div className="bg-gray-50 p-4 rounded-lg">
                    <h3 className="font-semibold text-gray-900 mb-2">Right to Access</h3>
                    <p className="text-sm">Request a copy of all personal data we hold about you or your child.</p>
                  </div>
                  <div className="bg-gray-50 p-4 rounded-lg">
                    <h3 className="font-semibold text-gray-900 mb-2">Right to Rectification</h3>
                    <p className="text-sm">Correct any inaccurate or incomplete personal data.</p>
                  </div>
                  <div className="bg-gray-50 p-4 rounded-lg">
                    <h3 className="font-semibold text-gray-900 mb-2">Right to Erasure</h3>
                    <p className="text-sm">Request deletion of personal data (also known as "right to be forgotten").</p>
                  </div>
                  <div className="bg-gray-50 p-4 rounded-lg">
                    <h3 className="font-semibold text-gray-900 mb-2">Right to Restrict Processing</h3>
                    <p className="text-sm">Limit how we process your data in certain circumstances.</p>
                  </div>
                  <div className="bg-gray-50 p-4 rounded-lg">
                    <h3 className="font-semibold text-gray-900 mb-2">Right to Data Portability</h3>
                    <p className="text-sm">Receive your data in a structured, machine-readable format.</p>
                  </div>
                  <div className="bg-gray-50 p-4 rounded-lg">
                    <h3 className="font-semibold text-gray-900 mb-2">Right to Object</h3>
                    <p className="text-sm">Object to certain types of data processing.</p>
                  </div>
                  <div className="bg-gray-50 p-4 rounded-lg">
                    <h3 className="font-semibold text-gray-900 mb-2">Right to Withdraw Consent</h3>
                    <p className="text-sm">Withdraw consent at any time where processing is based on consent.</p>
                  </div>
                  <div className="bg-gray-50 p-4 rounded-lg">
                    <h3 className="font-semibold text-gray-900 mb-2">Right to Complain</h3>
                    <p className="text-sm">Lodge a complaint with the Information Commissioner's Office (ICO).</p>
                  </div>
                </div>
              </div>
            </section>

            <section className="bg-white p-8 rounded-lg border border-gray-200">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">How to Exercise Your Rights</h2>
              <div className="space-y-4 text-gray-700">
                <p>
                  To exercise any of your GDPR/UK GDPR rights, please contact us:
                </p>
                <div className="bg-blue-50 p-6 rounded-lg">
                  <ul className="list-none space-y-2">
                    <li><strong>Email:</strong> privacy@familynova.co.uk</li>
                    <li><strong>Data Protection Officer:</strong> dpo@familynova.co.uk</li>
                    <li><strong>Subject Line:</strong> "GDPR Request - [Your Request Type]"</li>
                  </ul>
                </div>
                <p className="mt-4">
                  We will respond to your request within one month (or two months for complex requests). We may need to verify your identity before processing certain requests.
                </p>
              </div>
            </section>

            <section className="bg-white p-8 rounded-lg border border-gray-200">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">Special Protections for Children</h2>
              <div className="space-y-4 text-gray-700">
                <p>
                  GDPR and UK GDPR provide special protections for children's personal data. FamilyNova implements additional safeguards:
                </p>
                <ul className="list-disc list-inside space-y-2 ml-4">
                  <li><strong>Parental Consent:</strong> All children's accounts require explicit parental consent</li>
                  <li><strong>Parental Control:</strong> Parents have full visibility and control over their children's data</li>
                  <li><strong>Age Verification:</strong> We verify ages to apply appropriate protections</li>
                  <li><strong>Clear Language:</strong> Privacy information is presented in child-friendly language</li>
                  <li><strong>Data Minimisation:</strong> We collect only the minimum data necessary for the service</li>
                  <li><strong>No Profiling:</strong> We do not create profiles of children for marketing purposes</li>
                </ul>
              </div>
            </section>

            <section className="bg-white p-8 rounded-lg border border-gray-200">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">Data Processing Principles</h2>
              <div className="space-y-4 text-gray-700">
                <p>We follow all GDPR/UK GDPR data processing principles:</p>
                <div className="space-y-3">
                  <div className="border-l-4 border-blue-500 pl-4">
                    <h3 className="font-semibold text-gray-900">Lawfulness, Fairness, and Transparency</h3>
                    <p className="text-sm">All processing is lawful, fair, and transparent to users.</p>
                  </div>
                  <div className="border-l-4 border-blue-500 pl-4">
                    <h3 className="font-semibold text-gray-900">Purpose Limitation</h3>
                    <p className="text-sm">Data is collected only for specified, explicit, and legitimate purposes.</p>
                  </div>
                  <div className="border-l-4 border-blue-500 pl-4">
                    <h3 className="font-semibold text-gray-900">Data Minimisation</h3>
                    <p className="text-sm">We collect only data that is adequate, relevant, and necessary.</p>
                  </div>
                  <div className="border-l-4 border-blue-500 pl-4">
                    <h3 className="font-semibold text-gray-900">Accuracy</h3>
                    <p className="text-sm">We keep data accurate and up-to-date, allowing users to correct information.</p>
                  </div>
                  <div className="border-l-4 border-blue-500 pl-4">
                    <h3 className="font-semibold text-gray-900">Storage Limitation</h3>
                    <p className="text-sm">Data is retained only as long as necessary for the stated purposes.</p>
                  </div>
                  <div className="border-l-4 border-blue-500 pl-4">
                    <h3 className="font-semibold text-gray-900">Integrity and Confidentiality</h3>
                    <p className="text-sm">Data is processed securely with appropriate technical and organisational measures.</p>
                  </div>
                  <div className="border-l-4 border-blue-500 pl-4">
                    <h3 className="font-semibold text-gray-900">Accountability</h3>
                    <p className="text-sm">We are responsible for demonstrating compliance with all principles.</p>
                  </div>
                </div>
              </div>
            </section>

            <section className="bg-white p-8 rounded-lg border border-gray-200">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">Data Security Measures</h2>
              <div className="space-y-4 text-gray-700">
                <p>We implement comprehensive security measures to protect personal data:</p>
                <ul className="list-disc list-inside space-y-2 ml-4">
                  <li><strong>Encryption:</strong> All data is encrypted in transit (HTTPS/TLS) and at rest</li>
                  <li><strong>Access Controls:</strong> Strict access controls limit who can access personal data</li>
                  <li><strong>Secure Infrastructure:</strong> Data stored in secure, UK-based data centres</li>
                  <li><strong>Regular Audits:</strong> Security audits and penetration testing</li>
                  <li><strong>Staff Training:</strong> All staff trained in data protection and security</li>
                  <li><strong>Incident Response:</strong> Procedures for handling data breaches</li>
                  <li><strong>Backup & Recovery:</strong> Secure backup and disaster recovery systems</li>
                </ul>
              </div>
            </section>

            <section className="bg-white p-8 rounded-lg border border-gray-200">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">Data Breach Notification</h2>
              <div className="space-y-4 text-gray-700">
                <p>
                  In the unlikely event of a data breach that poses a risk to your rights and freedoms, we will:
                </p>
                <ul className="list-disc list-inside space-y-2 ml-4">
                  <li>Notify the Information Commissioner's Office (ICO) within 72 hours</li>
                  <li>Notify affected users without undue delay</li>
                  <li>Provide clear information about the nature of the breach</li>
                  <li>Explain the likely consequences</li>
                  <li>Describe measures taken or proposed to address the breach</li>
                </ul>
              </div>
            </section>

            <section className="bg-white p-8 rounded-lg border border-gray-200">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">International Data Transfers</h2>
              <div className="space-y-4 text-gray-700">
                <p>
                  FamilyNova is based in the United Kingdom. All personal data is stored and processed within the UK/EU:
                </p>
                <ul className="list-disc list-inside space-y-2 ml-4">
                  <li>All data centres are located in the UK/EU</li>
                  <li>No data is transferred outside the UK/EU without appropriate safeguards</li>
                  <li>We use Standard Contractual Clauses (SCCs) if any international transfer is necessary</li>
                  <li>We ensure equivalent levels of data protection for any transfers</li>
                </ul>
              </div>
            </section>

            <section className="bg-white p-8 rounded-lg border border-gray-200">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">Data Protection Officer</h2>
              <div className="space-y-4 text-gray-700">
                <p>
                  FamilyNova has appointed a Data Protection Officer (DPO) to oversee our GDPR/UK GDPR compliance:
                </p>
                <div className="bg-blue-50 p-6 rounded-lg">
                  <ul className="list-none space-y-2">
                    <li><strong>Email:</strong> dpo@familynova.co.uk</li>
                    <li><strong>Responsibilities:</strong></li>
                    <ul className="list-disc list-inside space-y-1 ml-4 mt-2">
                      <li>Monitor GDPR/UK GDPR compliance</li>
                      <li>Provide advice on data protection</li>
                      <li>Act as point of contact for data protection authorities</li>
                      <li>Handle data protection inquiries</li>
                    </ul>
                  </ul>
                </div>
              </div>
            </section>

            <section className="bg-white p-8 rounded-lg border border-gray-200">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">Complaints to the ICO</h2>
              <div className="space-y-4 text-gray-700">
                <p>
                  If you are not satisfied with how we handle your personal data, you have the right to lodge a complaint with the Information Commissioner's Office (ICO):
                </p>
                <div className="bg-gray-50 p-6 rounded-lg">
                  <ul className="list-none space-y-2">
                    <li><strong>Website:</strong> <a href="https://ico.org.uk" target="_blank" rel="noopener noreferrer" className="text-blue-600 hover:underline">ico.org.uk</a></li>
                    <li><strong>Phone:</strong> 0303 123 1113</li>
                    <li><strong>Address:</strong> Information Commissioner's Office, Wycliffe House, Water Lane, Wilmslow, Cheshire SK9 5AF</li>
                  </ul>
                </div>
              </div>
            </section>

            <section className="bg-white p-8 rounded-lg border border-gray-200">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">Contact Us</h2>
              <div className="space-y-4 text-gray-700">
                <p>
                  For any questions about our GDPR/UK GDPR compliance or to exercise your rights:
                </p>
                <div className="bg-blue-50 p-6 rounded-lg">
                  <ul className="list-none space-y-2">
                    <li><strong>General Privacy Inquiries:</strong> privacy@familynova.co.uk</li>
                    <li><strong>Data Protection Officer:</strong> dpo@familynova.co.uk</li>
                    <li><strong>Address:</strong> FamilyNova, United Kingdom</li>
                  </ul>
                </div>
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

