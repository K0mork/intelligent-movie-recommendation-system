# Google OAuth 設定手順書

## 🔐 Google Cloud Console OAuth設定

### 現在の状況
- **Firebase プロジェクト**: movie-recommendation-sys-21b5d
- **本番URL**: https://movie-recommendation-sys-21b5d.web.app
- **認証エラー**: `redirect_uri_mismatch`

### 必要な設定

#### 1. Google Cloud Console にアクセス
1. https://console.cloud.google.com/ にアクセス
2. プロジェクト「movie-recommendation-sys-21b5d」を選択

#### 2. OAuth同意画面設定
1. 左メニュー → 「APIs & Services」→ 「OAuth consent screen」
2. 「承認済みドメイン」に以下を追加：
   ```
   movie-recommendation-sys-21b5d.web.app
   firebaseapp.com
   ```

#### 3. OAuth 2.0 クライアントID設定
1. 左メニュー → 「APIs & Services」→ 「Credentials」
2. 既存のOAuth 2.0クライアントIDを編集
3. 「承認済みのリダイレクトURI」に以下を追加：
   ```
   https://movie-recommendation-sys-21b5d.web.app/__/auth/handler
   https://movie-recommendation-sys-21b5d.firebaseapp.com/__/auth/handler
   ```

### 設定後の確認
1. 本番サイトでGoogleサインインボタンをクリック
2. エラーなくGoogle認証画面が表示されることを確認
3. 認証完了後、正常にリダイレクトされることを確認

### トラブルシューティング
- 設定変更後、反映まで数分かかる場合があります
- キャッシュクリアが必要な場合があります
- Firebase コンソールでの設定確認も推奨

### 完了後の機能
- ✅ Googleアカウントでのサインイン
- ✅ プロフィール情報の取得
- ✅ Firebase Authentication 連携
- ✅ レビュー機能のフル活用
- ✅ AI推薦機能の利用