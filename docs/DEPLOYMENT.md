# 本番環境デプロイメントガイド

## プロジェクト概要

**インテリジェント映画レコメンドシステム**の本番環境へのデプロイメント手順書です。
このドキュメントは、開発フェーズ5・6が完了した状態から、本番環境での運用開始まで必要な作業をまとめています。

## 現在の開発状況

### ✅ 完了済み機能
- **基盤構築**: Flutter Web + Firebase統合
- **認証システム**: Google認証 + 匿名認証
- **映画データ**: TMDb API統合
- **レビューシステム**: 完全CRUD操作 + 鑑賞日機能
- **AI推薦システム**: Cloud Functions + Gemini API
- **UI/UX最適化**: アニメーション、エラーハンドリング、アクセシビリティ
- **テストスイート**: 統合テスト、ウィジェットテスト、アクセシビリティテスト

### 📊 プロジェクト規模
- **Dartファイル数**: 96ファイル
- **主要機能**: 認証、映画検索、レビュー、AI推薦
- **アーキテクチャ**: クリーンアーキテクチャ + Riverpod

## ⚠️ **本番リリース前の必須修正事項**

### 🚨 **重要**: サンプル推薦システムの置換
**ファイル**: `lib/features/recommendations/data/datasources/recommendation_remote_datasource.dart` (56-119行)

現在、Cloud Functions推薦システムが実装済みですが、無料プランの制限により一時的にサンプルデータを返すシステムになっています。

```dart
// 現在の仮実装（削除必要）
Future<List<RecommendationModel>> generateRecommendations(String userId) async {
  // 開発中のため、一時的にサンプル推薦を生成
  final sampleRecommendations = _generateSampleRecommendations(userId);
  return sampleRecommendations;
}
```

**修正手順**:
1. Firebase有料プランへのアップグレード
2. Cloud Functions推薦システムへの切り替え
3. サンプル生成メソッド `_generateSampleRecommendations()` の削除

### 🔧 **設定画面の実装**
**ファイル**: 複数ファイル (4箇所のTODOコメント)

設定画面への遷移が未実装のため、ユーザーが設定ボタンを押しても反応しません。

**修正が必要な箇所**:
- `lib/main.dart:151` - メインナビゲーション
- `lib/features/auth/presentation/pages/profile_page.dart:26, 293` - プロフィール画面
- `lib/features/auth/presentation/pages/sign_in_page.dart:124` - サインイン画面

## 本番環境ローンチ必須作業

### 1. 環境設定・セキュリティ 🔐

#### 1.1 本番用Firebase設定
```bash
# 1. 本番用Firebaseプロジェクト作成
firebase projects:create movie-recommend-prod

# 2. FlutterFireの本番設定
flutterfire configure --project=movie-recommend-prod

# 3. 本番用環境変数設定
cp .env.example .env.prod
```

#### 1.2 環境変数の本番設定
```bash
# .env.prod ファイルの必須設定項目
FIREBASE_API_KEY=本番用_firebase_api_key
FIREBASE_PROJECT_ID=movie-recommend-prod
TMDB_API_KEY=本番用_tmdb_api_key
GOOGLE_CLOUD_PROJECT_ID=movie-recommend-prod
VERTEX_AI_REGION=asia-northeast1
```

#### 1.3 セキュリティルールの最終確認
- **Firestore Rules**: `/firestore.rules` の本番適用
- **Firebase Auth**: 本番ドメインの承認設定
- **CORS設定**: 本番URLの許可リスト

### 2. ビルド最適化 🚀

#### 2.1 Flutter Web本番ビルド
```bash
# 1. 依存関係の最新化
flutter pub upgrade

# 2. 本番用ビルド実行
flutter build web --release --web-renderer html

# 3. ビルド成果物確認
ls -la build/web/
```

#### 2.2 パフォーマンス最適化
```bash
# ビルドサイズ分析
flutter build web --analyze-size

# JavaScript圧縮確認
gzip -9 build/web/main.dart.js
```

### 3. Cloud Functions デプロイ ☁️

#### 3.1 Functions依存関係の確認
```bash
cd functions/
npm install
npm run build
```

#### 3.2 本番環境へのデプロイ
```bash
# 本番用Functions設定
firebase use movie-recommend-prod

# Functionsデプロイ
firebase deploy --only functions

# 環境変数設定
firebase functions:config:set gemini.api_key="本番用_api_key"
```

### 4. Firebase Hosting デプロイ 🌐

#### 4.1 Hosting設定の確認
```json
// firebase.json の hosting設定確認
{
  "hosting": {
    "public": "build/web",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    "rewrites": [{"source": "**", "destination": "/index.html"}],
    "headers": [
      {
        "source": "**/*.@(js|css)",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "max-age=31536000"
          }
        ]
      }
    ]
  }
}
```

#### 4.2 本番デプロイ実行
```bash
# 1. 全体デプロイ
firebase deploy

# 2. または個別デプロイ
firebase deploy --only hosting
firebase deploy --only firestore:rules
firebase deploy --only functions
```

### 5. ドメイン・SSL設定 📡

#### 5.1 カスタムドメイン設定（オプション）
```bash
# Firebase Hostingにカスタムドメイン追加
firebase hosting:sites:create movie-recommend-app
firebase target:apply hosting prod movie-recommend-app
```

#### 5.2 SSL証明書の自動設定
- Firebase Hostingは自動でSSL証明書を提供
- カスタムドメインの場合、DNS設定が必要

### 6. 監視・分析設定 📊

#### 6.1 Firebase Analytics設定
```dart
// main.dartでAnalytics有効化
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
```

#### 6.2 パフォーマンス監視
```bash
# Firebase Performance Monitoring有効化
firebase experiments:enable webframeworks
```

### 7. 本番テスト・検証 ✅

#### 7.1 機能テスト項目
- [ ] Google認証フロー
- [ ] 匿名認証フロー
- [ ] 映画検索・表示
- [ ] レビュー投稿・編集・削除
- [ ] AI推薦システム
- [ ] レスポンシブデザイン
- [ ] アクセシビリティ
- [ ] パフォーマンス（Lighthouse スコア 90+）

#### 7.2 本番環境での動作確認
```bash
# ローカルでの本番ビルドテスト
flutter build web --release
cd build/web && python3 -m http.server 8000

# Firebase Hosting Preview
firebase hosting:channel:deploy preview
```

### 8. ドキュメント・サポート準備 📚

#### 8.1 ユーザー向けドキュメント
- [ ] ユーザーガイドの作成
- [ ] FAQ・トラブルシューティング
- [ ] プライバシーポリシー
- [ ] 利用規約

#### 8.2 運用ドキュメント
- [ ] 障害対応手順書
- [ ] データバックアップ手順
- [ ] セキュリティインシデント対応
- [ ] パフォーマンス監視手順

## デプロイメント チェックリスト

### 事前準備
- [ ] 本番用Firebaseプロジェクト作成
- [ ] 本番用API キー取得・設定
- [ ] 環境変数の本番設定完了
- [ ] セキュリティルールの本番適用

### ビルド・デプロイ
- [ ] Flutter Web 本番ビルド成功
- [ ] Cloud Functions デプロイ成功
- [ ] Firebase Hosting デプロイ成功
- [ ] ドメイン・SSL設定完了

### テスト・検証
- [ ] 全機能の動作確認
- [ ] パフォーマンステスト実施
- [ ] セキュリティテスト実施
- [ ] アクセシビリティテスト実施

### 運用準備
- [ ] 監視・分析設定完了
- [ ] ドキュメント整備完了
- [ ] サポート体制確立
- [ ] 障害対応手順確認

## 推定作業時間

| 作業項目 | 所要時間 | 備考 |
|---------|----------|------|
| 環境設定・セキュリティ | 2-3時間 | API キー取得、設定ファイル更新 |
| ビルド最適化 | 1-2時間 | ビルド設定調整、サイズ最適化 |
| Cloud Functions デプロイ | 1時間 | Functions設定、環境変数設定 |
| Firebase Hosting デプロイ | 30分 | Hosting設定、デプロイ実行 |
| ドメイン・SSL設定 | 1-2時間 | カスタムドメイン設定時 |
| 監視・分析設定 | 1時間 | Analytics、Performance設定 |
| 本番テスト・検証 | 2-3時間 | 全機能テスト、パフォーマンス確認 |
| ドキュメント準備 | 3-4時間 | ユーザーガイド、運用手順作成 |

**合計推定時間**: 11-16時間

## 次のステップ

本デプロイメントガイドに従って作業を進め、以下の順序で実施することを推奨します：

1. **環境設定**: 本番用Firebase・API設定
2. **ビルド**: Flutter Web本番ビルド
3. **デプロイ**: Firebase Hosting・Functions
4. **テスト**: 本番環境での動作確認
5. **監視**: Analytics・Performance設定
6. **ドキュメント**: ユーザーガイド・運用手順

デプロイ完了後は、継続的な監視と改善により、安定したサービス運用を実現できます。