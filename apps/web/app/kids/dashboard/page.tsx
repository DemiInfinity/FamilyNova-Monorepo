'use client'

import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import Navbar from '../../components/Navbar'
import Footer from '../../components/Footer'

interface Post {
  id: string
  content: string
  imageUrl?: string
  author: {
    id: string
    profile: {
      displayName: string
      avatar?: string
    }
  }
  likes: string[]
  comments: any[]
  createdAt: string
}

export default function KidsDashboard() {
  const router = useRouter()
  const [posts, setPosts] = useState<Post[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [user, setUser] = useState<any>(null)

  useEffect(() => {
    // Check authentication
    const token = localStorage.getItem('kidToken')
    const userStr = localStorage.getItem('kidUser')
    
    if (!token) {
      router.push('/kids')
      return
    }

    if (userStr) {
      setUser(JSON.parse(userStr))
    }

    loadPosts()
  }, [])

  const loadPosts = async () => {
    setIsLoading(true)
    try {
      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'https://family-nova-monorepo.vercel.app/api/v1'
      const token = localStorage.getItem('kidToken')
      
      const response = await fetch(`${apiUrl}/posts`, {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      })

      if (response.status === 401) {
        // Token expired, try refresh
        const refreshToken = localStorage.getItem('kidRefreshToken')
        if (refreshToken) {
          const refreshResponse = await fetch(`${apiUrl}/auth/refresh`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ refresh_token: refreshToken })
          })
          
          if (refreshResponse.ok) {
            const refreshData = await refreshResponse.json()
            localStorage.setItem('kidToken', refreshData.session.access_token)
            // Retry posts request
            const retryResponse = await fetch(`${apiUrl}/posts`, {
              headers: {
                'Authorization': `Bearer ${refreshData.session.access_token}`
              }
            })
            if (retryResponse.ok) {
              const data = await retryResponse.json()
              setPosts(data.posts || [])
            }
          } else {
            router.push('/kids')
          }
        } else {
          router.push('/kids')
        }
      } else if (response.ok) {
        const data = await response.json()
        setPosts(data.posts || [])
      }
    } catch (error) {
      console.error('Failed to load posts:', error)
    } finally {
      setIsLoading(false)
    }
  }

  const handleLogout = () => {
    localStorage.removeItem('kidToken')
    localStorage.removeItem('kidRefreshToken')
    localStorage.removeItem('kidUser')
    router.push('/kids')
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-purple-50 to-pink-50">
      <Navbar />
      <div className="container mx-auto px-4 py-8">
        <div className="max-w-4xl mx-auto">
          {/* Header */}
          <div className="bg-white rounded-lg shadow-lg p-6 mb-6">
            <div className="flex justify-between items-center">
              <div>
                <h1 className="text-2xl font-bold text-gray-900">
                  Welcome back, {user?.profile?.displayName || user?.email || 'Friend'}!
                </h1>
                <p className="text-gray-600 mt-1">Your safe social space</p>
              </div>
              <button
                onClick={handleLogout}
                className="px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition-colors"
              >
                Logout
              </button>
            </div>
          </div>

          {/* Posts Feed */}
          {isLoading ? (
            <div className="text-center py-12">
              <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
              <p className="mt-4 text-gray-600">Loading posts...</p>
            </div>
          ) : posts.length === 0 ? (
            <div className="bg-white rounded-lg shadow-lg p-12 text-center">
              <div className="text-6xl mb-4">📱</div>
              <h2 className="text-2xl font-bold text-gray-900 mb-2">No posts yet</h2>
              <p className="text-gray-600 mb-6">Start connecting with friends to see their posts!</p>
              <Link
                href="/kids/friends"
                className="inline-block bg-blue-600 text-white px-6 py-3 rounded-lg font-medium hover:bg-blue-700 transition-colors"
              >
                Find Friends
              </Link>
            </div>
          ) : (
            <div className="space-y-6">
              {posts.map((post) => (
                <div key={post.id} className="bg-white rounded-lg shadow-lg p-6">
                  <div className="flex items-center mb-4">
                    <div className="w-10 h-10 rounded-full bg-blue-500 flex items-center justify-center text-white font-bold mr-3">
                      {post.author.profile.displayName?.[0] || 'U'}
                    </div>
                    <div>
                      <p className="font-semibold text-gray-900">
                        {post.author.profile.displayName || 'Unknown'}
                      </p>
                      <p className="text-sm text-gray-500">
                        {new Date(post.createdAt).toLocaleDateString()}
                      </p>
                    </div>
                  </div>
                  
                  <p className="text-gray-800 mb-4">{post.content}</p>
                  
                  {post.imageUrl && (
                    <img
                      src={post.imageUrl}
                      alt="Post"
                      className="w-full rounded-lg mb-4"
                    />
                  )}
                  
                  <div className="flex items-center gap-6 pt-4 border-t border-gray-200">
                    <button className="flex items-center gap-2 text-gray-600 hover:text-blue-600">
                      <span>👍</span>
                      <span>{post.likes?.length || 0}</span>
                    </button>
                    <button className="flex items-center gap-2 text-gray-600 hover:text-blue-600">
                      <span>💬</span>
                      <span>{post.comments?.length || 0}</span>
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
      <Footer />
    </div>
  )
}

