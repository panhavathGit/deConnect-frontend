# DeConnect - Mock UI Testing

## Overview
This app has been refactored to work with **mock data** instead of a real backend. The MVVM architecture is fully maintained, allowing you to test all UI features without needing to connect to Supabase or any backend service.

## Features

### 🔐 Authentication
- **Login Page**: Enter any email (e.g., `test@example.com`) with a password of at least 6 characters
- Mock authentication always succeeds with valid inputs
- Includes validation for email format and password length

### 📱 Feed
- View a list of mock posts from various users
- Create new posts using the floating action button
- Like posts (updates in real-time in the UI)
- Pull to refresh functionality
- Displays user avatars, usernames, timestamps, and like counts

### 💬 Chat
- View list of existing conversations
- Start new chats with mock users
- Real-time message streaming (simulated)
- Send messages that appear instantly
- Beautiful chat bubble UI with sender/receiver distinction

## Architecture (MVVM)

The app maintains clean MVVM separation:

### Models
- `FeedPost` - Feed post data model
- `MockUser`, `MockMessage`, `MockRoom` - Mock data models in `lib/core/mock/mock_data.dart`

### Views
- `LoginPage` - Authentication UI
- `FeedPage` - Social feed UI
- `RoomListPage` - Chat room list UI
- `ChatRoomPage` - Individual chat conversation UI

### ViewModels
- `AuthViewModel` - Manages authentication state
- `FeedViewModel` - Manages feed data and operations
- `ChatViewModel` - Manages chat rooms and messages

### Repositories (Data Layer)
- `MockAuthRepository` - Mock authentication service
- `MockFeedRepository` - Mock feed data service
- `MockChatRepository` - Mock chat service with simulated realtime streams

## Mock Data

All mock data is centralized in `lib/core/mock/mock_data.dart`:

- **Current User**: `user-1` (TestUser)
- **Other Users**: 4 mock users (John Doe, Jane Smith, Bob Wilson, Alice Johnson)
- **Posts**: 8 sample posts with likes and timestamps
- **Chat Rooms**: 4 existing conversations
- **Messages**: Pre-populated messages for each room

## Testing the App

1. **Login**: Use any email format (e.g., `demo@test.com`) with password `123456` or longer
2. **View Feed**: See 8 mock posts from different users
3. **Create Post**: Tap the + button to create a new post
4. **Like Posts**: Tap the heart icon to like posts
5. **Open Chat**: Tap the chat icon in the app bar
6. **View Conversations**: See 4 existing chat rooms
7. **Start New Chat**: Tap + to select a user and start chatting
8. **Send Messages**: Type and send messages in real-time
9. **Logout**: Tap the logout icon to return to login screen

## Key Benefits

✅ **No Backend Required**: Test all UI features without Supabase or any backend  
✅ **MVVM Maintained**: Clean separation of concerns preserved  
✅ **Real-time Simulation**: Chat messages stream in real-time using StreamControllers  
✅ **Easy to Modify**: All mock data in one file for easy customization  
✅ **Quick Testing**: Instant feedback without network delays  

## Next Steps

When ready to connect to a real backend:

1. Replace `MockAuthRepository` with `AuthRepository` in `AuthViewModel`
2. Replace `MockFeedRepository` with `FeedRepository` in `FeedViewModel`
3. Replace `MockChatRepository` with `ChatRepository` in `ChatViewModel`
4. Re-enable Supabase initialization in `main.dart`
5. Update the Consumer logic to check actual auth state

The UI and ViewModels won't need changes - just swap the repository implementations!
