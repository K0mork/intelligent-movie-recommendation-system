# 📚 API ドキュメント

## 概要

インテリジェント映画レコメンドシステムのAPI仕様書です。

## 🔧 技術構成

### バックエンドアーキテクチャ
- **Cloud Functions**: TypeScript実装のサーバーレス関数
- **Firebase Authentication**: ユーザー認証管理
- **Cloud Firestore**: NoSQLデータベース
- **Google Gemini API**: AI分析エンジン

## 🔐 認証

すべてのAPIエンドポイント（パブリックを除く）は Firebase Authentication トークンが必要です。

```typescript
// リクエストヘッダー例
headers: {
  'Authorization': 'Bearer ${idToken}',
  'Content-Type': 'application/json'
}
```

## 📋 API エンドポイント

### 🎬 映画API

#### `GET /api/movies/popular`
人気映画の一覧を取得

**パラメータ:**
- `page` (optional): ページ番号 (デフォルト: 1)
- `limit` (optional): 取得件数 (デフォルト: 20)

**レスポンス:**
```json
{
  "movies": [
    {
      "id": 12345,
      "title": "映画タイトル",
      "overview": "映画の概要",
      "posterPath": "/poster.jpg",
      "backdropPath": "/backdrop.jpg",
      "releaseDate": "2023-01-01",
      "voteAverage": 7.5,
      "genres": ["Action", "Adventure"]
    }
  ],
  "totalPages": 100,
  "currentPage": 1
}
```

#### `GET /api/movies/search`
映画検索

**パラメータ:**
- `query` (required): 検索クエリ
- `page` (optional): ページ番号

**レスポンス:**
```json
{
  "movies": [...],
  "totalResults": 250,
  "totalPages": 13,
  "currentPage": 1
}
```

#### `GET /api/movies/{movieId}`
映画詳細情報取得

**レスポンス:**
```json
{
  "id": 12345,
  "title": "映画タイトル",
  "overview": "詳細な映画の概要",
  "runtime": 120,
  "genres": [...],
  "cast": [...],
  "crew": [...],
  "videos": [...],
  "images": [...]
}
```

### ⭐ レビューAPI

#### `POST /api/reviews`
レビュー投稿

**認証**: 必須

**リクエストボディ:**
```json
{
  "movieId": "12345",
  "movieTitle": "映画タイトル",
  "rating": 4.5,
  "comment": "素晴らしい映画でした",
  "watchedDate": "2023-12-01T00:00:00Z"
}
```

**レスポンス:**
```json
{
  "id": "review_id_123",
  "userId": "user_id_456",
  "movieId": "12345",
  "rating": 4.5,
  "comment": "素晴らしい映画でした",
  "watchedDate": "2023-12-01T00:00:00Z",
  "createdAt": "2023-12-01T10:30:00Z",
  "updatedAt": "2023-12-01T10:30:00Z"
}
```

#### `GET /api/reviews/user/{userId}`
ユーザーレビュー一覧取得

**認証**: 必須（自分のレビューのみ）

**レスポンス:**
```json
{
  "reviews": [
    {
      "id": "review_id_123",
      "movieId": "12345",
      "movieTitle": "映画タイトル",
      "rating": 4.5,
      "comment": "素晴らしい映画でした",
      "watchedDate": "2023-12-01T00:00:00Z",
      "createdAt": "2023-12-01T10:30:00Z"
    }
  ],
  "totalCount": 25
}
```

#### `PUT /api/reviews/{reviewId}`
レビュー編集

**認証**: 必須（レビュー作成者のみ）

**リクエストボディ:**
```json
{
  "rating": 5.0,
  "comment": "更新されたレビュー内容",
  "watchedDate": "2023-12-01T00:00:00Z"
}
```

#### `DELETE /api/reviews/{reviewId}`
レビュー削除

**認証**: 必須（レビュー作成者のみ）

### 🤖 AI推薦API

#### `POST /api/recommendations/analyze`
レビュー分析実行

**認証**: 必須

**リクエストボディ:**
```json
{
  "reviewId": "review_id_123"
}
```

**レスポンス:**
```json
{
  "analysisId": "analysis_id_456",
  "sentiment": {
    "score": 0.8,
    "magnitude": 0.9,
    "overall": "positive"
  },
  "preferences": {
    "genres": ["Action", "Adventure"],
    "themes": ["heroic", "adventure"],
    "mood": "uplifting"
  },
  "status": "completed"
}
```

#### `GET /api/recommendations/user/{userId}`
ユーザー向け推薦取得

**認証**: 必須

**レスポンス:**
```json
{
  "recommendations": [
    {
      "movieId": "67890",
      "movieTitle": "推薦映画",
      "score": 0.95,
      "reasons": [
        "アクション映画がお気に入りのようです",
        "冒険テーマの作品を高く評価しています"
      ],
      "confidence": 0.85
    }
  ],
  "generatedAt": "2023-12-01T15:00:00Z",
  "basedOnReviews": 15
}
```

#### `POST /api/recommendations/feedback`
推薦フィードバック送信

**認証**: 必須

**リクエストボディ:**
```json
{
  "recommendationId": "rec_id_789",
  "feedback": "helpful", // "helpful" | "not_helpful" | "irrelevant"
  "reason": "とても良い推薦でした"
}
```

### 👤 ユーザープロフィールAPI

#### `GET /api/profile`
ユーザープロフィール取得

**認証**: 必須

**レスポンス:**
```json
{
  "userId": "user_id_456",
  "displayName": "ユーザー名",
  "email": "user@example.com",
  "photoURL": "https://example.com/avatar.jpg",
  "preferences": {
    "favoriteGenres": ["Action", "Sci-Fi"],
    "preferredRating": "PG-13",
    "language": "ja"
  },
  "stats": {
    "totalReviews": 25,
    "averageRating": 4.2,
    "favoriteGenres": ["Action", "Adventure"]
  }
}
```

## 📊 データモデル

### Movie (映画)
```typescript
interface Movie {
  id: number;
  title: string;
  overview: string;
  posterPath?: string;
  backdropPath?: string;
  releaseDate: string;
  voteAverage: number;
  genres: string[];
  runtime?: number;
  originalLanguage: string;
}
```

### Review (レビュー)
```typescript
interface Review {
  id: string;
  userId: string;
  movieId: string;
  movieTitle: string;
  rating: number; // 1-5
  comment?: string;
  watchedDate?: Date;
  createdAt: Date;
  updatedAt: Date;
}
```

### Recommendation (推薦)
```typescript
interface Recommendation {
  id: string;
  userId: string;
  movieId: string;
  score: number; // 0-1
  reasons: string[];
  confidence: number; // 0-1
  basedOnReviews: string[];
  generatedAt: Date;
}
```

### AIAnalysis (AI分析)
```typescript
interface AIAnalysis {
  id: string;
  reviewId: string;
  sentiment: {
    score: number; // -1 to 1
    magnitude: number; // 0 to 1
    overall: 'positive' | 'negative' | 'neutral';
  };
  preferences: {
    genres: string[];
    themes: string[];
    mood: string;
  };
  processedAt: Date;
}
```

## 🚨 エラーハンドリング

### エラーレスポンス形式
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "入力データが無効です",
    "details": {
      "field": "rating",
      "reason": "1-5の範囲で入力してください"
    }
  },
  "timestamp": "2023-12-01T10:30:00Z"
}
```

### エラーコード一覧

| コード | 説明 | HTTPステータス |
|--------|------|----------------|
| `UNAUTHORIZED` | 認証が必要 | 401 |
| `FORBIDDEN` | 権限不足 | 403 |
| `NOT_FOUND` | リソースが見つからない | 404 |
| `VALIDATION_ERROR` | 入力検証エラー | 400 |
| `RATE_LIMIT_EXCEEDED` | レート制限超過 | 429 |
| `INTERNAL_ERROR` | サーバー内部エラー | 500 |
| `SERVICE_UNAVAILABLE` | サービス利用不可 | 503 |

## 📈 レート制限

| エンドポイント | 制限 |
|---------------|------|
| 映画検索 | 100リクエスト/分 |
| レビュー投稿 | 10リクエスト/分 |
| AI分析 | 20リクエスト/時間 |
| 推薦取得 | 50リクエスト/時間 |

## 🔧 開発・テスト用

### ローカル開発
```bash
# Cloud Functions エミュレーター起動
firebase emulators:start --only functions

# ベースURL
http://localhost:5001/movie-recommendation-sys-21b5d/us-central1
```

### テスト用APIキー
テスト環境では以下のプレフィックスを持つAPIキーを使用：
```
test_api_key_xxxxx
```

## 📝 変更履歴

### v1.0.0 (2023-12-01)
- 初回リリース
- 基本的な映画・レビュー・推薦API実装

### v1.1.0 (予定)
- Cloud Functionsデプロイ対応
- パフォーマンス最適化
- 詳細なエラーハンドリング

---

## 📞 サポート

APIに関する質問や問題は以下で報告してください：
- **GitHub Issues**: プロジェクトのIssuesページ
- **ドキュメント**: [API設計書](./API_DESIGN.md)
