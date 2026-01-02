'use client'

import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import Navbar from '../../components/Navbar'
import Footer from '../../components/Footer'

interface Child {
  id: string
  email: string
  profile: {
    displayName: string
    avatar?: string
  }
  verification: {
    parentVerified: boolean
    schoolVerified: boolean
  }
}

interface PendingPost {
  id: string
  content: string
  imageUrl?: string
  author: {
    id: string
    profile: {
      displayName: string
    }
  }
  createdAt: string
}

export default function ParentsDashboard() {
  const router = useRouter()
  const [children, setChildren] = useState<Child[]>([])
  const [pendingPosts, setPendingPosts] = useState<PendingPost[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [user, setUser] = useState<any>(null)
  const [activeTab, setActiveTab] = useState<'overview' | 'children' | 'pending'>('overview')

  useEffect(() => {
    const token = localStorage.getItem('parentToken')
    const userStr = localStorage.getItem('parentUser')
    
    if (!token) {
      router.push('/parents')
      return
    }

    if (userStr) {
      setUser(JSON.parse(userStr))
    }

    loadDashboard()
  }, [])

  const loadDashboard = async () => {
    setIsLoading(true)
    try {
      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'https://family-nova-monorepo.vercel.app/api/v1'
      const token = localStorage.getItem('parentToken')
      
      // Load children
      const childrenResponse = await fetch(`${apiUrl}/parents/dashboard`, {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      })

      if (childrenResponse.ok) {
        const data = await childrenResponse.json()
        setChildren(data.children || [])
      }

      // Load pending posts
      const pendingResponse = await fetch(`${apiUrl}/posts/pending`, {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      })

      if (pendingResponse.ok) {
        const pendingData = await pendingResponse.json()
        setPendingPosts(pendingData.posts || [])
      }
    } catch (error) {
      console.error('Failed to load dashboard:', error)
    } finally {
      setIsLoading(false)
    }
  }

  const approvePost = async (postId: string) => {
    try {
      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'https://family-nova-monorepo.vercel.app/api/v1'
      const token = localStorage.getItem('parentToken')
      
      const response = await fetch(`${apiUrl}/posts/${postId}/approve`, {
        method: 'PUT',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ action: 'approve' })
      })

      if (response.ok) {
        loadDashboard()
      }
    } catch (error) {
      console.error('Failed to approve post:', error)
    }
  }

  const rejectPost = async (postId: string) => {
    try {
      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'https://family-nova-monorepo.vercel.app/api/v1'
      const token = localStorage.getItem('parentToken')
      
      const response = await fetch(`${apiUrl}/posts/${postId}/approve`, {
        method: 'PUT',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ action: 'reject', reason: 'Post rejected by parent' })
      })

      if (response.ok) {
        loadDashboard()
      }
    } catch (error) {
      console.error('Failed to reject post:', error)
    }
  }

  const handleLogout = () => {
    localStorage.removeItem('parentToken')
    localStorage.removeItem('parentRefreshToken')
    localStorage.removeItem('parentUser')
    router.push('/parents')
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <Navbar />
      <div className="container mx-auto px-4 py-8">
        <div className="max-w-6xl mx-auto">
          {/* Header */}
          <div className="bg-white rounded-lg shadow-lg p-6 mb-6">
            <div className="flex justify-between items-center">
              <div>
                <h1 className="text-2xl font-bold text-gray-900">
                  Parent Dashboard
                </h1>
                <p className="text-gray-600 mt-1">
                  Monitor and manage your children's online activity
                </p>
              </div>
              <button
                onClick={handleLogout}
                className="px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition-colors"
              >
                Logout
              </button>
            </div>
          </div>

          {/* Tabs */}
          <div className="bg-white rounded-lg shadow-lg mb-6">
            <div className="flex border-b border-gray-200">
              <button
                onClick={() => setActiveTab('overview')}
                className={`px-6 py-3 font-medium ${
                  activeTab === 'overview'
                    ? 'text-blue-600 border-b-2 border-blue-600'
                    : 'text-gray-600 hover:text-gray-900'
                }`}
              >
                Overview
              </button>
              <button
                onClick={() => setActiveTab('children')}
                className={`px-6 py-3 font-medium ${
                  activeTab === 'children'
                    ? 'text-blue-600 border-b-2 border-blue-600'
                    : 'text-gray-600 hover:text-gray-900'
                }`}
              >
                Children ({children.length})
              </button>
              <button
                onClick={() => setActiveTab('pending')}
                className={`px-6 py-3 font-medium ${
                  activeTab === 'pending'
                    ? 'text-blue-600 border-b-2 border-blue-600'
                    : 'text-gray-600 hover:text-gray-900'
                }`}
              >
                Pending Posts ({pendingPosts.length})
              </button>
            </div>
          </div>

          {/* Content */}
          {isLoading ? (
            <div className="text-center py-12">
              <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
              <p className="mt-4 text-gray-600">Loading dashboard...</p>
            </div>
          ) : (
            <div className="bg-white rounded-lg shadow-lg p-6">
              {activeTab === 'overview' && (
                <div>
                  <h2 className="text-xl font-bold text-gray-900 mb-4">Overview</h2>
                  <div className="grid md:grid-cols-3 gap-4 mb-6">
                    <div className="bg-blue-50 p-4 rounded-lg">
                      <p className="text-sm text-gray-600">Children</p>
                      <p className="text-3xl font-bold text-blue-600">{children.length}</p>
                    </div>
                    <div className="bg-yellow-50 p-4 rounded-lg">
                      <p className="text-sm text-gray-600">Pending Posts</p>
                      <p className="text-3xl font-bold text-yellow-600">{pendingPosts.length}</p>
                    </div>
                    <div className="bg-green-50 p-4 rounded-lg">
                      <p className="text-sm text-gray-600">Verified Children</p>
                      <p className="text-3xl font-bold text-green-600">
                        {children.filter(c => c.verification.parentVerified && c.verification.schoolVerified).length}
                      </p>
                    </div>
                  </div>
                </div>
              )}

              {activeTab === 'children' && (
                <div>
                  <h2 className="text-xl font-bold text-gray-900 mb-4">Your Children</h2>
                  {children.length === 0 ? (
                    <p className="text-gray-600">No children added yet.</p>
                  ) : (
                    <div className="space-y-4">
                      {children.map((child) => (
                        <div key={child.id} className="border border-gray-200 rounded-lg p-4">
                          <div className="flex items-center justify-between">
                            <div>
                              <p className="font-semibold text-gray-900">
                                {child.profile.displayName || child.email}
                              </p>
                              <p className="text-sm text-gray-600">{child.email}</p>
                            </div>
                            <div className="flex gap-2">
                              {child.verification.parentVerified && (
                                <span className="px-2 py-1 bg-green-100 text-green-700 rounded text-xs">
                                  Parent ✓
                                </span>
                              )}
                              {child.verification.schoolVerified && (
                                <span className="px-2 py-1 bg-blue-100 text-blue-700 rounded text-xs">
                                  School ✓
                                </span>
                              )}
                            </div>
                          </div>
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              )}

              {activeTab === 'pending' && (
                <div>
                  <h2 className="text-xl font-bold text-gray-900 mb-4">Pending Posts for Approval</h2>
                  {pendingPosts.length === 0 ? (
                    <p className="text-gray-600">No pending posts.</p>
                  ) : (
                    <div className="space-y-4">
                      {pendingPosts.map((post) => (
                        <div key={post.id} className="border border-gray-200 rounded-lg p-4">
                          <div className="flex items-center mb-2">
                            <p className="font-semibold text-gray-900">
                              {post.author.profile.displayName || 'Unknown'}
                            </p>
                            <span className="ml-2 text-sm text-gray-500">
                              {new Date(post.createdAt).toLocaleDateString()}
                            </span>
                          </div>
                          <p className="text-gray-800 mb-4">{post.content}</p>
                          {post.imageUrl && (
                            <img src={post.imageUrl} alt="Post" className="w-full rounded-lg mb-4" />
                          )}
                          <div className="flex gap-2">
                            <button
                              onClick={() => approvePost(post.id)}
                              className="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors"
                            >
                              Approve
                            </button>
                            <button
                              onClick={() => rejectPost(post.id)}
                              className="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors"
                            >
                              Reject
                            </button>
                          </div>
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              )}
            </div>
          )}
        </div>
      </div>
      <Footer />
    </div>
  )
}

