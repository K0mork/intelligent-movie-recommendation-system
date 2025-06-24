# テスト実行ガイド

このプロジェクトのテストコードの実行方法とセットアップについて説明します。

## セットアップ

### 1. 依存関係のインストール
```bash
flutter pub get
```

### 2. Mockクラスの生成
```bash
flutter packages pub run build_runner build
```

## テスト実行

### 全てのテストを実行
```bash
flutter test
```

### 特定の機能のテストを実行
```bash
# 認証機能のテストのみ実行
flutter test test/features/auth/

# レビュー機能のテストのみ実行
flutter test test/features/reviews/

# 映画機能のテストのみ実行
flutter test test/features/movies/
```

### 特定のテストファイルを実行
```bash
# 認証エンティティのテスト
flutter test test/features/auth/domain/entities/app_user_test.dart

# 星評価ウィジェットのテスト
flutter test test/features/reviews/presentation/widgets/star_rating_test.dart
```

### カバレッジレポート付きでテスト実行
```bash
flutter test --coverage
```

## 作成済みのテストファイル

### 認証機能
- **app_user_test.dart**: AppUserエンティティのテスト
  - プロパティの生成とコピー
  - 等価性とハッシュコード
  - toString メソッド

- **auth_repository_impl_test.dart**: 認証リポジトリの実装テスト
  - Google Sign-in
  - 匿名認証
  - サインアウト
  - プロフィール更新
  - エラーハンドリング

- **google_sign_in_button_test.dart**: Google Sign-inボタンのウィジェットテスト
  - ローディング状態の表示
  - タップイベントの処理
  - UIの外観とスタイル
  - アクセシビリティ

### レビュー機能
- **review_test.dart**: Reviewエンティティのテスト
  - プロパティの管理
  - copyWith メソッド
  - 等価性の確認
  - バリデーション

- **star_rating_test.dart**: 星評価ウィジェットのテスト
  - StarRating（表示専用）
  - InteractiveStarRating（対話式）
  - 半星の表示
  - カスタムカラーとサイズ
  - タップイベント

### 映画機能
- **movie_entity_test.dart**: 映画エンティティのテスト
  - プロパティとメソッド
  - URL生成
  - 評価パーセンテージ計算
  - リリース年の抽出

- **search_movies_usecase_test.dart**: 映画検索ユースケースのテスト
  - 検索クエリのバリデーション
  - ページネーション
  - エラーハンドリング
  - リポジトリとの連携

## テスト戦略

### 単体テスト（Unit Tests）
- **エンティティ**: ドメインオブジェクトのロジック
- **ユースケース**: ビジネスロジック
- **リポジトリ実装**: データ層の抽象化

### ウィジェットテスト（Widget Tests）
- **UIコンポーネント**: 表示とユーザー操作
- **状態管理**: Riverpodプロバイダーとの連携
- **レスポンシブデザイン**: 異なる画面サイズ

### 統合テスト（Integration Tests）
- **Firebase連携**: 認証とFirestore
- **API通信**: TMDb/OMDb APIとの連携
- **エンドツーエンド**: ユーザーフロー全体

## MockitoとMockの使用

### Mockクラスの生成
```dart
@GenerateMocks([AuthRemoteDataSource])
import 'test_file.mocks.dart';
```

### Mockの設定
```dart
when(mockRepository.method()).thenAnswer((_) async => result);
```

### 検証
```dart
verify(mockRepository.method()).called(1);
```

## 注意事項

1. **Firebase設定**: テスト時はFirebaseの初期化をスキップするか、テスト用設定を使用
2. **API呼び出し**: 実際のAPIではなくMockを使用
3. **非同期処理**: `async/await`と`thenAnswer`を適切に使用
4. **エラーケース**: 正常系だけでなく異常系もテスト

## 継続的インテグレーション

GitHub Actionsでのテスト自動化例：
```yaml
- name: Run tests
  run: flutter test
- name: Generate coverage
  run: flutter test --coverage
```

このテストスイートは、プロジェクトの品質保証と継続的な開発をサポートするよう設計されています。
