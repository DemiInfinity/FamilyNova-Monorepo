package com.nova.parent.api

import com.nova.parent.models.*
import retrofit2.Response
import retrofit2.http.*

interface ApiInterface {
    // Auth
    @POST("auth/login")
    suspend fun login(@Body request: LoginRequest): Response<LoginResponse>
    
    @POST("auth/register")
    suspend fun register(@Body request: RegisterRequest): Response<RegisterResponse>
    
    @GET("auth/me")
    suspend fun getCurrentUser(@Header("Authorization") token: String): Response<ProfileResponse>
    
    // Parents
    @GET("parents/dashboard")
    suspend fun getDashboard(@Header("Authorization") token: String): Response<DashboardResponse>
    
    @GET("parents/children")
    suspend fun getChildren(@Header("Authorization") token: String): Response<ChildrenResponse>
    
    @POST("parents/children/create")
    suspend fun createChild(
        @Header("Authorization") token: String,
        @Body request: CreateChildRequest
    ): Response<CreateChildResponse>
    
    @GET("parents/children/{childId}")
    suspend fun getChildDetails(
        @Header("Authorization") token: String,
        @Path("childId") childId: String
    ): Response<ChildDetailsResponse>
    
    @POST("parents/children/{childId}/login-code")
    suspend fun generateLoginCode(
        @Header("Authorization") token: String,
        @Path("childId") childId: String,
        @Body request: LoginCodeRequest
    ): Response<LoginCodeResponse>
    
    // Monitoring
    @GET("parents/monitoring/messages")
    suspend fun getMonitoredMessages(
        @Header("Authorization") token: String,
        @Query("childId") childId: String? = null
    ): Response<MonitoredMessagesResponse>
    
    // Post Approval
    @GET("parents/posts/pending")
    suspend fun getPendingPosts(@Header("Authorization") token: String): Response<PendingPostsResponse>
    
    @POST("parents/posts/{postId}/approve")
    suspend fun approvePost(
        @Header("Authorization") token: String,
        @Path("postId") postId: String
    ): Response<ApprovePostResponse>
    
    @POST("parents/posts/{postId}/reject")
    suspend fun rejectPost(
        @Header("Authorization") token: String,
        @Path("postId") postId: String,
        @Body request: RejectPostRequest
    ): Response<RejectPostResponse>
    
    // Profile Changes
    @GET("parents/profile-changes/pending")
    suspend fun getPendingProfileChanges(@Header("Authorization") token: String): Response<ProfileChangesResponse>
    
    @POST("parents/profile-changes/{requestId}/approve")
    suspend fun approveProfileChange(
        @Header("Authorization") token: String,
        @Path("requestId") requestId: String
    ): Response<ApproveProfileChangeResponse>
    
    @POST("parents/profile-changes/{requestId}/reject")
    suspend fun rejectProfileChange(
        @Header("Authorization") token: String,
        @Path("requestId") requestId: String
    ): Response<RejectProfileChangeResponse>
    
    // Posts (for parent social features)
    @GET("posts")
    suspend fun getPosts(
        @Header("Authorization") token: String,
        @Query("userId") userId: String? = null
    ): Response<PostsResponse>
    
    @POST("posts")
    suspend fun createPost(
        @Header("Authorization") token: String,
        @Body request: CreatePostRequest
    ): Response<PostResponse>
    
    // Messages (for parent-to-parent messaging)
    @GET("messages")
    suspend fun getMessages(
        @Header("Authorization") token: String,
        @Query("friendId") friendId: String? = null
    ): Response<MessagesResponse>
    
    @POST("messages")
    suspend fun sendMessage(
        @Header("Authorization") token: String,
        @Body request: SendMessageRequest
    ): Response<SendMessageResponse>
}

// Request/Response Models
data class LoginRequest(
    val email: String,
    val password: String
)

data class RegisterRequest(
    val email: String,
    val password: String,
    val firstName: String,
    val lastName: String,
    val userType: String = "parent"
)

data class LoginResponse(
    val session: Session?,
    val user: UserResponse
)

data class RegisterResponse(
    val session: Session?,
    val user: UserResponse
)

data class Session(
    val access_token: String,
    val refresh_token: String?,
    val expires_in: Int,
    val expires_at: Int?
)

data class UserResponse(
    val id: String,
    val email: String,
    val userType: String
)

data class ProfileResponse(
    val user: UserProfileData
)

data class UserProfileData(
    val id: String,
    val email: String,
    val profile: ProfileData,
    val userType: String
)

data class ProfileData(
    val firstName: String?,
    val lastName: String?,
    val displayName: String?,
    val avatar: String?,
    val banner: String?,
    val school: String?,
    val grade: String?
)

data class DashboardResponse(
    val parent: ParentDashboardData
)

data class ParentDashboardData(
    val id: String,
    val profile: ProfileData,
    val children: List<ChildData>,
    val parentConnections: List<ParentConnectionData>?
)

data class ChildData(
    val id: String,
    val email: String,
    val profile: ChildProfileData,
    val verification: VerificationStatusData,
    val lastLogin: String?
)

data class ChildProfileData(
    val firstName: String?,
    val lastName: String?,
    val displayName: String?,
    val avatar: String?,
    val school: String?,
    val grade: String?
)

data class VerificationStatusData(
    val parentVerified: Boolean?,
    val schoolVerified: Boolean?
)

data class ParentConnectionData(
    val id: String,
    val profile: ProfileData
)

data class ChildrenResponse(
    val children: List<ChildData>
)

data class CreateChildRequest(
    val email: String,
    val password: String,
    val firstName: String,
    val lastName: String,
    val displayName: String? = null,
    val dateOfBirth: String? = null,
    val school: String? = null,
    val grade: String? = null
)

data class CreateChildResponse(
    val message: String,
    val child: ChildData
)

data class ChildDetailsResponse(
    val child: ChildDetailsData
)

data class ChildDetailsData(
    val id: String,
    val email: String,
    val profile: ChildProfileData,
    val verification: VerificationStatusData,
    val lastLogin: String?
)

data class LoginCodeRequest(
    val childId: String
)

data class LoginCodeResponse(
    val code: String,
    val expiresAt: String
)

data class MonitoredMessagesResponse(
    val messages: List<MonitoredMessageData>
)

data class MonitoredMessageData(
    val id: String,
    val content: String,
    val sender: String,
    val receiver: String,
    val createdAt: String
)

data class PendingPostsResponse(
    val posts: List<PostData>
)

data class PostData(
    val id: String,
    val content: String,
    val imageUrl: String?,
    val status: String,
    val author: AuthorData,
    val likes: List<String>?,
    val comments: List<CommentData>?,
    val createdAt: String
)

data class AuthorData(
    val id: String,
    val profile: AuthorProfileData
)

data class AuthorProfileData(
    val displayName: String?,
    val avatar: String?
)

data class CommentData(
    val id: String,
    val content: String,
    val author: AuthorData,
    val createdAt: String
)

data class ApprovePostResponse(
    val message: String,
    val post: PostData
)

data class RejectPostRequest(
    val reason: String? = null
)

data class RejectPostResponse(
    val message: String,
    val post: PostData
)

data class ProfileChangesResponse(
    val requests: List<ProfileChangeRequestData>
)

data class ProfileChangeRequestData(
    val id: String,
    val kidId: String,
    val kidName: String,
    val requestedChanges: Map<String, String>,
    val status: String,
    val createdAt: String
)

data class ApproveProfileChangeResponse(
    val message: String
)

data class RejectProfileChangeResponse(
    val message: String
)

data class CreatePostRequest(
    val content: String,
    val imageUrl: String? = null
)

data class PostResponse(
    val post: PostData
)

data class PostsResponse(
    val posts: List<PostData>
)

data class MessagesResponse(
    val messages: List<MessageData>
)

data class MessageData(
    val id: String,
    val senderId: String,
    val receiverId: String,
    val content: String,
    val createdAt: String
)

data class SendMessageRequest(
    val receiverId: String,
    val content: String
)

data class SendMessageResponse(
    val message: MessageData
)

