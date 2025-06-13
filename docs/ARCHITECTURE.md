# アーキテクチャ設計書 - インテリジェント映画レコメンドシステム

## 1. システム全体アーキテクチャ

### 1.1 アーキテクチャ概要図

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Frontend      │────▶│   Backend       │────▶│   External      │
│   (Flutter)     │     │   (Firebase)    │     │   Services      │
│   ✅ 完成         │     │   ✅ 完成       │     │   ✅ 完成       │
└─────────────────┘     └─────────────────┘     └─────────────────┘
│                       │                       │
│ • Flutter Web ✅      │ • Firebase Auth ✅    │ • TMDb API ✅
│ • Riverpod ✅         │ • Cloud Firestore ✅ │ • Gemini API 🔄
│ • Material Design ✅  │ • Cloud Functions 🔄 │ • Vertex AI 🔄
│ • Responsive UI ✅    │ • Firebase Hosting ✅│
└─────────────────┘     └─────────────────┘     └─────────────────┘

✅ = 実装済み  🔄 = 開発中  ⭕ = 計画中
```

### 1.2 詳細システム構成図

```
[ユーザー]
     |
     ↓ HTTPS
┌─────────────────────────────────────────────────────────────┐
│                    Flutter Web Client                       │
├─────────────────────────────────────────────────────────────┤
│  Presentation Layer                                         │
│  ├─ Pages (Screens)                                        │
│  ├─ Widgets (Components)                                   │
│  └─ State Management (Riverpod)                           │
├─────────────────────────────────────────────────────────────┤
│  Domain Layer                                              │
│  ├─ Entities (Business Objects)                           │
│  ├─ Use Cases (Business Logic)                            │
│  └─ Repository Interfaces                                 │
├─────────────────────────────────────────────────────────────┤
│  Data Layer                                                │
│  ├─ Repository Implementations                             │
│  ├─ Data Sources (Remote/Local)                           │
│  └─ Models (Data Transfer Objects)                        │
└─────────────────────────────────────────────────────────────┘
     |
     ↓ REST API / WebSocket
┌─────────────────────────────────────────────────────────────┐
│                    Firebase Backend                         │
├─────────────────────────────────────────────────────────────┤
│  Firebase Authentication                                   │
│  ├─ Google Sign-In                                        │
│  ├─ JWT Token Management                                  │
│  └─ User Session Management                               │
├─────────────────────────────────────────────────────────────┤
│  Cloud Firestore                                          │
│  ├─ Users Collection                                      │
│  ├─ Movies Collection                                     │
│  ├─ Reviews Collection                                    │
│  ├─ Recommendations Collection                            │
│  └─ User Profiles Collection                              │
├─────────────────────────────────────────────────────────────┤
│  Cloud Functions                                          │
│  ├─ Movie Data Sync                                       │
│  ├─ Review Analysis                                       │
│  ├─ Recommendation Generation                             │
│  └─ User Profile Updates                                  │
├─────────────────────────────────────────────────────────────┤
│  Firebase Hosting                                         │
│  ├─ Static File Serving                                   │
│  ├─ CDN                                                   │
│  └─ SSL/TLS                                               │
└─────────────────────────────────────────────────────────────┘
     |
     ↓ HTTP/REST
┌─────────────────────────────────────────────────────────────┐
│                   External Services                         │
├─────────────────────────────────────────────────────────────┤
│  TMDb API                                                  │
│  ├─ Movie Information                                      │
│  ├─ Search & Discovery                                     │
│  └─ Images & Metadata                                      │
├─────────────────────────────────────────────────────────────┤
│  Google Cloud AI                                          │
│  ├─ Gemini API (Sentiment Analysis)                       │
│  ├─ Vertex AI (Recommendations)                           │
│  └─ Natural Language Processing                           │
└─────────────────────────────────────────────────────────────┘
```

## 2. Clean Architecture 実装

### 2.1 レイヤー構成

#### 2.1.1 Presentation Layer (`lib/features/*/presentation/`)
```
presentation/
├── pages/          # 画面・ページ
├── widgets/        # UIコンポーネント
└── providers/      # Riverpodプロバイダー
```

**責務:**
- ユーザーインターフェース
- ユーザー入力の処理
- 状態管理（UI状態）
- ナビゲーション

#### 2.1.2 Domain Layer (`lib/features/*/domain/`)
```
domain/
├── entities/       # ビジネスエンティティ
├── usecases/       # ビジネスロジック
└── repositories/   # リポジトリインターフェース
```

**責務:**
- ビジネスルール
- エンティティ定義
- ユースケース実装
- 外部依存の抽象化

#### 2.1.3 Data Layer (`lib/features/*/data/`)
```
data/
├── repositories/   # リポジトリ実装
├── datasources/    # データソース
└── models/         # データモデル
```

**責務:**
- データアクセス
- 外部API通信
- ローカルストレージ
- データキャッシュ

### 2.2 依存関係の方向

```
Presentation ──→ Domain ←── Data
     ↑                        ↓
     └─── Dependency Injection ─┘
```

- Presentation層はDomain層に依存
- Data層はDomain層に依存
- Domain層は他の層に依存しない（独立）

## 3. 状態管理アーキテクチャ（Riverpod）

### 3.1 プロバイダー階層

```
┌─────────────────────────────────────────────────────────────┐
│                    Global Providers                         │
├─────────────────────────────────────────────────────────────┤
│  • authProvider (Authentication State)                     │
│  • userProfileProvider (User Profile)                      │
│  • themeProvider (App Theme)                               │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                   Feature Providers                        │
├─────────────────────────────────────────────────────────────┤
│  Movies Feature:                                           │
│  • moviesProvider (Movie List)                            │
│  • movieDetailsProvider (Movie Details)                   │
│  • movieSearchProvider (Search Results)                   │
│                                                            │
│  Reviews Feature:                                          │
│  • reviewsProvider (Review List)                          │
│  • userReviewsProvider (User's Reviews)                   │
│                                                            │
│  Recommendations Feature:                                 │
│  • recommendationsProvider (Personalized Recommendations) │
│  • recommendationAnalysisProvider (Analysis Results)      │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                     UI Providers                           │
├─────────────────────────────────────────────────────────────┤
│  • loadingStateProvider (Loading States)                  │
│  • errorStateProvider (Error Handling)                    │
│  • navigationProvider (Navigation State)                  │
└─────────────────────────────────────────────────────────────┘
```

### 3.2 状態管理パターン

#### 3.2.1 非同期状態管理
```dart
@riverpod
class MovieList extends _$MovieList {
  @override
  Future<List<Movie>> build() async {
    // データ取得ロジック
    return movieRepository.getPopularMovies();
  }
  
  Future<void> refresh() async {
    // リフレッシュロジック
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => movieRepository.getPopularMovies());
  }
}
```

#### 3.2.2 エラーハンドリング
```dart
@riverpod
class GlobalErrorHandler extends _$GlobalErrorHandler {
  @override
  AppError? build() => null;
  
  void handleError(AppError error) {
    state = error;
    // エラーログ送信、ユーザー通知等
  }
  
  void clearError() {
    state = null;
  }
}
```

## 4. データベース設計

### 4.1 Firestore Collections

#### 4.1.1 Users Collection
```javascript
/users/{userId}
{
  "uid": "string",
  "email": "string",
  "displayName": "string?",
  "photoURL": "string?",
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "preferences": {
    "favoriteGenres": ["number"],
    "watchedMovies": ["number"],
    "dislikedGenres": ["number"]
  },
  "aiProfile": {
    "sentimentTrends": {},
    "preferenceWeights": {},
    "lastAnalysisAt": "timestamp"
  }
}
```

#### 4.1.2 Movies Collection
```javascript
/movies/{movieId}
{
  "id": "number",
  "title": "string",
  "overview": "string",
  "posterPath": "string?",
  "backdropPath": "string?",
  "releaseDate": "string?",
  "voteAverage": "number",
  "voteCount": "number",
  "genreIds": ["number"],
  "tmdbData": {}, // TMDb API response cache
  "lastUpdated": "timestamp",
  "popularity": "number"
}
```

#### 4.1.3 Reviews Collection
```javascript
/reviews/{reviewId}
{
  "id": "string",
  "userId": "string",
  "movieId": "number",
  "rating": "number", // 1-5
  "comment": "string",
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "aiAnalysis": {
    "sentimentScore": "number", // -1 to 1
    "emotions": {
      "joy": "number",
      "sadness": "number",
      "anger": "number",
      "fear": "number",
      "surprise": "number"
    },
    "extractedKeywords": ["string"],
    "analyzedAt": "timestamp"
  }
}
```

#### 4.1.4 Recommendations Collection
```javascript
/recommendations/{userId}
{
  "userId": "string",
  "recommendations": [
    {
      "movieId": "number",
      "score": "number",
      "reasons": ["string"],
      "category": "string" // "similar_taste", "genre_based", "trending"
    }
  ],
  "generatedAt": "timestamp",
  "algorithm": "string",
  "version": "string"
}
```

### 4.2 Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Movies are readable by all authenticated users
    match /movies/{movieId} {
      allow read: if request.auth != null;
      allow write: if false; // Only Cloud Functions can write
    }
    
    // Reviews are readable by all, writable by owner
    match /reviews/{reviewId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.auth.uid == resource.data.userId;
      allow update, delete: if request.auth != null && request.auth.uid == resource.data.userId;
    }
    
    // Recommendations are user-specific
    match /recommendations/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if false; // Only Cloud Functions can write
    }
  }
}
```

## 5. API設計

### 5.1 Cloud Functions

#### 5.1.1 Review Analysis Function
```typescript
// functions/src/reviewAnalysis.ts
export const analyzeReview = functions.firestore
  .document('reviews/{reviewId}')
  .onCreate(async (snap, context) => {
    const review = snap.data();
    
    // Gemini API for sentiment analysis
    const sentimentResult = await geminiAnalyze(review.comment);
    
    // Update review with analysis
    await snap.ref.update({
      aiAnalysis: sentimentResult
    });
    
    // Update user profile
    await updateUserProfile(review.userId, sentimentResult);
  });
```

#### 5.1.2 Recommendation Generation Function
```typescript
// functions/src/recommendations.ts
export const generateRecommendations = functions.pubsub
  .schedule('every 6 hours')
  .onRun(async (context) => {
    const users = await getUsersForRecommendation();
    
    for (const user of users) {
      const recommendations = await vertexAIRecommend(user);
      await saveRecommendations(user.uid, recommendations);
    }
  });
```

### 5.2 External API Integration

#### 5.2.1 TMDb API Service
```dart
class TMDbService {
  static const String baseUrl = 'https://api.themoviedb.org/3';
  
  Future<List<Movie>> getPopularMovies({int page = 1}) async {
    final response = await dio.get('$baseUrl/movie/popular', 
      queryParameters: {
        'api_key': tmdbApiKey,
        'page': page,
      }
    );
    
    return (response.data['results'] as List)
        .map((json) => Movie.fromJson(json))
        .toList();
  }
  
  Future<List<Movie>> searchMovies(String query) async {
    final response = await dio.get('$baseUrl/search/movie',
      queryParameters: {
        'api_key': tmdbApiKey,
        'query': query,
      }
    );
    
    return (response.data['results'] as List)
        .map((json) => Movie.fromJson(json))
        .toList();
  }
}
```

## 6. セキュリティアーキテクチャ

### 6.1 認証・認可

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Client        │    │   Firebase      │    │   Firestore     │
│   (Flutter)     │    │   Auth          │    │   (Database)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │ 1. Sign in request    │                       │
         ├──────────────────────▶│                       │
         │                       │                       │
         │ 2. ID Token           │                       │
         │◀──────────────────────┤                       │
         │                       │                       │
         │ 3. Request with token │                       │
         ├───────────────────────┼──────────────────────▶│
         │                       │                       │
         │                       │ 4. Verify token       │
         │                       │◀──────────────────────┤
         │                       │                       │
         │                       │ 5. Authorization      │
         │                       │──────────────────────▶│
         │                       │                       │
         │ 6. Response           │                       │
         │◀──────────────────────┼───────────────────────┤
```

### 6.2 データ保護

- **暗号化**: HTTPS通信、データベース暗号化
- **アクセス制御**: Firestore Security Rules
- **API キー管理**: Cloud Functions環境変数
- **CORS設定**: Origin制限

## 7. パフォーマンスアーキテクチャ

### 7.1 キャッシュ戦略

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Local Cache   │    │   CDN Cache     │    │   Database      │
│   (Flutter)     │    │   (Firebase)    │    │   (Firestore)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │ 1. Check local        │                       │
         │                       │                       │
         │ 2. Check CDN          │                       │
         ├──────────────────────▶│                       │
         │                       │                       │
         │ 3. Query DB           │                       │
         ├───────────────────────┼──────────────────────▶│
         │                       │                       │
         │ 4. Cache & Return     │                       │
         │◀──────────────────────┼───────────────────────┤
```

### 7.2 最適化戦略

- **Lazy Loading**: 画面表示時にデータ取得
- **Pagination**: 大量データの分割取得
- **Image Optimization**: 画像サイズ最適化
- **Code Splitting**: 機能別コード分割
- **Tree Shaking**: 未使用コード除去

## 8. 監視・ログアーキテクチャ

### 8.1 監視項目

- **パフォーマンス**: Firebase Performance Monitoring
- **エラー**: Firebase Crashlytics
- **使用状況**: Firebase Analytics
- **API使用量**: Cloud Monitoring

### 8.2 ログ設計

```dart
enum LogLevel { debug, info, warning, error, fatal }

class Logger {
  static void log(LogLevel level, String message, {
    Map<String, dynamic>? extra,
    Exception? exception,
  }) {
    final logEntry = {
      'timestamp': DateTime.now().toIso8601String(),
      'level': level.name,
      'message': message,
      'extra': extra,
      'exception': exception?.toString(),
    };
    
    // Local logging
    developer.log(message, level: level.index);
    
    // Remote logging (Firebase/Cloud Logging)
    if (level.index >= LogLevel.warning.index) {
      FirebaseCrashlytics.instance.log(jsonEncode(logEntry));
    }
  }
}
```