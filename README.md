# インテリジェント映画レコメンドシステム

AIを活用したパーソナライズ映画推薦システム。ユーザーのレビューと嗜好をGoogle CloudのAIで分析し、最適な映画を推薦するFlutter Webアプリケーションです。

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-039BE5?style=for-the-badge&logo=Firebase&logoColor=white)
![Google Cloud](https://img.shields.io/badge/GoogleCloud-%234285F4.svg?style=for-the-badge&logo=google-cloud&logoColor=white)

## 🎯 プロジェクト概要

このプロジェクトは、映画愛好家のための AI 駆動型レコメンデーションシステムです。ユーザーが投稿したレビューを Google Cloud の AI サービスで分析し、個々の嗜好に基づいてパーソナライズされた映画推薦を提供します。

### 主な特徴

#### ✅ 実装済み機能
- 🔐 **認証システム**: Google/匿名認証による安全なサインイン
- 🎬 **映画データベース**: TMDb APIからの豊富な映画情報
- 🔍 **映画検索**: タイトル・キーワード検索機能
- 📱 **レスポンシブUI**: PC・タブレット・スマホ完全対応
- 🌙 **ダークモード**: システム設定に応じた自動切り替え
- ⚡ **最適化**: Webスクロール体験・パフォーマンス最適化

#### 🔄 開発中機能
- ⭐ **レビューシステム**: 星評価・コメント投稿機能
- 🤖 **AI分析**: Gemini APIによるレビュー感情・嗜好分析
- 👤 **パーソナライズ推薦**: 個人の嗜好に基づく映画推薦

## 🏗️ アーキテクチャ

### 技術スタック

**フロントエンド**
- Flutter (Web/iOS/Android対応)
- Riverpod (状態管理)
- Material Design 3

**バックエンド/クラウド**
- Firebase Authentication
- Cloud Firestore
- Cloud Functions
- Firebase Hosting

**AI・機械学習**
- Google Cloud Vertex AI
- Gemini API
- 自然言語処理

**外部API**
- TMDb API (映画データ)

### システム構成

```
[Flutter Web Client] ←→ [Firebase Backend] ←→ [External APIs]
       │                        │                    │
   • Riverpod            • Authentication        • TMDb API
   • Material UI         • Firestore            • Gemini API
   • Responsive          • Cloud Functions      • Vertex AI
```

## 📚 ドキュメント

プロジェクトの詳細な設計書は `docs/` フォルダに整理されています：

- [📋 TODO.md](docs/TODO.md) - 開発タスク管理
- [📖 REQUIREMENTS.md](docs/REQUIREMENTS.md) - 機能要件仕様書
- [🏛️ ARCHITECTURE.md](docs/ARCHITECTURE.md) - システムアーキテクチャ設計書
- [🔌 API_DESIGN.md](docs/API_DESIGN.md) - API設計仕様書
- [🎨 UI_SPECIFICATION.md](docs/UI_SPECIFICATION.md) - UI/UX設計仕様書
- [📘 PROJECT_GUIDE.md](PROJECT_GUIDE.md) - プロジェクト全体ガイド
- [⚙️ CLAUDE.md](CLAUDE.md) - 開発環境ガイド

## 🚀 セットアップ・実行方法

### 前提条件

- Flutter SDK (^3.7.2 以上)
- Firebase CLI
- TMDb API キー
- インターネット接続

### 1. リポジトリクローン

```bash
git clone https://github.com/K0mork/intelligent-movie-recommendation-system.git
cd intelligent-movie-recommendation-system
```

### 2. 依存関係インストール

```bash
flutter pub get
```

### 3. Firebase設定

```bash
# Firebase CLI でログイン
firebase login

# FlutterFire CLI で設定
flutterfire configure
```

### 4. 環境変数設定

```bash
# .env ファイルを作成して API キーを設定
echo "TMDB_API_KEY=your_tmdb_api_key" > .env
echo "FIREBASE_CONFIG=your_firebase_config" >> .env
```

### 5. アプリケーション実行

```bash
# Web 版開発サーバー実行
flutter run -d chrome --web-port 3000

# または、ビルドして静的ホスティング
flutter build web --release
cd build/web && python3 -m http.server 3000
```

## 🎮 使い方

### 現在利用可能な機能
1. **認証**: Google/匿名アカウントでサインイン
2. **映画探索**: TMDb APIからの最新・人気映画閲覧
3. **映画検索**: タイトルやキーワードで検索
4. **詳細情報**: 映画のポスター、あらすじ、詳細情報表示
5. **レスポンシブUI**: PC・タブレット・スマホ対応

### 開発中の機能
- **レビュー機能**: 映画への評価・コメント投稿
- **AI分析**: Gemini APIによるレビュー情報分析
- **パーソナライズ推薦**: 個人の嗜好に基づく映画推薦

## 🔧 開発

### プロジェクト構造

```
lib/
├── core/               # 共通設定・ユーティリティ
│   ├── config/         # 環境設定
│   ├── constants/      # アプリケーション定数
│   ├── theme/          # UIテーマ・スタイル設定
│   ├── utils/          # ユーティリティ関数
│   └── errors/         # エラーハンドリング
├── features/           # 機能別実装
│   ├── auth/           # 認証機能 (完成)
│   └── movies/         # 映画機能 (完成)
├── shared/             # 共有コンポーネント
└── main.dart           # アプリケーションエントリーポイント
```

### コード生成

```bash
# JSON serialization コード生成 (必要時)
dart run build_runner build

# ウォッチモードで自動生成
dart run build_runner watch
```

### テスト実行

```bash
# ユニットテスト
flutter test

# ウィジェットテスト
flutter test test/widget_test.dart

# コード解析
flutter analyze
```

## 🤝 コントリビューション

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 ライセンス

このプロジェクトは MIT ライセンスの下で公開されています。詳細は [LICENSE](LICENSE) ファイルを参照してください。

## 👥 作成者

- **Developer**: [K0mork](https://github.com/K0mork)
- **AI Assistant**: Claude Code by Anthropic

## 🙏 謝辞

- [TMDb](https://www.themoviedb.org/) - 映画データ提供
- [Google Cloud](https://cloud.google.com/) - AI・クラウドサービス
- [Firebase](https://firebase.google.com/) - バックエンドインフラ
- [Flutter](https://flutter.dev/) - クロスプラットフォーム開発フレームワーク

---

⭐ このプロジェクトが役に立ったら、Star をつけてください！
