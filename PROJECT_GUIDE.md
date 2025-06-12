# インテリジェント映画レコメンドシステム  
## Intelligent Movie Recommendation System

---

## 目次
1. プロジェクト概要
2. システム要件
3. 技術スタック
4. アーキテクチャ図とシステム構成
5. 開発・実装フロー
6. 画面構成・UI要件
7. 各機能の詳細仕様
8. AI・レコメンド処理設計
9. セキュリティ・運用要件
10. デプロイとリリース手順
11. ハッカソン提出物準備
12. 参考情報・APIリスト

---

## 1. プロジェクト概要

- **目的**  
  ユーザーの映画レビュー・感想・視聴履歴データをGoogle CloudのAIで解析し，パーソナライズされた映画を推薦するWeb/モバイルアプリケーションを構築する．

- **主な特徴**  
  - ユーザー認証・管理
  - 映画データ自動取得
  - レビュー投稿・管理
  - AI分析による推薦
  - UI/UXの最適化
  - Web & モバイル両対応

---

## 2. システム要件

- **ユーザー要件**
  - Googleアカウント等での認証
  - 映画検索・リストからの選択・登録
  - レビュー・評価・感想の投稿
  - 個人に最適化された推薦映画の閲覧
  - 過去レビューの参照・編集

- **非機能要件**
  - レスポンシブデザイン（PC, タブレット, スマホ）
  - ダークモード対応
  - セキュリティ（認証/認可，HTTPS通信）

---

## 3. 技術スタック

- **フロントエンド**  
  - Flutter（Web/モバイル対応）  
  - 状態管理: Riverpod または Provider

- **バックエンド/クラウド**  
  - Firebase Authentication（ユーザー認証）
  - Cloud Firestore（データ管理）
  - Cloud Functions（サーバーレスAPI、AI処理）
  - Google Cloud Vertex AI / Gemini API（AI分析・推薦）
  - TMDb APIまたはOMDb API（映画情報取得）

---

## 4. アーキテクチャ図とシステム構成

```
[ユーザー]
     |
 [Flutter UI]
     |
     |--(HTTP/REST)--> [Firebase Auth]
     |
     |--(HTTP/REST)--> [Firestore]
     |
     |--(HTTP/REST)--> [Cloud Functions] --+--> [Google Cloud AI（Vertex AI / Gemini）]
                                           |
                                           +--> [外部API（TMDb / OMDb）]
```

- 詳細なフローは「開発・実装フロー」節を参照

---

## 5. 開発・実装フロー

### 0. 事前準備
- Flutter SDKインストール
- Firebase/Google Cloudプロジェクト作成・連携
- TMDb/OMDb APIキー取得

### 1. プロジェクトセットアップ
- Flutterプロジェクト新規作成  
  - `flutter create movie_recommend_app`
- Firebase CLIで連携  
  - `flutterfire configure`

### 2. ユーザー認証実装
- Firebase Authenticationを導入
- GoogleサインインUIの設計・実装

### 3. 映画データベース設計・構築
- TMDb/OMDb APIで映画情報取得（Cloud Functionsで定期バッチ・検索API化）
- Firestoreに映画データ構造を設計・格納

### 4. レビュー機能実装
- 映画個別ページでレビュー投稿・星評価UI
- Firestoreへの保存
- 投稿時にCloud Functions発火→AI分析へ

### 5. AI分析・推薦処理実装
- Cloud FunctionsでGemini/Vertex AI API呼び出し
  - レビュー感情・嗜好分析
  - ユーザープロファイルへ反映
- Vertex AI Recommendationsによる推薦リスト生成
- 推薦結果をFirestoreに保存

### 6. レコメンド表示・UI実装
- Flutterで推薦映画リスト表示画面
- 推薦理由・分析結果の表示
- ジャンル・出演者・評価順などフィルター機能

### 7. UI/UX最適化
- レスポンシブ対応
- ダークモード切り替え
- フィードバック・エラー処理

### 8. デプロイ・公開
- Flutter Webビルド & Firebase Hostingデプロイ
  - `flutter build web`
  - `firebase deploy`

### 9. 提出物準備
- GitHubにコード公開
- Zenn記事執筆（システム解説、アーキテクチャ図、AI活用の工夫など）
- デモ動画作成

---

## 6. 画面構成・UI要件

- **サインイン画面**
  - Googleサインインボタン
- **映画一覧・検索画面**
  - タイトル，ジャンル，年で検索
- **映画詳細画面**
  - 映画情報，レビューリスト，レビュー投稿UI
- **マイページ（ユーザー履歴・レビュー一覧）**
- **推薦映画一覧画面**
  - おすすめ理由の簡易表示
- **分析ダッシュボード**
  - ユーザー嗜好・評価傾向グラフ
- **管理用（管理者・デバッグ）画面（必要なら）**

---

## 7. 各機能の詳細仕様

### 映画情報管理
- 映画情報はTMDb/OMDb APIより取得し，Firestoreにキャッシュ
- 情報項目: タイトル，概要，ポスター画像URL，公開日，ジャンル，出演者等

### レビュー機能
- 各映画ごとにユーザーごとのレビューを登録・編集・削除
- 項目: 星1〜5評価，コメント，投稿日，ユーザーID

### レコメンド機能
- AIによる感想・嗜好分析
- Vertex AI Recommendationsでパーソナライズ推薦リスト生成
- ユーザーのプロファイル情報を随時更新

---

## 8. AI・レコメンド処理設計

- Cloud Functionsにてレビュー投稿をトリガ
  - Gemini APIでコメントの感情/嗜好分析
  - Vertex AI Recommendationsで個別推薦リスト生成
- Firestoreにユーザープロファイル・推薦結果を保存
- 推薦理由や分析内容を簡潔にユーザーへフィードバック

---

## 9. セキュリティ・運用要件

- Firebase Authenticationによる認証必須
- Firestoreのセキュリティルールを厳格に設定
- HTTPS通信強制
- AI APIキーや外部APIキーの安全管理

---

## 10. デプロイとリリース手順

- FlutterプロジェクトWebビルド
  - `flutter build web`
- Firebase Hosting初期化
  - `firebase init hosting`
- デプロイ
  - `firebase deploy`
- モバイルビルドの場合はストア公開手順も記載

---

## 11. ハッカソン提出物準備

- GitHubリポジトリ（READMEに上記内容とセットアップ手順）
- 公開URL（Firebase Hosting等）
- Zenn記事（4,000〜6,000字，アーキテクチャ図含む）
- YouTubeデモ動画（約3分）

---

## 12. 参考情報・APIリスト

- [Flutter 公式](https://flutter.dev/)
- [Firebase 公式](https://firebase.google.com/)
- [Google Cloud Vertex AI](https://cloud.google.com/vertex-ai)
- [Gemini API（Google AI Studio）](https://ai.google.dev/)
- [TMDb API](https://www.themoviedb.org/documentation/api)
- [OMDb API](https://www.omdbapi.com/)
- [Zenn](https://zenn.dev/)

---

## その他・備考

- Cloud Functionsのローカル開発は `firebase emulators:start` 推奨
- コスト・クレジット管理に注意（Google Cloud $300クレジット利用可）
- テストユーザー・サンプルデータの用意
- チーム開発の場合は作業分担やブランチ運用方針も記載

---

# END