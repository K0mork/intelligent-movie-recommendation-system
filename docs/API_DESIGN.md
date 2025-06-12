# API設計書 - インテリジェント映画レコメンドシステム

## 1. API概要

### 1.1 API設計原則
- RESTful API設計
- 統一的なレスポンス形式
- 適切なHTTPステータスコード
- 認証・認可の実装
- エラーハンドリングの標準化

### 1.2 基本URL
- **開発環境**: `https://us-central1-movie-recommend-dev.cloudfunctions.net`
- **本番環境**: `https://us-central1-movie-recommend-prod.cloudfunctions.net`

## 2. 認証・認可

### 2.1 認証方式
Firebase Authentication による JWT Token 認証

#### 2.1.1 認証ヘッダー
```http
Authorization: Bearer <Firebase_ID_Token>
```

#### 2.1.2 トークン取得例
```typescript
// Firebase Auth からトークン取得
const user = firebase.auth().currentUser;
const idToken = await user.getIdToken();
```

### 2.2 権限レベル
- **Anonymous**: 未認証ユーザー（映画閲覧のみ）
- **Authenticated**: 認証済みユーザー（レビュー投稿、推薦取得）
- **Admin**: 管理者（データ管理、システム設定）

## 3. レスポンス形式

### 3.1 成功レスポンス
```json
{
  "success": true,
  "data": {
    // レスポンスデータ
  },
  "message": "Operation successful",
  "timestamp": "2025-06-12T05:00:00.000Z"
}
```

### 3.2 エラーレスポンス
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": {
      "field": "rating",
      "reason": "Rating must be between 1 and 5"
    }
  },
  "timestamp": "2025-06-12T05:00:00.000Z"
}
```

### 3.3 ページネーション
```json
{
  "success": true,
  "data": {
    "items": [...],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 150,
      "totalPages": 8,
      "hasNext": true,
      "hasPrev": false
    }
  }
}
```

## 4. Cloud Functions API

### 4.1 映画関連API

#### 4.1.1 人気映画一覧取得
```http
GET /api/movies/popular
```

**Parameters:**
- `page` (number, optional): ページ番号 (default: 1)
- `limit` (number, optional): 取得件数 (default: 20, max: 100)

**Response:**
```json
{
  "success": true,
  "data": {
    "movies": [
      {
        "id": 123456,
        "title": "Sample Movie",
        "overview": "Movie description...",
        "posterPath": "/path/to/poster.jpg",
        "backdropPath": "/path/to/backdrop.jpg",
        "releaseDate": "2024-01-15",
        "voteAverage": 7.8,
        "voteCount": 1250,
        "genreIds": [28, 12, 16],
        "popularity": 45.6
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 500,
      "totalPages": 25,
      "hasNext": true,
      "hasPrev": false
    }
  }
}
```

#### 4.1.2 映画検索
```http
GET /api/movies/search
```

**Parameters:**
- `query` (string, required): 検索クエリ
- `page` (number, optional): ページ番号
- `year` (number, optional): 公開年
- `genre` (number, optional): ジャンルID

**Response:**
```json
{
  "success": true,
  "data": {
    "movies": [...],
    "searchMeta": {
      "query": "avengers",
      "totalResults": 45,
      "searchTime": 0.123
    },
    "pagination": {...}
  }
}
```

#### 4.1.3 映画詳細取得
```http
GET /api/movies/{movieId}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "movie": {
      "id": 123456,
      "title": "Sample Movie",
      "overview": "Detailed movie description...",
      "posterPath": "/path/to/poster.jpg",
      "backdropPath": "/path/to/backdrop.jpg",
      "releaseDate": "2024-01-15",
      "voteAverage": 7.8,
      "voteCount": 1250,
      "genres": [
        {"id": 28, "name": "Action"},
        {"id": 12, "name": "Adventure"}
      ],
      "cast": [
        {
          "id": 123,
          "name": "Actor Name",
          "character": "Character Name",
          "profilePath": "/path/to/profile.jpg"
        }
      ],
      "director": "Director Name",
      "runtime": 148,
      "budget": 200000000,
      "revenue": 2048359754
    }
  }
}
```

### 4.2 レビュー関連API

#### 4.2.1 レビュー投稿
```http
POST /api/reviews
```

**Request Body:**
```json
{
  "movieId": 123456,
  "rating": 4.5,
  "comment": "Great movie! Really enjoyed it."
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "review": {
      "id": "review_uuid",
      "userId": "user_uuid",
      "movieId": 123456,
      "rating": 4.5,
      "comment": "Great movie! Really enjoyed it.",
      "createdAt": "2025-06-12T05:00:00.000Z",
      "updatedAt": "2025-06-12T05:00:00.000Z"
    }
  },
  "message": "Review posted successfully"
}
```

#### 4.2.2 レビュー一覧取得
```http
GET /api/reviews
```

**Parameters:**
- `movieId` (number, optional): 映画IDでフィルタ
- `userId` (string, optional): ユーザーIDでフィルタ
- `page` (number, optional): ページ番号
- `sortBy` (string, optional): ソート項目 (`createdAt`, `rating`, `helpful`)
- `order` (string, optional): ソート順 (`asc`, `desc`)

**Response:**
```json
{
  "success": true,
  "data": {
    "reviews": [
      {
        "id": "review_uuid",
        "userId": "user_uuid",
        "movieId": 123456,
        "rating": 4.5,
        "comment": "Great movie!",
        "createdAt": "2025-06-12T05:00:00.000Z",
        "user": {
          "displayName": "User Name",
          "photoURL": "/path/to/avatar.jpg"
        },
        "aiAnalysis": {
          "sentimentScore": 0.85,
          "emotions": {
            "joy": 0.8,
            "excitement": 0.7
          }
        }
      }
    ],
    "pagination": {...}
  }
}
```

#### 4.2.3 レビュー更新
```http
PUT /api/reviews/{reviewId}
```

**Request Body:**
```json
{
  "rating": 5.0,
  "comment": "Updated review comment"
}
```

#### 4.2.4 レビュー削除
```http
DELETE /api/reviews/{reviewId}
```

### 4.3 推薦関連API

#### 4.3.1 パーソナライズ推薦取得
```http
GET /api/recommendations/personalized
```

**Parameters:**
- `limit` (number, optional): 取得件数 (default: 10, max: 50)
- `category` (string, optional): 推薦カテゴリ (`similar_taste`, `genre_based`, `trending`)

**Response:**
```json
{
  "success": true,
  "data": {
    "recommendations": [
      {
        "movie": {
          "id": 123456,
          "title": "Recommended Movie",
          "posterPath": "/path/to/poster.jpg",
          "voteAverage": 8.2
        },
        "score": 0.92,
        "reasons": [
          "Based on your love for action movies",
          "Similar to movies you rated highly",
          "Trending among users with similar taste"
        ],
        "category": "similar_taste"
      }
    ],
    "meta": {
      "algorithm": "hybrid_collaborative_filtering",
      "version": "1.2.0",
      "generatedAt": "2025-06-12T05:00:00.000Z",
      "profileCompleteness": 0.78
    }
  }
}
```

#### 4.3.2 推薦フィードバック
```http
POST /api/recommendations/feedback
```

**Request Body:**
```json
{
  "movieId": 123456,
  "action": "liked", // "liked", "disliked", "not_interested", "watched"
  "source": "personalized_recommendation"
}
```

### 4.4 ユーザー関連API

#### 4.4.1 ユーザープロファイル取得
```http
GET /api/users/profile
```

**Response:**
```json
{
  "success": true,
  "data": {
    "profile": {
      "uid": "user_uuid",
      "email": "user@example.com",
      "displayName": "User Name",
      "photoURL": "/path/to/avatar.jpg",
      "createdAt": "2025-01-01T00:00:00.000Z",
      "preferences": {
        "favoriteGenres": [28, 12, 16],
        "watchedMoviesCount": 45,
        "avgRating": 4.2
      },
      "aiProfile": {
        "preferenceWeights": {
          "action": 0.8,
          "comedy": 0.6,
          "drama": 0.4
        },
        "sentimentTrends": {
          "positivity": 0.75,
          "complexity": 0.6
        },
        "lastAnalysisAt": "2025-06-11T10:00:00.000Z"
      }
    }
  }
}
```

#### 4.4.2 ユーザープロファイル更新
```http
PUT /api/users/profile
```

**Request Body:**
```json
{
  "displayName": "New Display Name",
  "preferences": {
    "favoriteGenres": [28, 12, 35]
  }
}
```

### 4.5 分析関連API

#### 4.5.1 ダッシュボードデータ取得
```http
GET /api/analytics/dashboard
```

**Response:**
```json
{
  "success": true,
  "data": {
    "stats": {
      "totalReviews": 67,
      "avgRating": 4.2,
      "watchedMovies": 45,
      "favoriteGenres": [
        {"genre": "Action", "count": 18},
        {"genre": "Comedy", "count": 12}
      ]
    },
    "trends": {
      "monthlyReviews": [
        {"month": "2025-01", "count": 12},
        {"month": "2025-02", "count": 15}
      ],
      "ratingDistribution": {
        "1": 2,
        "2": 3,
        "3": 8,
        "4": 25,
        "5": 29
      }
    },
    "insights": [
      "You tend to rate action movies higher",
      "Your reviews are generally positive",
      "You watch more movies in winter months"
    ]
  }
}
```

## 5. 外部API連携

### 5.1 TMDb API

#### 5.1.1 映画情報取得
```http
GET https://api.themoviedb.org/3/movie/popular
```

**Headers:**
```http
Authorization: Bearer {TMDB_API_KEY}
```

#### 5.1.2 映画検索
```http
GET https://api.themoviedb.org/3/search/movie
```

### 5.2 Gemini API

#### 5.2.1 感情分析
```http
POST https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent
```

**Request Body:**
```json
{
  "contents": [{
    "parts": [{
      "text": "Analyze the sentiment of this movie review: 'Great movie! Really enjoyed it.'"
    }]
  }]
}
```

### 5.3 Vertex AI API

#### 5.3.1 推薦生成
```http
POST https://us-central1-aiplatform.googleapis.com/v1/projects/{PROJECT_ID}/locations/us-central1/endpoints/{ENDPOINT_ID}:predict
```

## 6. エラーコード一覧

### 6.1 認証エラー
- `AUTH_001`: Invalid or expired token
- `AUTH_002`: Insufficient permissions
- `AUTH_003`: User not found

### 6.2 バリデーションエラー
- `VALID_001`: Required field missing
- `VALID_002`: Invalid field format
- `VALID_003`: Field value out of range

### 6.3 ビジネスロジックエラー
- `BIZ_001`: Review already exists for this movie
- `BIZ_002`: Movie not found in database
- `BIZ_003`: Cannot delete review older than 30 days

### 6.4 システムエラー
- `SYS_001`: Database connection error
- `SYS_002`: External API unavailable
- `SYS_003`: Rate limit exceeded

## 7. レート制限

### 7.1 API制限
- **認証済みユーザー**: 1000 requests/hour
- **未認証ユーザー**: 100 requests/hour
- **レビュー投稿**: 10 posts/hour
- **推薦生成**: 50 requests/hour

### 7.2 制限ヘッダー
```http
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1640995200
```

## 8. バージョニング

### 8.1 APIバージョン管理
- URLパスでバージョン指定: `/v1/api/movies`
- ヘッダーでバージョン指定: `API-Version: v1`

### 8.2 下位互換性
- 新機能追加時は下位互換を維持
- 破壊的変更時は新バージョンを作成
- 旧バージョンは6ヶ月間サポート

## 9. 監視・ログ

### 9.1 APIメトリクス
- レスポンス時間
- エラー率
- リクエスト数
- レート制限違反数

### 9.2 ログ形式
```json
{
  "timestamp": "2025-06-12T05:00:00.000Z",
  "level": "info",
  "method": "GET",
  "path": "/api/movies/popular",
  "userId": "user_uuid",
  "statusCode": 200,
  "responseTime": 156,
  "userAgent": "Mozilla/5.0...",
  "ip": "192.168.1.1"
}
```

## 10. テスト

### 10.1 APIテストツール
- Postman Collection
- Jest テストスイート
- Firebase Emulator Suite

### 10.2 テストカバレッジ
- ユニットテスト: 各エンドポイント
- 統合テスト: エンドツーエンド
- パフォーマンステスト: 負荷テスト