# CLAUDE.md

必ず日本語で回答すること．/
This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an Intelligent Movie Recommendation System (インテリジェント映画レコメンドシステム) that uses Flutter for the frontend and Firebase/Google Cloud services for the backend. The system analyzes user movie reviews using AI to provide personalized movie recommendations.

## Architecture

- **Frontend**: Flutter (Web/Mobile support)
- **State Management**: Riverpod or Provider
- **Authentication**: Firebase Authentication
- **Database**: Cloud Firestore
- **Backend**: Cloud Functions (serverless)
- **AI/ML**: Google Cloud Vertex AI / Gemini API
- **External APIs**: TMDb API or OMDb API for movie data

## Development Commands

### Flutter Commands
```bash
# Create new Flutter project
flutter create movie_recommend_app

# Build for web
flutter build web

# Run development server
flutter run
```

### Firebase Commands
```bash
# Configure Firebase for Flutter
flutterfire configure

# Initialize Firebase hosting
firebase init hosting

# Deploy to Firebase
firebase deploy

# Start local emulator (for Cloud Functions development)
firebase emulators:start
```

### Project Setup
1. Install Flutter SDK
2. Create Firebase/Google Cloud project and configure
3. Obtain TMDb/OMDb API keys
4. Run `flutterfire configure` to connect Firebase

## System Flow

1. User authentication via Firebase Auth
2. Movie data fetched from TMDb/OMDb APIs via Cloud Functions
3. User reviews stored in Firestore
4. Cloud Functions trigger AI analysis on review submission
5. Gemini/Vertex AI analyzes sentiment and preferences
6. Personalized recommendations generated and stored
7. Flutter UI displays recommendations with reasoning

## Key Components

- **Authentication**: Google sign-in integration
- **Movie Database**: Cached movie data from external APIs
- **Review System**: Star ratings and text comments
- **AI Analysis**: Sentiment analysis and preference profiling
- **Recommendation Engine**: Vertex AI Recommendations
- **Responsive UI**: Dark mode support, mobile-friendly

## Security Considerations

- Firebase Authentication required for all operations
- Strict Firestore security rules
- HTTPS communication enforced
- Secure API key management for external services