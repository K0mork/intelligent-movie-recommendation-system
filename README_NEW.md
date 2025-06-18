# 🎬 インテリジェント映画レコメンドシステム

AIが分析するパーソナライズ映画推薦システム - Flutter Web アプリケーション

[![Deploy](https://img.shields.io/badge/deploy-firebase-green)](https://movie-recommendation-sys-21b5d.web.app)
[![Flutter](https://img.shields.io/badge/Flutter-3.7.2-blue)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-10.x-orange)](https://firebase.google.com)

## 🌟 概要

このプロジェクトは、ユーザーの映画レビューをAIで分析し、パーソナライズされた映画推薦を提供するインテリジェントシステムです。Flutter Webで構築され、Firebase上でホスティングされています。

**🔗 ライブデモ**: https://movie-recommendation-sys-21b5d.web.app

## ✨ 主な機能

### 🔐 認証システム
- Google サインイン
- 匿名認証（ゲストモード）
- 安全な認証状態管理

### 🎥 映画機能
- TMDb API統合による豊富な映画データベース
- 映画検索・一覧表示
- 詳細な映画情報表示
- レスポンシブデザイン対応

### ⭐ レビューシステム
- 5段階星評価システム
- テキストレビュー投稿
- 鑑賞日記録機能
- レビュー編集・削除
- ユーザーレビュー履歴
- レビュー統計表示

### 🤖 AI推薦システム
- Google Gemini API による感情分析
- ハイブリッド推薦アルゴリズム（コンテンツベース + 協調フィルタリング）
- 推薦理由の詳細説明
- ユーザーフィードバック機能

### 🎨 UI/UX
- Material Design 3準拠
- ダークモード完全対応
- スムーズなアニメーション・トランジション
- アクセシビリティ対応
- スケルトンローディング
- 統一エラーハンドリング

## 🛠️ 技術スタック

| カテゴリ | 技術 |
|---------|------|
| **フロントエンド** | Flutter Web, Material Design 3 |
| **状態管理** | Riverpod |
| **認証** | Firebase Authentication |
| **データベース** | Cloud Firestore |
| **バックエンド** | Cloud Functions (TypeScript) |
| **AI/ML** | Google Gemini API |
| **外部API** | TMDb API |
| **ホスティング** | Firebase Hosting |
| **開発言語** | Dart, TypeScript |

## 🚀 セットアップ手順

### 前提条件
- Flutter SDK 3.7.2以上
- Node.js 18以上
- Firebase CLI
- TMDb APIキー

### 1. プロジェクトのクローン
```bash
git clone <repository-url>
cd movie_recommend_app
```

### 2. 依存関係のインストール
```bash
# Flutter依存関係
flutter pub get

# Cloud Functions依存関係
cd functions
npm install
cd ..
```

### 3. 環境変数の設定
`.env`ファイルをプロジェクトルートに作成:
```bash
# TMDb API
TMDB_API_KEY=your_tmdb_api_key_here
TMDB_BASE_URL=https://api.themoviedb.org/3
```

### 4. Firebase設定
```bash
# Firebase CLIでログイン
firebase login

# Firebaseプロジェクトの設定
firebase use movie-recommendation-sys-21b5d

# Firebase設定の生成
flutterfire configure
```

### 5. 開発サーバーの起動
```bash
# Webアプリの起動
flutter run -d chrome

# Cloud Functionsエミュレーター起動 (別ターミナル)
cd functions
npm run serve
```

## 📱 デプロイ

### 本番環境へのデプロイ
```bash
# Webアプリのビルド
flutter build web --release

# Firebase Hostingへのデプロイ
firebase deploy --only hosting

# Cloud Functionsも含めた全体デプロイ (Blazeプランが必要)
firebase deploy
```

## 🧪 テスト

### テストの実行
```bash
# 全テスト実行
flutter test

# テストカバレッジ生成
flutter test --coverage

# 統合テスト実行
flutter test integration_test/

# パフォーマンステスト実行
flutter test test/performance/

# セキュリティテスト実行
flutter test test/security/
```

### テストカバレッジ
プロジェクトには包括的なテストスイートが含まれています：
- **ユニットテスト**: 9ファイル（認証・映画・レビュー機能）
- **ウィジェットテスト**: 主要コンポーネント
- **統合テスト**: エンドツーエンドのユーザーフロー
- **パフォーマンステスト**: レンダリング性能・メモリ使用量
- **セキュリティテスト**: 入力検証・認証セキュリティ

## 📁 プロジェクト構造

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
├── performance/         # パフォーマンステスト
├── security/           # セキュリティテスト
└── helpers/            # テストヘルパー
```

## 🔧 開発コマンド

```bash
# 開発サーバー起動
flutter run -d chrome

# Web用リリースビルド
flutter build web --release

# テスト実行
flutter test

# コードフォーマット
dart format .

# 静的解析
flutter analyze

# 依存関係更新
flutter pub get

# Cloud Functions開発
cd functions && npm run serve

# Firebase デプロイ
firebase deploy
```

## 🔒 セキュリティ

- **認証**: Firebase Authentication による安全なユーザー認証
- **データ保護**: Firestore Security Rules による適切なアクセス制御
- **通信**: HTTPS通信の強制
- **API保護**: 環境変数による機密情報の管理
- **入力検証**: XSS・SQLインジェクション対策

## 🎯 今後の機能拡張

- [ ] Cloud Functionsのデプロイ (Blazeプランアップグレード後)
- [ ] オフライン対応 (PWA機能強化)
- [ ] SEO最適化
- [ ] ソーシャル機能 (レビュー共有)
- [ ] 多言語対応
- [ ] モバイルアプリ版

## 📋 開発進捗

### ✅ 完了済み (Phase 1-6)
- [x] 基盤構築・Firebase設定
- [x] 認証システム実装
- [x] 映画API統合
- [x] レビューシステム完全実装
- [x] AI推薦システム構築
- [x] UI/UX最適化
- [x] 包括的テストスイート

### 🚀 デプロイ済み (Phase 7)
- [x] Flutter Web ビルド最適化
- [x] Firebase Hosting デプロイ
- [x] パフォーマンス監視設定

## 📞 サポート

問題や質問がある場合は、以下の方法でお問い合わせください：

- **Issues**: GitHubのIssuesページ
- **ドキュメント**: [プロジェクトWiki](./docs/)
- **ライブアプリ**: https://movie-recommendation-sys-21b5d.web.app

## 📄 ライセンス

このプロジェクトはMITライセンスの下で公開されています。

---

**🎬 映画の新しい発見をAIと一緒に。**