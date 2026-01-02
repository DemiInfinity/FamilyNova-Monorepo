# Syncing Kids App from Parent App

This document outlines the process for updating the kids app (Nova) with changes from the parent app (Nova+), but only for shared views that exist in both apps.

## Shared Views to Sync

The following views exist in both apps and should be kept in sync:

1. **AboutView.swift** - About page with app info
2. **AddFriendView.swift** - Add friend functionality
3. **CommentsView.swift** - Post comments
4. **CreatePostView.swift** - Create text posts
5. **EditProfileView.swift** - Edit user profile
6. **EnterFriendCodeView.swift** - Enter friend code
7. **ExploreView.swift** - Explore/discover page
8. **FriendsView.swift** - Friends list and management
9. **HomeFeedView.swift** - Main feed view
10. **ImagePicker.swift** - Image picker utility
11. **LoginView.swift** - Login screen
12. **MainTabView.swift** - Main tab navigation
13. **MessagesView.swift** - Messaging interface
14. **MoreView.swift** - More menu
15. **NotificationsView.swift** - Notifications list
16. **PhotoPostView.swift** - Create photo posts
17. **PostDetailView.swift** - Post detail view
18. **ProfileComponents.swift** - Profile UI components
19. **ProfileView.swift** - User profile
20. **QRCodeScannerView.swift** - QR code scanner
21. **ScanFriendQRView.swift** - Scan friend QR code
22. **SettingsView.swift** - Settings page
23. **ShowMyFriendCodeView.swift** - Show friend code
24. **UnifiedCreatePostView.swift** - Unified post creation

## Sync Process

### 1. Design System Updates
- Ensure both apps use the same cosmic design system
- Check for `CosmicColors`, `CosmicFonts`, `CosmicSpacing` consistency
- Verify `CosmicPostCard` and other shared components

### 2. Feature Updates
When updating features in parent app, check if they should be synced to kids app:
- Post reactions and comments
- Real-time messaging
- Friend requests
- Notifications
- Profile updates
- Image uploads

### 3. Code Structure
- Keep API service calls consistent
- Maintain same data models where applicable
- Use same utility functions

## Kids-Only Views (Do NOT sync)
- **EducationView.swift** - Education content (kids only)
- **HomeView.swift** - Kids-specific home view
- **NewsFeedView.swift** - Kids-specific news feed

## Parent-Only Views (Do NOT sync)
- **ActivityReportsView.swift**
- **ChildDetailsView.swift**
- **ConnectionsView.swift**
- **CreateChildAccountView.swift**
- **DashboardView.swift**
- **FeedView.swift**
- **HomeworkView.swift**
- **MonitoringView.swift**
- **MyPostsView.swift**
- **PostApprovalView.swift**
- **ProfileChangeApprovalView.swift**
- **RegisterView.swift**
- **SafetyDashboardView.swift**
- **SplashScreenView.swift**
- **SubscriptionView.swift**

## Manual Sync Checklist

When syncing a view from parent to kids app:

- [ ] Copy the updated view file
- [ ] Update import statements (FamilyNovaParent → FamilyNovaKids)
- [ ] Check for parent-specific code (remove if present)
- [ ] Verify cosmic design system usage
- [ ] Test the view in kids app
- [ ] Ensure API endpoints are correct (kids vs parents endpoints)
- [ ] Check for any hardcoded app names ("Nova+" → "Nova")

## Automated Sync Script

A script can be created to automate this process, but manual review is recommended to ensure:
1. No parent-specific features leak into kids app
2. API endpoints are correctly differentiated
3. Design system is properly applied

