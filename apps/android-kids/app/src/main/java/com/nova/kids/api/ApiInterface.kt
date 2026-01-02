package com.nova.kids.api

import com.nova.kids.models.*
import retrofit2.Response
import retrofit2.http.*

interface ApiInterface {
    // Auth
    @POST("auth/login")
    suspend fun login(@Body request: LoginRequest): Response<LoginResponse>
    
    @POST("auth/register")
    suspend fun register(@Body request: RegisterRequest): Response<RegisterResponse>
    
    @POST("auth/login-code")
    suspend fun loginWithCode(@Body request: LoginCodeRequest): Response<LoginResponse>
    
    // Profile
    @GET("kids/profile")
    suspend fun getProfile(@Header("Authorization") token: String): Response<ProfileResponse>
    
    @GET("auth/me")
    suspend fun getCurrentUser(@Header("Authorization") token: String): Response<ProfileResponse>
    
    // Posts
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
    
    @POST("posts/{postId}/like")
    suspend fun likePost(
        @Header("Authorization") token: String,
        @Path("postId") postId: String
    ): Response<LikeResponse>
    
    @POST("posts/{postId}/comment")
    suspend fun commentOnPost(
        @Header("Authorization") token: String,
        @Path("postId") postId: String,
        @Body request: CommentRequest
    ): Response<CommentResponse>
    
    @DELETE("posts/{postId}")
    suspend fun deletePost(
        @Header("Authorization") token: String,
        @Path("postId") postId: String
    ): Response<DeleteResponse>
    
    // Friends
    @GET("friends")
    suspend fun getFriends(@Header("Authorization") token: String): Response<FriendsResponse>
    
    @POST("friends/request")
    suspend fun sendFriendRequest(
        @Header("Authorization") token: String,
        @Body request: FriendRequestRequest
    ): Response<FriendRequestResponse>
    
    @GET("friends/search")
    suspend fun searchFriends(
        @Header("Authorization") token: String,
        @Query("query") query: String
    ): Response<FriendsSearchResponse>
    
    @POST("friends/add-by-code")
    suspend fun addFriendByCode(
        @Header("Authorization") token: String,
        @Body request: AddFriendByCodeRequest
    ): Response<AddFriendByCodeResponse>
    
    @GET("friends/my-code")
    suspend fun getMyFriendCode(
        @Header("Authorization") token: String
    ): Response<FriendCodeResponse>
    
    // Messages
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
    
    // Upload
    @Multipart
    @POST("upload/avatar")
    suspend fun uploadAvatar(
        @Header("Authorization") token: String,
        @Part file: okhttp3.MultipartBody.Part
    ): Response<UploadResponse>
    
    @Multipart
    @POST("upload/banner")
    suspend fun uploadBanner(
        @Header("Authorization") token: String,
        @Part file: okhttp3.MultipartBody.Part
    ): Response<UploadResponse>
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
    val displayName: String
)

data class LoginCodeRequest(
    val code: String
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
    val verification: VerificationData
)

data class ProfileData(
    val firstName: String?,
    val lastName: String?,
    val displayName: String?,
    val school: String?,
    val grade: String?,
    val avatar: String?,
    val banner: String?
)

data class VerificationData(
    val parentVerified: Boolean?,
    val schoolVerified: Boolean?
)

data class PostsResponse(
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
    val content: String
)

data class CreatePostRequest(
    val content: String,
    val imageUrl: String? = null
)

data class PostResponse(
    val post: PostData
)

data class LikeResponse(
    val message: String,
    val liked: Boolean,
    val likesCount: Int
)

data class CommentRequest(
    val content: String
)

data class CommentResponse(
    val comment: CommentDetailData
)

data class CommentDetailData(
    val id: String,
    val content: String,
    val author: CommentAuthorData,
    val createdAt: String
)

data class CommentAuthorData(
    val id: String,
    val profile: CommentAuthorProfileData?
)

data class CommentAuthorProfileData(
    val displayName: String?
)

data class DeleteResponse(
    val message: String,
    val postId: String
)

data class FriendsResponse(
    val friends: List<FriendData>
)

data class FriendData(
    val id: String,
    val profile: FriendProfileData
)

data class FriendProfileData(
    val displayName: String?,
    val avatar: String?
)

data class FriendRequestRequest(
    val friendId: String
)

data class FriendRequestResponse(
    val message: String,
    val friendRequest: FriendRequestData
)

data class FriendRequestData(
    val id: String,
    val status: String
)

data class FriendsSearchResponse(
    val users: List<FriendSearchResult>
)

data class FriendSearchResult(
    val id: String,
    val profile: FriendProfileData
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

data class UploadResponse(
    val url: String,
    val message: String
)

data class AddFriendByCodeRequest(
    val code: String
)

data class AddFriendByCodeResponse(
    val message: String,
    val friend: FriendData
)

data class FriendCodeResponse(
    val code: String,
    val expiresAt: String?
)

