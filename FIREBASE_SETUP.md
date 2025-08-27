# Firebase Setup Instructions

## 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter project name: `ai-chatbot-app` (or your preferred name)
4. Enable Google Analytics (optional)
5. Select or create a Google Analytics account
6. Click "Create project"

## 2. Enable Authentication

1. In Firebase Console, go to **Authentication**
2. Click "Get started"
3. Go to **Sign-in method** tab
4. Enable **Email/Password**:
   - Click on "Email/Password"
   - Enable "Email/Password"
   - Click "Save"
5. Enable **Google**:
   - Click on "Google"
   - Enable "Google"
   - Add your project email as support email
   - Click "Save"

## 3. Create Firestore Database

1. Go to **Firestore Database**
2. Click "Create database"
3. Choose **Start in test mode** (for development)
4. Select a location close to your users
5. Click "Done"

## 4. Create Storage

1. Go to **Storage**
2. Click "Get started"
3. Choose **Start in test mode**
4. Select same location as Firestore
5. Click "Done"

## 5. Add Android App

1. In Project Overview, click Android icon
2. Enter Android package name: `com.sparow.cc.appspraow`
3. Enter App nickname: `AI ChatBot Android`
4. Enter SHA-1 certificate fingerprint (for Google Sign-In)
   - Get debug SHA-1: `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`
5. Click "Register app"
6. Download `google-services.json`
7. Place it in `android/app/` directory
8. Follow the configuration steps shown in Firebase Console

## 6. Add iOS App

1. In Project Overview, click iOS icon
2. Enter iOS bundle ID: `com.sparow.cc.appspraow`
3. Enter App nickname: `AI ChatBot iOS`
4. Click "Register app"
5. Download `GoogleService-Info.plist`
6. Add it to `ios/Runner/` in Xcode
7. Follow the configuration steps shown in Firebase Console

## 7. Update Firebase Configuration

1. Install FlutterFire CLI:
   ```bash
   npm install -g firebase-tools
   dart pub global activate flutterfire_cli
   ```

2. Login to Firebase:
   ```bash
   firebase login
   ```

3. Configure FlutterFire:
   ```bash
   flutterfire configure
   ```

4. This will automatically update `lib/firebase_options.dart` with your project configuration

## 8. Set up Firestore Security Rules

Replace the default rules in Firestore with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own user document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Users can read/write their own conversations
    match /conversations/{conversationId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
    
    // Users can read/write messages in their conversations
    match /conversations/{conversationId}/messages/{messageId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == get(/databases/$(database)/documents/conversations/$(conversationId)).data.userId;
    }
  }
}
```

## 9. Set up Storage Security Rules

Replace the default rules in Storage with:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## 10. Environment Variables

Create a `.env` file in the root directory for API keys:

```
OPENAI_API_KEY=your_openai_api_key_here
GEMINI_API_KEY=your_gemini_api_key_here
STRIPE_PUBLISHABLE_KEY=your_stripe_publishable_key_here
STRIPE_SECRET_KEY=your_stripe_secret_key_here
```

**Important**: Add `.env` to your `.gitignore` file to keep API keys secure.

## 11. Get API Keys

### OpenAI API Key
1. Go to [OpenAI Platform](https://platform.openai.com/)
2. Sign up/Login
3. Go to API Keys section
4. Create new secret key
5. Copy the key to your `.env` file

### Google Gemini API Key
1. Go to [Google AI Studio](https://makersuite.google.com/)
2. Sign up/Login
3. Create new API key
4. Copy the key to your `.env` file

### Stripe API Keys
1. Go to [Stripe Dashboard](https://dashboard.stripe.com/)
2. Sign up/Login
3. Go to Developers > API keys
4. Copy both publishable and secret keys to your `.env` file

After completing these steps, your Firebase project will be ready for the AI ChatBot application!