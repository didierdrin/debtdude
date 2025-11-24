# DebtDude Chat Implementation

## Overview
This implementation integrates the DebtDude Flutter app with the Express.js backend to enable users to ask questions about their transactions through an AI-powered chat interface.

## Backend Integration
- **Base URL**: `https://debtdude-expressjs-backend.onrender.com`
- **API Endpoints Used**:
  - `GET /api/conversations` - Get user conversations
  - `POST /api/conversations` - Create new conversation
  - `GET /api/conversations/:id/messages` - Get messages for a conversation
  - `POST /api/conversations/:id/messages` - Send message to conversation
  - `POST /api/dashboard` - Get dashboard data

## Key Changes Made

### 1. Updated ChatCubit (`lib/cubits/chat_cubit.dart`)
- Replaced Firebase Firestore with backend API calls
- Added proper error handling for API failures
- Maintained local fallback for dashboard calculations

### 2. Updated ConversationCubit (`lib/cubits/conversation_cubit.dart`)
- Integrated with backend API for message handling
- Removed local AI response generation (now handled by backend)
- Added proper error states

### 3. Updated ApiService (`lib/services/api_service.dart`)
- Added comprehensive error handling
- Proper HTTP status code checking
- Graceful fallback responses

### 4. Fixed Provider Issues (`lib/main.dart`)
- Added global BlocProvider for ChatCubit at app level
- Prevents "Provider not found" errors

### 5. Updated ChatScreen (`lib/screens/chat_screen.dart`)
- Uses globally provided ChatCubit instead of creating local instance
- Maintains transaction data integration for AI responses

## Features
- **Real-time Chat**: Users can ask questions about their transactions
- **AI Responses**: Backend generates intelligent responses using Gemini API
- **Transaction Context**: Chat includes user's transaction data for personalized responses
- **Conversation Management**: Create, list, and manage multiple conversations
- **Dashboard Integration**: Shows balance and spending data in chat interface

## Usage
1. Navigate to Chat tab in the app
2. Tap "+" to create a new conversation
3. Ask questions about transactions like:
   - "What's my balance?"
   - "How much did I spend this week?"
   - "Show me my recent transactions"
   - "What are my loan payments?"

## Error Handling
- Network failures gracefully handled with fallback responses
- Local calculations used when backend is unavailable
- User-friendly error messages displayed
- Automatic retry mechanisms for failed requests

## Dependencies
- `flutter_bloc: ^8.1.3` - State management
- `http: ^1.1.0` - HTTP requests
- `firebase_auth: ^5.3.1` - User authentication
- `firebase_core: ^3.6.0` - Firebase initialization