# 🌟 Contributing to Brevity

Thank you for your interest in contributing to **Brevity**! We welcome all kinds of contributions — whether it's fixing bugs, improving documentation, adding new features, or helping with translations.

## 📚 Table of Contents

- [🤝 Ways to Contribute](#ways-to-contribute)
- [⭐ Show Your Support](#show-your-support)
- [🔧 Development Setup](#development-setup)
  - [📋 Prerequisites](#prerequisites)
  - [🚀 Frontend Setup (Flutter)](#frontend-setup-flutter)
  - [🧱 Backend Setup (Node.js)](#backend-setup-nodejs)
- [📍 Project Structure](#project-structure)
- [🔄 Contribution Workflow](#contribution-workflow)
- [🎯 Issue Guidelines](#issue-guidelines)
- [📍 Backend API Documentation](#backend-api-documentation)
- [💬 Community & Support](#community--support)
- [🙌 Thank You!](#thank-you)



## 🤝 Ways to Contribute <a id="ways-to-contribute"></a>

- 🐛 **Bug fixes** - Help us squash those pesky bugs
- ✨ **New features** - Implement exciting new functionality
- 📚 **Documentation** - Improve or write new documentation
- 🎨 **UI/UX improvements** - Make the app more beautiful and user-friendly
- 🧪 **Testing** - Write tests to improve code quality
- 🔧 **Performance optimizations** - Make the app faster and more efficient
- 🛡️ **Security improvements** - Help keep user data safe



## ⭐ Show Your Support <a id="show-your-support"></a>

If you like the project, **give it a star**! ⭐  
👉 [Star Brevity on GitHub](https://github.com/Yash159357/BREVITY)



## 🔧 Development Setup <a id="development-setup"></a>

### 📋 Prerequisites <a id="prerequisites"></a>

Before you begin, ensure you have the following installed on your system:

**For Flutter Development:**
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.7.0 or higher)
- [Dart SDK](https://dart.dev/get-dart) (comes with Flutter)
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/)
- [Git](https://git-scm.com/downloads)

**For Backend Development:**
- [Node.js](https://nodejs.org/) (18.x or higher recommended)
- [npm](https://www.npmjs.com/) or [yarn](https://yarnpkg.com/)
- [MongoDB](https://www.mongodb.com/try/download/community) (local or cloud)
- [Git](https://git-scm.com/downloads)

**Additional Tools (Optional but Recommended):**
- [MongoDB Compass](https://www.mongodb.com/products/compass) - GUI for MongoDB
- [Postman](https://www.postman.com/) - API testing

### 🚀 Frontend Setup (Flutter) <a id="frontend-setup-flutter"></a>

#### 1. Fork and Clone the Repository

1. **Fork** the repository by clicking the "Fork" button at the top right of [this repo](https://github.com/Yash159357/BREVITY)

2. **Clone** your fork:
```bash
git clone https://github.com/YOUR-USERNAME/brevity.git
cd brevity
```

3. **Set up upstream** to keep your fork synchronized:
```bash
git remote add upstream https://github.com/Yash159357/BREVITY.git
git remote -v
```

You should see:
```bash
origin    https://github.com/YOUR-USERNAME/brevity.git (fetch)
origin    https://github.com/YOUR-USERNAME/brevity.git (push)
upstream  https://github.com/Yash159357/BREVITY.git (fetch)
upstream  https://github.com/Yash159357/BREVITY.git (push)
```

#### 2. Configure Environment Variables

Create a `.env` file at the root of the Flutter project:

```bash
# For Windows
type nul > .env

# For macOS/Linux
touch .env
```

Add the following to your `.env` file:

```env
# API Keys
GEMINI_API_KEY=your_gemini_api_key_here
NEWS_API_KEY=your_news_api_key_here

# Optional: Add more configuration as needed
```

> 🔒 **Important**: Never commit the `.env` file to version control. It's already included in `.gitignore`.

#### 3. Get API Keys

**Gemini API Key:**
1. Visit [Google AI Studio](https://aistudio.google.com/apikey)
2. Create a new API key
3. Copy and paste it into your `.env` file

**News API Key:**
1. Visit [NewsAPI.org](https://newsapi.org/register)
2. Sign up for a free account
3. Copy your API key to the `.env` file

#### 4. Configure Android Signing (Required for Building)

The project includes an Android signing configuration that needs to be set up for building APKs.

**Configure `key.properties` file:**

1. Navigate to the `android` directory - there's already a `key.properties` file
2. Update the existing `android/key.properties` file with appropriate values:

**For Development/Debug Builds:**
```properties
storeFile=debug.keystore
storePassword=android
keyAlias=androiddebugkey
keyPassword=android
```

**For Production Builds:**
```properties
storeFile=your-release-keystore.jks
storePassword=your_store_password
keyAlias=your_key_alias
keyPassword=your_key_password
```

**Create Debug Keystore (if needed):**

If you don't have a debug keystore, create one:
```bash
# Navigate to android directory
cd android

# Create debug keystore
keytool -genkeypair -v -keystore debug.keystore -storepass android -alias androiddebugkey -keypass android -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=Android Debug,O=Android,C=US"
```

**For Production Release:**

1. Generate a release keystore:
```bash
keytool -genkey -v -keystore your-release-keystore.jks -alias your_key_alias -keyalg RSA -keysize 2048 -validity 10000
```

2. Update `key.properties` with your actual keystore details

> 🔒 **Important**: 
> - Never commit keystore files or real passwords to version control
> - The `key.properties` file is already gitignored for security
> - Keep your release keystore and passwords secure

#### 5. Install Dependencies and Run

```bash
# Install Flutter dependencies
flutter pub get

# Run the app (make sure you have an emulator running or device connected)
flutter run
```

#### 6. Verify Setup

- The app should launch successfully
- Check that API calls are working (news feed loads, AI features respond)
- No errors in the debug console

**Common Issues & Troubleshooting:**

🔧 **Build Issues:**
- If you get signing errors, ensure `key.properties` is configured correctly
- For "Keystore not found" errors, check the `storeFile` path in `key.properties`
- Ensure you have the correct Android SDK and build tools installed

🔧 **API Issues:**
- If news feed doesn't load, verify your `NEWS_API_KEY` in `.env`
- If AI features don't work, check your `GEMINI_API_KEY` in `.env`
- Ensure `.env` file is in the root directory, not in subdirectories

🔧 **Emulator Issues:**
- Make sure you have at least one Android emulator created in Android Studio
- Or connect a physical device with USB debugging enabled
- Check that your device/emulator is detected with `flutter devices`

### 🧱 Backend Setup (Node.js) <a id="backend-setup-nodejs"></a>

> **Note**: Backend setup is only required if you're working on server-side features. The backend is already deployed and accessible for frontend development.

#### 1. Navigate to Server Directory

```bash
cd server
```

#### 2. Install Dependencies

```bash
npm install
```

#### 3. Configure Environment Variables

The server directory should have a `.env.example` file. Copy it to create your own `.env`:

```bash
# For Windows
copy .env.example .env

# For macOS/Linux
cp .env.example .env
```

Then update the values in `.env` with your actual credentials (see `.env.example` for all required variables).

#### 4. Set Up Database

**Option A: Local MongoDB**
1. Install and start MongoDB locally
2. Use the default connection string in `.env`

**Option B: MongoDB Atlas (Cloud)**
1. Create a free account at [MongoDB Atlas](https://www.mongodb.com/atlas)
2. Create a new cluster
3. Get your connection string and update `MONGODB_URI` in `.env`

#### 5. Run the Server

```bash
# Development mode (with auto-restart)
npm run dev

# Production mode
npm start
```

Your backend will be running at: [http://localhost:5001](http://localhost:5001)

#### 6. Verify Backend Setup

Test the server with a simple GET request:
```bash
curl http://localhost:5001/api/health
```

Or visit [http://localhost:5001/api/health](http://localhost:5001/api/health) in your browser.


## 📍 Project Structure <a id="project-structure"></a>

```
brevity/
├── 📱 lib/                     # Flutter app source code
│   ├── controller/            # State management & business logic
│   ├── models/               # Data models
│   ├── utils/                # Utility functions
│   └── views/                # UI screens and widgets
├── 🖥️ server/                 # Node.js backend
│   ├── controllers/          # Route handlers
│   ├── middleware/           # Custom middleware
│   ├── models/              # Database models
│   ├── routes/              # API routes
│   └── services/            # Business logic
├── 🏗️ android/               # Android-specific code
├── 🍎 ios/                   # iOS-specific code
├── 🌐 web/                   # Web-specific assets
├── 🧪 test/                  # Test files
├── 📄 .env                   # Environment variables (create this)
├── 📦 pubspec.yaml          # Flutter dependencies
└── 📖 README.md             # Project documentation
```


## 🔄 Contribution Workflow <a id="contribution-workflow"></a>

### Step 1: Choose an Issue
1. Browse [open issues](https://github.com/Yash159357/BREVITY/issues)
2. Comment on the issue to get it assigned to you

### Step 2: Create a Branch
```bash
# Sync with upstream
git checkout main
git pull upstream main

# Create a new branch for your feature
git checkout -b feature/your-feature-name

# Or for bug fixes
git checkout -b fix/bug-description
```

### Step 3: Make Your Changes
- Write clean, readable code
- Follow the existing code style
- Add comments where necessary
- Test your changes thoroughly

### Step 4: Commit Your Changes
```bash
# Stage your changes
git add .

# Commit with a descriptive message
git commit -m "feat: add new feature description"

# Or for bug fixes
git commit -m "fix: resolve issue with specific component"
```

**Commit Message Convention:**
- `feat:` for new features
- `fix:` for bug fixes
- `docs:` for documentation changes
- `style:` for formatting changes
- `refactor:` for code refactoring
- `test:` for adding or updating tests
- `chore:` for maintenance tasks

### Step 5: Push and Create Pull Request
```bash
# Push to your fork
git push origin your-branch-name
```

Then create a pull request through GitHub's interface.


## 🎯 Issue Guidelines <a id="issue-guidelines"></a>

### Claiming Issues
- 💬 **Comment first**: Claim an issue by leaving a comment
- ⏳ **7-day rule**: Issues will be unassigned if inactive for 7+ days
- 🥇 **First come, first serve**: Issues are assigned based on who claims first
- 🚫 **One at a time**: Work on one issue at a time until completion

## 📍 Backend API Documentation <a id="backend-api-documentation"></a>

Our Node.js/Express backend provides comprehensive REST API endpoints for user authentication, content management, bookmarks, and more.

### 🔗 Base URLs
- **Development**: `http://localhost:5001`
- **Production**: `https://your-production-url.com`

### 🔐 Authentication
Most endpoints require authentication via JWT Bearer tokens:
```http
Authorization: Bearer <your-jwt-token>
```

### 📊 API Response Format
All API responses follow this standard format:
```json
{
  "success": true,
  "message": "Operation successful",
  "data": { ... },
  "timestamp": "2025-08-12T10:30:00.000Z"
}
```

### 🛣️ Endpoints

#### 🔑 Authentication (`/api/auth`)
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| `POST` | `/register` | User registration with profile image | ❌ |
| `POST` | `/resend-verification` | Resend email verification | ❌ |
| `GET` | `/verify-email` | Verify user email address | ❌ |
| `POST` | `/login` | User login | ❌ |
| `POST` | `/google` | Google OAuth authentication | ❌ |
| `POST` | `/forgot-password` | Send password reset email | ❌ |
| `POST` | `/reset-password` | Reset password with token | ❌ |
| `POST` | `/logout` | User logout | ✅ |
| `GET` | `/me` | Get current user profile | ✅ |

#### 👤 User Management (`/api/users`)
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| `PUT` | `/profile` | Update user profile with image | ✅ |
| `DELETE` | `/profile/image` | Delete profile image | ✅ |
| `DELETE` | `/deleteAccount` | Delete user account | ✅ |

#### � News (`/api/news`)
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| `GET` | `/trending` | Get trending news articles | ❌ |
| `GET` | `/general` | Get general news articles | ❌ |
| `GET` | `/category/:category` | Get news by category | ❌ |
| `GET` | `/politics` | Get politics news | ❌ |
| `GET` | `/search` | Search news articles | ❌ |
| `GET` | `/:newsId` | Get specific news article by ID | ✅ |
| `POST` | `/share` | Get shareable link for news | ✅ |

#### 👍 Reactions (`/api/reactions`)
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| `POST` | `/like` | Like a news article | ✅ |
| `POST` | `/dislike` | Dislike a news article | ✅ |
| `GET` | `/reacted-news` | Get user's reacted news | ✅ |
| `DELETE` | `/like/:articleId` | Remove like from article | ✅ |
| `DELETE` | `/dislike/:articleId` | Remove dislike from article | ✅ |

#### �🔖 Bookmarks (`/api/bookmarks`)
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| `GET` | `/` | Get user's bookmarks | ✅ |
| `POST` | `/` | Toggle bookmark (add/remove) | ✅ |

#### 🤖 AI/Gemini (`/api/gemini`)
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| `POST` | `/generate` | Generate content using Gemini AI | ✅ |
| `GET` | `/health` | Gemini service health check | ❌ |

#### ⚕️ System
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| `GET` | `/api/health` | Health check endpoint | ❌ |
| `GET` | `/auth/verify-email` | Email verification redirect | ❌ |

### 📋 Request Examples

#### User Registration
```bash
curl -X POST http://localhost:5001/api/auth/register \
  -F "email=user@example.com" \
  -F "password=securePassword123" \
  -F "name=John Doe" \
  -F "profileImage=@/path/to/image.jpg"
```

#### User Login
```bash
curl -X POST http://localhost:5001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"securePassword123"}'
```

#### Google OAuth Login
```bash
curl -X POST http://localhost:5001/api/auth/google \
  -H "Content-Type: application/json" \
  -d '{"idToken":"google_id_token_here"}'
```

#### Get Trending News
```bash
curl -X GET http://localhost:5001/api/news/trending
```

#### Search News
```bash
curl -X GET "http://localhost:5001/api/news/search?q=technology&page=1&limit=10"
```

#### Get Bookmarks
```bash
curl -X GET http://localhost:5001/api/bookmarks \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

#### Like a News Article
```bash
curl -X POST http://localhost:5001/api/reactions/like \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"articleId":"article_id_here","articleUrl":"https://example.com/article"}'
```

#### Generate AI Content
```bash
curl -X POST http://localhost:5001/api/gemini/generate \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"prompt":"Summarize this article","maxTokens":500}'
```

#### Share News Article
```bash
curl -X POST http://localhost:5001/api/news/share \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"articleId":"article_id_here","title":"Article Title","url":"https://example.com"}'
```

### 🔄 Error Handling
The API uses standard HTTP status codes:
- `200` - Success
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `429` - Too Many Requests
- `500` - Internal Server Error

Error responses include detailed messages:
```json
{
  "success": false,
  "message": "Validation error",
  "errors": [
    {
      "field": "email",
      "message": "Please provide a valid email address"
    }
  ]
}
```

### 📄 Complete API Documentation

For detailed information about all endpoints, request/response schemas, and advanced features, download our comprehensive API documentation:

📥 **[Download Complete API Documentation](assets/backend_route_overview.docx)**

This document includes:
- 📝 Detailed endpoint descriptions
- 🔍 Request/response examples
- 🛡️ Authentication requirements
- 📊 Data validation rules
- 🚨 Error scenarios and handling
- 🔄 Rate limiting information
- 🧪 Testing guidelines

### 🧪 Testing the API

You can test the API using various tools:

#### Recommended Tools
- **[Postman](https://postman.com)** - Full-featured API client
- **cURL** - Command line tool

#### Quick Health Check
```bash
curl http://localhost:5001/api/health
```

Expected response:
```json
{
  "success": true,
  "status": "OK",
  "message": "NewsAI Backend is running",
  "timestamp": "2025-08-12T10:30:00.000Z"
}
```

### 📈 Rate Limiting
- **Limit**: 100 requests per 15-minute window per IP
- **Headers**: Check `X-RateLimit-*` headers in responses
- **Exceeded**: Returns `429 Too Many Requests`


## 💬 Community & Support <a id="community--support"></a>

### Getting Help
- 💬 **Discord**: Join our [Discord community](https://discord.gg/csnXFwPGUb)
- 🐛 **Issues**: Create a [GitHub issue](https://github.com/Yash159357/BREVITY/issues/new)

### Community Guidelines
- Be respectful and inclusive
- Help others when you can
- Stay on topic in discussions
- Follow our [Code of Conduct](CODE_OF_CONDUCT.md)

### Recognition
Contributors are recognized in our:
- 📜 Hall of Fame in the README
- 🏆 Monthly contributor highlights
- 🎉 Special mentions in release notes

## 🙌 Thank You! <a id="thank-you"></a>

Every contribution matters, whether you're:
- 🐛 Fixing a small typo
- ✨ Implementing a major feature  
- 📚 Improving documentation
- 🧪 Writing tests
- 🎨 Designing UI improvements

**Your efforts help make Brevity better for everyone!** 🎉
