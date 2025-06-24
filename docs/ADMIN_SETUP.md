# 管理者アカウント設定ガイド

## 概要

FilmFlow では、一部の管理機能（ユーザー管理、システム設定等）にアクセスするために管理者権限が必要です。このドキュメントでは、初期管理者アカウントの設定方法を説明します。

## 📋 前提条件

- Firebase プロジェクトが作成済み
- Cloud Firestore が有効化済み
- Firebase Admin SDK または Firebase Console へのアクセス権限

## 🔧 設定手順

### 方法1: Firebase Console を使用（推奨）

#### 1. Firebase Console にアクセス
```bash
# Firebase Console を開く
firebase open
```

#### 2. Firestore Database に移動
1. Firebase Console で該当プロジェクトを選択
2. 左メニューから「Firestore Database」を選択
3. 「コレクション」タブを確認

#### 3. 管理者ユーザーのドキュメントを作成/編集

**新規ユーザーの場合:**
```json
// コレクション: users
// ドキュメントID: {管理者のUID}
{
  "email": "admin@example.com",
  "displayName": "管理者",
  "isAdmin": true,
  "createdAt": "2024-12-XX",
  "role": "admin"
}
```

**既存ユーザーの場合:**
```json
// 既存ドキュメントに以下フィールドを追加
{
  "isAdmin": true,
  "role": "admin"
}
```

### 方法2: Firebase CLI を使用

#### 1. Firebase プロジェクトにログイン
```bash
firebase login
firebase use your-project-id
```

#### 2. Node.js スクリプトで設定
```javascript
// admin-setup.js
const admin = require('firebase-admin');

// Firebase Admin SDK を初期化
const serviceAccount = require('./path/to/serviceAccountKey.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function setAdminUser(uid, userData) {
  try {
    await db.collection('users').doc(uid).set({
      ...userData,
      isAdmin: true,
      role: 'admin'
    }, { merge: true });

    console.log(`✅ 管理者権限を付与しました: ${uid}`);
  } catch (error) {
    console.error('❌ エラー:', error);
  }
}

// 使用例
setAdminUser('user-uid-here', {
  email: 'admin@example.com',
  displayName: '管理者'
});
```

### 方法3: アプリケーション内で設定（開発時のみ）

#### 1. 一時的な管理者作成機能
```dart
// 開発環境でのみ使用（本番では削除）
Future<void> createTempAdmin(String uid) async {
  if (kDebugMode) {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set({
      'isAdmin': true,
      'role': 'admin',
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
```

## 🔐 セキュリティ設定

### Firestore セキュリティルール

管理者権限をチェックするルールが既に設定されています：

```javascript
// firestore.rules（既存設定）
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 管理者チェック関数
    function isAdmin() {
      return request.auth != null &&
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }

    // 管理者のみアクセス可能なパス
    match /admin/{document=**} {
      allow read, write: if isAdmin();
    }
  }
}
```

### Cloud Functions での管理者チェック

```typescript
// functions/src/index.ts（既存実装）
export const adminFunction = functions.https.onCall(async (data, context) => {
  // 認証確認
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'ユーザーの認証が必要です。');
  }

  // 管理者権限チェック
  const userId = context.auth.uid;
  const userDoc = await db.collection('users').doc(userId).get();
  const userData = userDoc.data();

  if (!userData?.isAdmin) {
    throw new functions.https.HttpsError('permission-denied', '管理者権限が必要です。');
  }

  // 管理者機能の実行
  // ...
});
```

## ✅ 設定確認

### 1. アプリケーションでの確認
```dart
// ユーザーの管理者権限を確認
Future<bool> checkAdminStatus(String uid) async {
  final userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .get();

  return userDoc.data()?['isAdmin'] == true;
}
```

### 2. Firebase Console での確認
1. Firestore Database を開く
2. `users` コレクションを確認
3. 該当ユーザーのドキュメントで `isAdmin: true` が設定されていることを確認

## 🚨 トラブルシューティング

### よくある問題と解決法

#### 1. 「管理者権限が必要です」エラー
```bash
Error: permission-denied: 管理者権限が必要です。
```

**解決法:**
- ユーザーのFirestoreドキュメントで `isAdmin: true` が設定されているか確認
- UID が正しく設定されているか確認
- Firestore セキュリティルールが正しく適用されているか確認

#### 2. ユーザードキュメントが存在しない
```bash
Error: ユーザードキュメントが見つかりません
```

**解決法:**
```javascript
// Firestore でドキュメントを作成
{
  "email": "user@example.com",
  "displayName": "ユーザー名",
  "isAdmin": true,
  "createdAt": "2024-12-XX"
}
```

#### 3. 権限反映の遅延
**解決法:**
- アプリケーションを再起動
- ブラウザキャッシュをクリア
- Firebase プロジェクトのセキュリティルールを再デプロイ

## 📝 管理者権限の管理

### 権限の追加
```bash
# Firebase Console または CLI で実行
isAdmin: true
role: "admin"
```

### 権限の削除
```bash
# 管理者権限を削除
isAdmin: false
# または
isAdmin: (フィールドを削除)
```

### 一時的な権限付与
```bash
# 期限付き権限（アプリケーション側で実装）
adminUntil: "2024-12-31T23:59:59Z"
```

## 🔄 継続的な管理

### 定期的な確認事項
- [ ] 管理者アカウントの最小限原則
- [ ] 不要になった管理者権限の削除
- [ ] 管理者活動ログの確認
- [ ] セキュリティルールの定期見直し

### 自動化の推奨事項
- 管理者権限変更の通知機能
- 管理者活動のログ記録
- 定期的な権限監査の実装

## 📞 サポート

設定で問題が発生した場合：

1. **Firebase ドキュメント**: https://firebase.google.com/docs/firestore
2. **Cloud Functions ドキュメント**: https://firebase.google.com/docs/functions
3. **プロジェクト固有の設定**: `CLAUDE.md` を参照

---

**最終更新**: 2024年12月
**対象バージョン**: v1.0.0+
**担当**: 開発チーム
