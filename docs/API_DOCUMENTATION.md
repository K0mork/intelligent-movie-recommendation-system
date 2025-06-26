# 📚 API ドキュメント (v2.0.0)

## 概要

インテリジェント映画レコメンドシステム「FilmFlow」のAPI仕様書です。このドキュメントは、現在のソースコードに基づいた最新の仕様を反映しています。

## 🔧 アーキテクチャ

- **Cloud Functions for Firebase**: バックエンドロジックはすべてTypeScriptで実装されたサーバーレス関数です。
- **呼び出し方式**: APIはRESTエンドポイントではなく、**Firebase Callable Functions** として提供されます。クライアント（Web/Mobileアプリ）はFirebase SDKを通じて各関数を直接呼び出します。
- **Firebase Authentication**: ユーザー認証を管理します。Callable Functionsは呼び出し時に自動的にユーザーの認証情報を検証します。
- **Cloud Firestore**: アプリケーションのメインデータベースとして使用されます。
- **Google Gemini API**: レビュー分析や推薦理由の生成などのAI機能に使用されます。

### クライアントでの呼び出し例 (JavaScript)

```javascript
import { getFunctions, httpsCallable } from "firebase/functions";

const functions = getFunctions();
const searchMovies = httpsCallable(functions, 'searchMovies');

try {
  const result = await searchMovies({ query: 'Inception', page: 1 });
  const movies = result.data.movies;
  console.log(movies);
} catch (error) {
  console.error("Error calling searchMovies:", error);
}
```

## 📋 API関数一覧

### 👤 認証 (Auth)

`authHandlers.ts` で定義されています。

- **`getUserProfile`**: 呼び出し元ユーザーのプロフィール情報を取得します。
- **`updateUserProfile`**: ユーザーのプロフィール情報（表示名、設定など）を更新します。
- **`exportUserData`**: ユーザーに関連する全データをエクスポートする非同期タスクを開始します。
- **`deleteUserAccount`**: ユーザーアカウントと関連データをすべて削除します。

### 🎬 映画 (Movies)

`movieHandlers.ts` で定義されています。

- **`searchMovies`**: キーワードで映画を検索します。
- **`getPopularMovies`**: 現在の人気映画一覧を取得します。
- **`getMoviesByGenre`**: 指定されたジャンルの映画一覧を取得します。
- **`getMovieDetails`**: 特定の映画の詳細情報を取得します。
- **`getSimilarMovies`**: 特定の映画に類似した映画を取得します。
- **`getMovieStats`**: 映画に関する統計情報（レビュー数など）を取得します。
- **`getMovieTrends`**: 最近のトレンド映画を取得します。
- **`getNewReleases`**: 最新のリリース作品を取得します。
- **`initializeSampleMovies`**: (開発用) サンプル映画データをDBに投入します。

### ⭐ レビュー (Reviews)

`reviewHandlers.ts` で定義されています。

- **`analyzeReviewWithService`**: 投稿されたレビューをAIで分析します。（`onReviewCreated`トリガーから呼び出されるのが主）
- **`getReviewAnalysis`**: 特定のレビューの分析結果を取得します。
- **`getUserPreferences`**: ユーザーのレビュー履歴から推測される好みを返します。
- **`getUserReviewStats`**: ユーザーのレビューに関する統計情報（平均評価など）を取得します。
- **`addReviewComment`**: レビューに対してコメントを追加します。
- **`getReviewComments`**: 特定のレビューに紐づくコメント一覧を取得します。
- **`batchUpdateReviewAnalysis`**: (管理用) 複数のレビューをまとめて再分析します。
- **`onReviewCreated` (Firestoreトリガー)**: 新しいレビューが作成された際に自動的に `analyzeReviewWithService` を実行します。

### 🤖 推薦 (Recommendations)

`recommendationHandlers.ts` で定義されています。

- **`generatePersonalizedRecommendations`**: ユーザーにパーソナライズされた映画の推薦リストを生成します。
- **`getSavedRecommendations`**: ユーザーが保存した推薦リストを取得します。
- **`recordRecommendationFeedback`**: 推薦結果に対するユーザーからのフィードバック（役に立ったかなど）を記録します。
- **`updateRecommendationSettings`**: 推薦の生成に関するユーザー設定（好みのジャンルなど）を更新します。
- **`getRecommendationExplanation`**: なぜその映画が推薦されたのか、理由を説明します。
- **`getSimilarUserRecommendations`**: 類似した嗜好を持つ他のユーザーが高く評価した映画を推薦します。
- **`getTrendingRecommendations`**: 現在、他のユーザーの間で話題になっている映画を推薦します。
- **`getRecommendationStats`**: 推薦システムのパフォーマンスに関する統計情報を取得します。
- **`retrainRecommendationModel`**: (管理用) 推薦モデルの再学習プロセスを開始します。

### 🔧 システム (System)

`index.ts` で定義されています。

- **`healthCheck`**: APIサーバーの稼働状況を確認するためのエンドポイントです。HTTP GETリクエストでアクセス可能です。
- **`cleanupDatabase` (Pub/Subトリガー)**: 24時間ごとに実行され、古いログなどの不要なデータをDBから削除します。

### 🗑️ 非推奨 (Legacy)

古いクライアントとの互換性のために残されていますが、新規開発での使用は推奨されません。

- **`analyzeReview`**: `analyzeReviewWithService` の古いバージョンです。
- **`getRecommendations`**: `generatePersonalizedRecommendations` の古いバージョンです。

## 🚨 エラーハンドリング

Callable Functionsでは、エラーは例外としてクライアントに返されます。エラーオブジェクトには `code` と `message` プロパティが含まれます。

### 主なエラーコード

| code | 説明 |
|---|---|
| `unauthenticated` | ユーザーが認証されていません。 |
| `permission-denied` | 呼び出し元に操作の権限がありません。 |
| `not-found` | 要求されたリソースが見つかりません。 |
| `invalid-argument` | 関数に渡された引数が無効です。 |
| `internal` | サーバー内部で予期せぬエラーが発生しました。 |
