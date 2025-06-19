# CLAUDE.md

必ず日本語で回答すること．
This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is FilmFlow (フィルムフロー) - an Intelligent Movie Recommendation System - a production-ready Flutter web application that uses AI to analyze user movie reviews and provide personalized movie recommendations. The project has completed development phases 1-6 and is ready for deployment.

## Current Status (開発フェーズ6完了 + PRE_LAUNCH修正完了)

### ✅ Completed Features
- **Phase 1-2**: 基盤構築・Firebase認証・映画API統合完了
- **Phase 3**: レビュー機能完全実装（投稿・編集・削除・履歴・統計）
- **Phase 4**: AI分析・推薦システム完全実装（Cloud Functions + Gemini API）
- **Phase 5**: UI/UX最適化完全実装（レスポンシブ・ダークモード・アニメーション）
- **Phase 6**: 包括的テストスイート完成（ユニット・統合・ウィジェットテスト）
- **PRE_LAUNCH**: 本番リリース前修正完了（設定画面・環境変数チェック・管理者設定）

### 🎯 Ready for Production
- Firebase Hosting設定とデプロイ準備完了
- Flutter Web ビルド最適化済み
- パフォーマンス監視設定可能
- 設定画面完全実装済み
- 環境変数バリデーション機能実装済み
- 管理者アカウント設定ガイド完備

## Architecture (実装済み)

- **Frontend**: Flutter Web + Material Design 3
- **State Management**: Riverpod (完全実装)
- **Authentication**: Firebase Authentication (Google/匿名認証)
- **Database**: Cloud Firestore (完全設定済み)
- **Backend**: Cloud Functions (TypeScript)
- **AI/ML**: Google Gemini API (ハイブリッド推薦アルゴリズム)
- **External APIs**: TMDb API (完全統合)

## Development Commands

### Flutter Commands
```bash
# 開発サーバー起動
flutter run -d chrome

# Web用ビルド
flutter build web

# テスト実行
flutter test

# テストカバレッジ生成
flutter test --coverage

# 依存関係更新
flutter pub get
```

### Firebase Commands
```bash
# Cloud Functions開発・デプロイ
cd functions
npm run build
npm run serve
firebase deploy --only functions

# Hosting設定・デプロイ
firebase init hosting
firebase deploy --only hosting

# 全体デプロイ
firebase deploy
```

### Testing Commands
```bash
# 全テスト実行
flutter test

# 統合テスト実行
flutter test integration_test/

# カバレッジレポート生成
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## Project Structure (実装済み)

```
lib/
├── core/                    # 共通機能
│   ├── config/             # 環境設定
│   ├── constants/          # アプリ定数
│   ├── errors/            # エラーハンドリング
│   ├── theme/             # テーマ・スタイル
│   ├── utils/             # ユーティリティ
│   └── widgets/           # 共通ウィジェット
├── features/              # 機能別モジュール
│   ├── auth/              # 認証機能
│   ├── movies/            # 映画機能
│   ├── reviews/           # レビュー機能
│   └── recommendations/   # 推薦機能
└── main.dart             # エントリーポイント

functions/                 # Cloud Functions
├── src/
│   ├── index.ts          # メイン関数
│   └── services/         # AIサービス
└── package.json

test/                     # テストスイート
├── features/            # 機能別テスト
├── integration/         # 統合テスト
└── helpers/            # テストヘルパー
```

## Key Features (実装済み)

### 認証システム
- Google サインイン
- 匿名認証
- 認証状態管理（Riverpod）
- プロフィール画面
- 設定画面（プロフィール編集・表示設定・通知設定・データ管理）

### 映画機能
- TMDb API統合
- 映画検索・一覧表示（年指定検索対応）
- 映画詳細画面
- レスポンシブデザイン
- 年代別フィルタリング機能

### レビューシステム
- 星評価（1-5）
- テキストレビュー
- 鑑賞日記録
- レビュー編集・削除
- ユーザー履歴
- レビュー統計

### AI推薦システム
- Cloud Functions + Gemini API
- ハイブリッド推薦アルゴリズム
- 感情分析
- 推薦理由説明
- ユーザーフィードバック

### UI/UX
- Material Design 3
- ダークモード対応
- アニメーション・トランジション
- アクセシビリティ対応
- スケルトンローディング
- エラーハンドリング

## Environment Variables (.env)

```bash
# TMDb API
TMDB_API_KEY=your_tmdb_api_key
TMDB_BASE_URL=https://api.themoviedb.org/3

# Firebase (自動生成済み)
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_APP_ID=your_app_id
```

### 環境変数バリデーション機能
- 起動時の必須環境変数自動チェック（Firebase、TMDb API）
- オプション環境変数の警告機能（Google Cloud、OMDb API）
- デバッグモードでの詳細設定状況表示
- 本番環境での致命的エラーハンドリング

## Testing Coverage

- **ユニットテスト**: 9ファイル（認証・映画・レビュー）
- **ウィジェットテスト**: 主要コンポーネント
- **統合テスト**: レビューフロー全体
- **セキュリティテスト**: Firestore rules
- **カバレッジ**: lcov.info生成済み

## Security Implementation

- Firebase Authentication必須
- Firestore Security Rules設定済み
- HTTPS通信強制
- API key環境変数管理
- XSS/CSRF対策実装
- 管理者権限システム実装済み（詳細は `docs/ADMIN_SETUP.md` を参照）

## Deployment Ready

- `firebase.json`設定完了
- `firestore.rules`設定完了
- `functions/`デプロイ準備完了
- `build/web/`生成可能
- PWA対応済み

## Deployment & Updates (本番運用)

### 🚀 初回デプロイ完了
- **本番URL**: https://movie-recommendation-sys-21b5d.web.app
- **ステータス**: Phase 7完了済み（2024年12月）

### 🔄 ローカル更新の本番反映手順

#### 1. 開発・テスト
```bash
# ローカル開発
flutter run -d chrome

# テスト実行
flutter test

# 静的解析
flutter analyze
```

#### 2. ビルド・デプロイ
```bash
# 本番ビルド
flutter build web --release

# Firebase Hostingにデプロイ
firebase deploy --only hosting

# Cloud Functions含む全体デプロイ (Blazeプラン必要)
firebase deploy
```

#### 3. デプロイ後確認
```bash
# デプロイ後のURLを開く
firebase open hosting

# または直接アクセス
# https://movie-recommendation-sys-21b5d.web.app
```

### 🔧 継続的デプロイのベストプラクティス

#### 更新前チェックリスト
- [ ] `flutter test` でテスト通過
- [ ] `flutter analyze` でエラーなし
- [ ] `.env` ファイルの環境変数確認
- [ ] ローカルでの動作確認

#### デプロイコマンド例
```bash
# 完全なデプロイワークフロー
flutter clean
flutter pub get
flutter test
flutter build web --release
firebase deploy --only hosting
```

#### ホットフィックス用クイックデプロイ
```bash
# 緊急修正の場合
flutter build web --release && firebase deploy --only hosting
```

### ⚡ 実践的デプロイワークフロー

#### 日常的な開発更新
```bash
# 1. 機能開発・修正
flutter run -d chrome

# 2. テスト実行
flutter test

# 3. ビルド・デプロイ
flutter build web --release
firebase deploy --only hosting

# 4. 動作確認
# https://movie-recommendation-sys-21b5d.web.app にアクセス
```

#### 大規模更新時
```bash
# 1. 完全クリーン
flutter clean
flutter pub get

# 2. 全テスト実行
flutter test
flutter analyze

# 3. 本番ビルド
flutter build web --release

# 4. デプロイ実行
firebase deploy --only hosting

# 5. デプロイ確認
firebase open hosting
```

### 🚨 トラブルシューティング

#### よくある問題と解決法

**ビルドエラー時:**
```bash
flutter clean
flutter pub get
flutter pub deps
flutter build web --release
```

**デプロイエラー時:**
```bash
firebase login
firebase use movie-recommendation-sys-21b5d
firebase deploy --only hosting
```

**キャッシュ問題時:**
```bash
# ブラウザのハードリフレッシュ
# Ctrl+Shift+R (Windows/Linux)
# Cmd+Shift+R (Mac)
```

### 📋 デプロイ履歴管理

#### 現在のバージョン
- **v1.0.0**: 初回本番デプロイ（Phase 1-7完了）
- **デプロイ日時**: 2024年12月
- **機能**: 完全なMVP（認証・映画・レビュー・AI推薦）

#### 今後の更新計画
- **v1.1.0**: Cloud Functions有効化（Blazeプラン後）
- **v1.2.0**: PWA機能強化
- **v1.3.0**: SEO最適化・多言語対応

## Recent Updates (継続的機能追加)

### 🎯 年指定検索機能追加（2025年6月19日）

#### 実装内容
1. **UI/UX改善**
   - MovieSearchDelegateにPopupMenuButtonで年代選択機能を実装
   - 5年間隔での年代選択（1900年〜現在）
   - 年フィルタ状態の視覚的表示とクリア機能
   - 検索結果件数の動的表示

2. **API統合強化**
   - TMDb API: `year`パラメータ対応
   - OMDb API: `y`パラメータ対応
   - クライアント側での年代範囲フィルタリング実装

3. **アーキテクチャ全層対応**
   - DataSource層: MovieRemoteDataSourceにyear引数追加
   - Repository層: MovieRepositoryにyear引数追加
   - UseCase層: SearchMoviesUseCaseにyear引数追加
   - Presentation層: MovieControllerとUIコンポーネント対応

4. **テスト強化**
   - 年指定機能の包括的テストケース追加（4新規テスト）
   - 既存テスト14件すべて通過維持
   - mockファイル自動再生成による型安全性確保

#### 技術的特徴
- **型安全性**: Dart null safetyに完全対応
- **パフォーマンス**: APIとクライアント両方でのフィルタリング最適化
- **拡張性**: 将来的な検索フィルター追加への対応
- **ユーザビリティ**: 直感的な年代選択インターフェース

#### 影響範囲
- **Files Modified**: 11ファイル
- **Lines Added**: 332行追加、110行削除
- **Test Coverage**: 全テスト通過（14/14）
- **Breaking Changes**: なし（既存機能への影響なし）