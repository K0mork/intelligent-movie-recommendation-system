# レビュー感情分析サービス

このサービスは、Gemini APIを使用してユーザーの映画レビューを分析し、感情分析と好み抽出を行います。

## 機能

### 1. 感情分析
- レビューテキストの感情（positive/negative/neutral）を判定
- 感情スコア（-1から1）を算出
- 検出された感情のリストを提供

### 2. 好み抽出
- ユーザーが言及したジャンル、テーマ、俳優、監督を抽出
- キーワード分析による好みの特定

### 3. 分析結果保存
- Firestoreに分析結果を保存
- ユーザーの好み履歴を蓄積・更新

### 4. 自動分析
- レビューが作成されたときの自動トリガー
- バックグラウンドでの分析処理

## 使用方法

### 環境設定
1. `.env.example`を参考に環境変数を設定
2. `GEMINI_API_KEY`にGemini APIキーを設定

### Cloud Functions

#### 1. analyzeReviewWithService
レビューの総合分析を実行

```javascript
const result = await firebase.functions().httpsCallable('analyzeReviewWithService')({
  reviewId: 'review123',
  reviewText: 'この映画は素晴らしかった...',
  movieId: 'movie456',
  movieTitle: 'インセプション'
});
```

#### 2. getReviewAnalysis
分析結果を取得

```javascript
const result = await firebase.functions().httpsCallable('getReviewAnalysis')({
  reviewId: 'review123'
});
```

#### 3. getUserPreferences
ユーザーの好み履歴を取得

```javascript
const result = await firebase.functions().httpsCallable('getUserPreferences')();
```

### Firestoreコレクション構造

#### reviewAnalysis/{reviewId}
```json
{
  "reviewId": "review123",
  "userId": "user456",
  "movieId": "movie789",
  "sentiment": {
    "sentiment": "positive",
    "score": 0.8,
    "emotions": ["excitement", "joy"]
  },
  "preferences": {
    "genres": ["action", "sci-fi"],
    "themes": ["friendship", "technology"],
    "actors": ["Leonardo DiCaprio"],
    "directors": ["Christopher Nolan"],
    "keywords": ["cinematography", "plot twist"]
  },
  "analyzedAt": "2024-01-01T00:00:00Z",
  "confidence": 0.85
}
```

#### userPreferences/{userId}
```json
{
  "genres": {
    "action": 5,
    "sci-fi": 3,
    "drama": 2
  },
  "themes": {
    "friendship": 4,
    "technology": 3
  },
  "actors": {
    "Leonardo DiCaprio": 2,
    "Tom Hanks": 1
  },
  "directors": {
    "Christopher Nolan": 3
  },
  "keywords": {
    "cinematography": 2,
    "plot twist": 1
  },
  "createdAt": "2024-01-01T00:00:00Z",
  "lastUpdated": "2024-01-01T00:00:00Z"
}
```

## エラーハンドリング

- 包括的なエラーログ
- 適切なHTTPステータスコード
- ユーザーフレンドリーなエラーメッセージ
- 自動分析失敗時の安全な処理

## デプロイ

```bash
# 本番環境にデプロイ
npm run deploy

# ローカルエミュレーターで起動
npm run serve
```

## ログ監視

```bash
# Functions のログを確認
npm run logs
```