# FilmFlow: インテリジェント映画レコメンドシステム

[![Security Scan](https://github.com/your-repo/filmflow/actions/workflows/security-scan.yml/badge.svg)](https://github.com/your-repo/filmflow/actions/workflows/security-scan.yml)

**FilmFlow** は、AIを活用してユーザーに最適な映画を推薦する、クロスプラットフォーム対応のアプリケーションです。FlutterとFirebaseを駆使し、モダンで高速なユーザー体験を提供します。

## ✨ 主な機能

- **AIによるレビュー分析**: ユーザーが投稿したレビューをGoogleのGemini APIが分析し、個人の好み（ジャンル、テーマ、ムード）を詳細に把握します。
- **パーソナライズド推薦**: AIの分析結果に基づき、一人ひとりのユーザーに最適化された映画を推薦します。
- **多彩な検索機能**: 人気作品、トレンド、ジャンル別など、様々な切り口で映画を検索できます。
- **クロスプラットフォーム**: Flutterを採用し、iOSとAndroidの両方でネイティブアプリとして動作します。
- **セキュアな認証**: Firebase Authenticationによる安全なユーザー登録・ログイン機能を提供します。

## 🔧 技術スタック

| カテゴリ | 技術 |
|---|---|
| **フロントエンド** | Flutter (Dart) |
| **バックエンド** | Cloud Functions for Firebase (TypeScript) |
| **データベース** | Cloud Firestore |
| **認証** | Firebase Authentication |
| **AI / ML** | Google Gemini API |
| **CI/CD** | GitHub Actions |

## 🚀 セットアップ手順

### 前提条件

- Flutter SDK
- Firebase CLI
- Node.js (npm)
- Java Development Kit (JDK)

### 1. プロジェクトのクローン

```bash
git clone https://github.com/your-repo/filmflow.git
cd filmflow
```

### 2. フロントエンド (Flutter) の設定

```bash
# 依存パッケージのインストール
fvm flutter pub get

# Firebaseプロジェクトの設定ファイルを配置
# (Firebaseコンソールからダウンロードした google-services.json と GoogleService-Info.plist を配置)
cp path/to/your/google-services.json android/app/
cp path/to/your/GoogleService-Info.plist ios/Runner/

# コード生成の実行
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. バックエンド (Cloud Functions) の設定

```bash
# functionsディレクトリに移動
cd functions

# 依存パッケージのインストール
npm install

# 環境変数の設定
# .env.example をコピーして .env ファイルを作成し、APIキーなどを設定
cp .env.example .env
```

### 4. Firebaseエミュレータの起動

ローカルでの開発・テストにはFirebase Local Emulator Suiteを使用します。

```bash
# プロジェクトルートに戻る
cd ..

# エミュレータを起動
firebase emulators:start
```

### 5. アプリケーションの実行

```bash
# Flutterアプリをデバッグモードで起動
fvm flutter run
```

## ドキュメント

より詳細な情報については、以下のドキュメントを参照してください。

- [**APIドキュメント**](./docs/API_DOCUMENTATION.md)
- [**プロジェクトガイド**](./PROJECT_GUIDE.md)
- [**アーキテクチャ設計**](./docs/ARCHITECTURE.md)
