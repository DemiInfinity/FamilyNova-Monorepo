'use client'

import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import Logo from '../../components/Logo'

interface EducationContent {
  id: string
  title: string
  description: string
  contentType: string
  grade: string
  subject: string
  dueDate?: string
}

export default function SchoolDashboard() {
  const router = useRouter()
  const [content, setContent] = useState<EducationContent[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [showCreateForm, setShowCreateForm] = useState(false)
  const [formData, setFormData] = useState({
    title: '',
    description: '',
    contentType: 'homework' as 'homework' | 'lesson' | 'quiz' | 'resource',
    grade: '',
    subject: '',
    dueDate: ''
  })

  useEffect(() => {
    // Check authentication
    const token = localStorage.getItem('schoolToken')
    if (!token) {
      router.push('/schools')
      return
    }
    loadContent()
  }, [])

  const loadContent = async () => {
    setIsLoading(true)
    try {
      // TODO: Implement API call to fetch school's education content
      // This would require school authentication middleware
      setContent([])
    } catch (error) {
      console.error('Failed to load content:', error)
    } finally {
      setIsLoading(false)
    }
  }

  const handleCreateContent = async (e: React.FormEvent) => {
    e.preventDefault()
    const token = localStorage.getItem('schoolToken')
    if (!token) {
      router.push('/schools')
      return
    }

    try {
      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://infinityiotserver.local:3000/api'
      
      // Get school ID from token (would need to decode JWT in real implementation)
      // For now, we'll need to store school ID separately or decode token
      
      const response = await fetch(`${apiUrl}/education`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({
          schoolId: 'temp', // TODO: Get from token
          ...formData,
          dueDate: formData.dueDate || undefined
        })
      })

      if (!response.ok) throw new Error('Failed to create content')

      setShowCreateForm(false)
      setFormData({
        title: '',
        description: '',
        contentType: 'homework',
        grade: '',
        subject: '',
        dueDate: ''
      })
      loadContent()
    } catch (error) {
      console.error('Failed to create content:', error)
    }
  }

  const generateCode = async () => {
    const token = localStorage.getItem('schoolToken')
    if (!token) {
      router.push('/schools')
      return
    }

    try {
      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://infinityiotserver.local:3000/api'
      const grade = prompt('Enter grade for this code (e.g., Grade 5):')
      if (!grade) return
      
      const response = await fetch(`${apiUrl}/school-codes/generate`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({
          schoolId: 'temp', // TODO: Get from token
          grade
        })
      })

      if (!response.ok) throw new Error('Failed to generate code')

      const data = await response.json()
      alert(`Code generated: ${data.code.code}\n\nShare this code with the student.`)
      loadContent()
    } catch (error) {
      console.error('Failed to generate code:', error)
      alert('Failed to generate code')
    }
  }

  const handleLogout = () => {
    localStorage.removeItem('schoolToken')
    router.push('/schools')
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <nav className="bg-white shadow-sm">
        <div className="container mx-auto px-4 py-4 flex justify-between items-center">
          <Logo size="sm" variant="parent" />
          <button
            onClick={handleLogout}
            className="text-gray-600 hover:text-gray-800"
          >
            Logout
          </button>
        </div>
      </nav>

      <div className="container mx-auto px-4 py-8">
        <div className="flex justify-between items-center mb-8">
          <div>
            <h1 className="text-3xl font-bold text-navy mb-2">School Dashboard</h1>
            <p className="text-gray-600">Manage education content and student codes</p>
          </div>
          <div className="flex gap-4">
            <button
              onClick={() => setShowCreateForm(!showCreateForm)}
              className="bg-teal-600 text-white px-6 py-3 rounded-lg font-semibold hover:bg-teal-700 transition-colors"
            >
              {showCreateForm ? 'Cancel' : '+ Create Content'}
            </button>
          </div>
        </div>
        
        {/* School Codes Section */}
        <div className="bg-white rounded-lg shadow-md p-6 mb-8">
          <div className="flex justify-between items-center mb-4">
            <h2 className="text-2xl font-bold text-navy">Student Codes</h2>
            <button
              onClick={generateCode}
              className="bg-blue-600 text-white px-4 py-2 rounded-lg font-semibold hover:bg-blue-700 transition-colors"
            >
              + Generate Code
            </button>
          </div>
          <p className="text-gray-600 mb-4">
            Generate codes for students to link their accounts to your school. Codes expire after 30 days.
          </p>
          <SchoolCodeGenerator />
        </div>

        {showCreateForm && (
          <div className="bg-white rounded-lg shadow-md p-6 mb-8">
            <h2 className="text-2xl font-bold text-navy mb-4">Create Education Content</h2>
            <form onSubmit={handleCreateContent} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Title *
                </label>
                <input
                  type="text"
                  required
                  value={formData.title}
                  onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-teal-500"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Description
                </label>
                <textarea
                  value={formData.description}
                  onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                  rows={4}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-teal-500"
                />
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Content Type *
                  </label>
                  <select
                    required
                    value={formData.contentType}
                    onChange={(e) => setFormData({ ...formData, contentType: e.target.value as any })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-teal-500"
                  >
                    <option value="homework">Homework</option>
                    <option value="lesson">Lesson</option>
                    <option value="quiz">Quiz</option>
                    <option value="resource">Resource</option>
                  </select>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Grade *
                  </label>
                  <input
                    type="text"
                    required
                    value={formData.grade}
                    onChange={(e) => setFormData({ ...formData, grade: e.target.value })}
                    placeholder="e.g., Grade 5"
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-teal-500"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Subject *
                  </label>
                  <input
                    type="text"
                    required
                    value={formData.subject}
                    onChange={(e) => setFormData({ ...formData, subject: e.target.value })}
                    placeholder="e.g., Math, Science"
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-teal-500"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Due Date
                  </label>
                  <input
                    type="date"
                    value={formData.dueDate}
                    onChange={(e) => setFormData({ ...formData, dueDate: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-teal-500"
                  />
                </div>
              </div>

              <button
                type="submit"
                className="w-full bg-teal-600 text-white py-3 rounded-lg font-semibold hover:bg-teal-700 transition-colors"
              >
                Create Content
              </button>
            </form>
          </div>
        )}

        <div className="bg-white rounded-lg shadow-md p-6">
          <h2 className="text-2xl font-bold text-navy mb-4">Education Content</h2>
          
          {isLoading ? (
            <div className="text-center py-8">Loading...</div>
          ) : content.length === 0 ? (
            <div className="text-center py-8 text-gray-500">
              No content created yet. Create your first education content above.
            </div>
          ) : (
            <div className="space-y-4">
              {content.map((item) => (
                <div key={item.id} className="border border-gray-200 rounded-lg p-4">
                  <div className="flex justify-between items-start">
                    <div>
                      <h3 className="text-lg font-semibold text-navy">{item.title}</h3>
                      <p className="text-gray-600 text-sm mt-1">{item.description}</p>
                      <div className="flex gap-4 mt-2 text-sm text-gray-500">
                        <span>{item.contentType}</span>
                        <span>•</span>
                        <span>{item.grade}</span>
                        <span>•</span>
                        <span>{item.subject}</span>
                        {item.dueDate && (
                          <>
                            <span>•</span>
                            <span>Due: {new Date(item.dueDate).toLocaleDateString()}</span>
                          </>
                        )}
                      </div>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  )
}

function SchoolCodeGenerator() {
  const [codes, setCodes] = useState<any[]>([])
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    loadCodes()
  }, [])

  const loadCodes = async () => {
    setIsLoading(true)
    try {
      const token = localStorage.getItem('schoolToken')
      if (!token) return

      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://infinityiotserver.local:3000/api'
      const response = await fetch(`${apiUrl}/school-codes?schoolId=temp`, {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      })

      if (response.ok) {
        const data = await response.json()
        setCodes(data.codes || [])
      }
    } catch (error) {
      console.error('Failed to load codes:', error)
    } finally {
      setIsLoading(false)
    }
  }

  if (isLoading) {
    return <div className="text-center py-4">Loading codes...</div>
  }

  if (codes.length === 0) {
    return (
      <div className="text-center py-8 text-gray-500">
        No codes generated yet. Click "Generate Code" to create one.
      </div>
    )
  }

  return (
    <div className="space-y-3">
      {codes.map((code: any) => (
        <div key={code.id} className="border border-gray-200 rounded-lg p-4 flex justify-between items-center">
          <div>
            <div className="flex items-center gap-3">
              <span className="text-2xl font-mono font-bold text-teal-600">{code.code}</span>
              <span className="text-sm text-gray-500">Grade: {code.grade}</span>
            </div>
            <div className="text-sm text-gray-500 mt-1">
              {code.assignedTo ? (
                <span className="text-green-600">✓ Used by {code.assignedTo.profile?.displayName || code.assignedTo.email}</span>
              ) : (
                <span className="text-orange-600">○ Unused</span>
              )}
              {code.expiresAt && (
                <span className="ml-4">
                  Expires: {new Date(code.expiresAt).toLocaleDateString()}
                </span>
              )}
            </div>
          </div>
          {!code.assignedTo && (
            <button
              onClick={() => {
                navigator.clipboard.writeText(code.code)
                alert('Code copied to clipboard!')
              }}
              className="bg-gray-100 hover:bg-gray-200 px-4 py-2 rounded-lg text-sm font-medium"
            >
              Copy
            </button>
          )}
        </div>
      ))}
    </div>
  )
}

