# 本番リリース前 必須修正事項

## 🎯 **修正優先度別リスト**

### 🔴 **最重要 - 本番リリース前に必須**

#### 1. サンプル推薦システムの置換
**影響度**: ★★★★★ (システムの核心機能)  
**工数**: 2-3時間  
**ファイル**: `lib/features/recommendations/data/datasources/recommendation_remote_datasource.dart`

**現在の問題**:
```dart
// 56-119行: 仮実装
Future<List<RecommendationModel>> generateRecommendations(String userId) async {
  // 開発中のため、一時的にサンプル推薦を生成
  // （Cloud Functionsのデプロイには有料プランが必要）
  final sampleRecommendations = _generateSampleRecommendations(userId);
  return sampleRecommendations;
}
```

**修正内容**:
```dart
Future<List<RecommendationModel>> generateRecommendations(String userId) async {
  try {
    final result = await functions
        .httpsCallable('generateRecommendations')
        .call({'userId': userId});
    
    return (result.data as List)
        .map((item) => RecommendationModel.fromMap(item))
        .toList();
  } catch (e) {
    throw Exception('AI推薦の生成に失敗しました: $e');
  }
}
```

**削除が必要な部分**:
- `_generateSampleRecommendations()`メソッド (78-119行)
- サンプルデータの固定配列

**前提条件**:
- Firebase有料プランへのアップグレード
- Cloud Functions の本番デプロイ

---

#### 2. 設定画面の実装
**影響度**: ★★★☆☆ (ユーザビリティ)  
**工数**: 1-2時間  
**ファイル**: 複数ファイル

**現在の問題**:
```dart
// lib/main.dart:151
onTap: () {
  Navigator.pop(context);
  // TODO: 設定画面に遷移  ← 未実装
},
```

**修正オプション A - 最小実装**:
```dart
onTap: () {
  Navigator.pop(context);
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => const SettingsPage(),
    ),
  );
},
```

**修正オプション B - 一時的無効化**:
```dart
// 一時的に設定ボタンを無効化
onTap: _isSettingsAvailable ? () {
  Navigator.pop(context);
  // 設定画面への遷移
} : null,
```

**影響箇所**:
- `lib/main.dart:151`
- `lib/features/auth/presentation/pages/profile_page.dart:26, 293`
- `lib/features/auth/presentation/pages/sign_in_page.dart:124`

### 🟡 **中程度 - 品質向上のため推奨**

#### 3. 管理者アカウントの初期設定
**影響度**: ★★☆☆☆ (管理機能)  
**工数**: 30分  
**ファイル**: `functions/src/index.ts` (581-587行)

**現在の実装**:
```typescript
if (!userData?.isAdmin) {
  throw new functions.https.HttpsError('permission-denied', '管理者権限が必要です。');
}
```

**必要な作業**:
1. 初期管理者アカウントのFirestoreでの設定
```javascript
// Firestoreで管理者フラグを設定
db.collection('users').doc('admin-user-id').set({
  isAdmin: true,
  // その他のユーザー情報
});
```

#### 4. 環境変数の存在確認強化
**影響度**: ★★☆☆☆ (エラー対応)  
**工数**: 30分  

**推奨する改善**:
```dart
// 起動時の環境変数チェック
void validateEnvironmentVariables() {
  final requiredVars = ['TMDB_API_KEY', 'FIREBASE_PROJECT_ID'];
  final missing = requiredVars.where((key) => 
    EnvConfig.getValue(key).isEmpty
  ).toList();
  
  if (missing.isNotEmpty) {
    throw Exception('環境変数が設定されていません: ${missing.join(', ')}');
  }
}
```

### 🟢 **低優先度 - 将来的な改善**

#### 5. パフォーマンス最適化
- 大量データ処理時の最適化
- 画像キャッシュの改善
- JavaScript バンドルサイズの最適化

#### 6. 監視機能の強化
- 詳細なエラーログシステム
- パフォーマンス監視の自動化
- ユーザー行動分析の強化

---

## 📋 **修正作業チェックリスト**

### Phase 1: 必須修正 (3-4時間)
- [ ] Firebase有料プランへのアップグレード
- [ ] サンプル推薦システムの削除
- [ ] Cloud Functions推薦システムへの切り替え
- [ ] 設定画面の基本実装 (最低限)
- [ ] 各TODO箇所の修正

### Phase 2: 品質向上 (1-2時間)
- [ ] 管理者アカウントの初期設定
- [ ] 環境変数チェック機能の追加
- [ ] エラーハンドリングの強化

### Phase 3: 最終確認 (1時間)
- [ ] 修正箇所の動作確認
- [ ] 全機能テスト
- [ ] パフォーマンステスト

---

## 🚀 **修正後の期待効果**

### 修正前の状況
- ❌ AI推薦が固定のサンプルデータ
- ❌ 設定ボタンが機能しない
- ⚠️ 一部の管理機能が未完成

### 修正後の状況
- ✅ 本物のAI推薦システムが動作
- ✅ ユーザーが設定画面にアクセス可能
- ✅ 管理機能が完全に利用可能
- ✅ 本番環境での安定した動作

---

## 📞 **緊急時の対応**

修正作業中に問題が発生した場合：

1. **推薦システム修正時の問題**
   - Cloud Functions のデプロイエラー
   - Gemini API の接続エラー
   → サンプルシステムのバックアップを一時的に復活

2. **設定画面実装時の問題**
   - ナビゲーション関連のエラー
   → ボタンの一時的無効化で対応

3. **緊急時の連絡先**
   - 開発者: [連絡先を記載]
   - Firebase サポート: [サポートページURL]

---

**最終更新**: 2025年6月17日  
**推定総作業時間**: 5-7時間  
**リリース準備完了予定**: 修正完了後 24時間以内