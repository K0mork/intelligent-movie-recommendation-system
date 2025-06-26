# 開発プロジェクトガイド

このドキュメントは、FilmFlowプロジェクトへのコントリビュートを円滑に進めるためのガイドです。

## 🚀 開発を始める前に

1.  **`README.md` を読む**: まずは [README.md](./README.md) を読み、プロジェクトの概要とセットアップ手順を理解してください。
2.  **Firebaseプロジェクトへのアクセス**: 開発にはFirebaseプロジェクトへのアクセス権が必要です。管理者に連絡して、必要な権限を取得してください。
3.  **コーディング規約の確認**: この後述されるコーディング規約に目を通してください。

## 🛠️ 開発ワークフロー

1.  **Issueの作成**: 機能追加やバグ修正など、作業を始める前に関連するIssueを作成（または既存のIssueを担当）してください。
2.  **ブランチの作成**: `main` ブランチから作業用のブランチを作成します。ブランチ名は `feature/issue-123-new-feature` や `fix/issue-456-bug-fix` のように、分かりやすい名前を付けます。
3.  **開発**: Flutter (フロントエンド) と Cloud Functions (バックエンド) のコードを実装します。
    -   **ローカルテスト**: Firebase Local Emulator Suite を活用し、ローカル環境で十分にテストを行ってください。
    -   **単体テスト・ウィジェットテスト**: `test/` ディレクトリに、追加・修正したロジックに対するテストコードを記述します。
4.  **Pull Requestの作成**: 作業が完了したら、`main` ブランチへのPull Requestを作成します。
    -   PRのテンプレートに従い、変更内容やテスト結果を記述してください。
    -   CI（GitHub Actions）のテストがすべてパスしていることを確認します。
5.  **コードレビュー**: チームメンバーによるコードレビューを受け、指摘事項を修正します。
6.  **マージ**: レビューで承認されたら、Pull Requestをマージします。

## 🌿 ブランチ戦略

-   **`main`**: 常に安定し、デプロイ可能な状態を保ちます。直接のコミットは禁止です。
-   **`develop`**: 開発中の最新バージョン。`feature`ブランチのマージ先となります。（※現在は`main`に直接マージするシンプルな戦略を採用）
-   **`feature/*`**: 新機能開発のためのブランチ。
-   **`fix/*`**: バグ修正のためのブランチ。
-   **`release/*`**: リリース準備のためのブランチ。

## ✍️ コーディング規約

### 一般

-   **言語**: Dart (Flutter), TypeScript (Cloud Functions)
-   **フォーマット**: 各言語の標準的なフォーマッター（`dart format`, `prettier`）に従います。コミット前に必ず実行してください。
-   **命名規則**:
    -   ファイル名: `snake_case.dart` (Dart), `camelCase.ts` (TypeScript)
    -   クラス・型: `UpperCamelCase`
    -   変数・関数: `lowerCamelCase`
    -   定数: `UPPER_SNAKE_CASE`

### Flutter / Dart

-   **状態管理**: Riverpod を採用しています。
-   **アーキテクチャ**: 機能ごとにディレクトリを分けるフィーチャーファースト構成です (`lib/features/*`)。
-   **UI**: Material Design 3 に準拠します。共通のウィジェットは `lib/core/widgets/` に配置します。
-   **静的解析**: `analysis_options.yaml` のルールを遵守してください。

### Cloud Functions / TypeScript

-   **モジュール構成**: `functions/src/` 以下に、`auth`, `movies`, `reviews` のように機能ごとにディレクトリを分け、関連するロジックをまとめてください。
-   **エラーハンドリング**: `try-catch` を適切に使用し、クライアントに返すエラーは `functions.https.HttpsError` を用いてください。
-   **環境変数**: APIキーなどの機密情報は `.env` ファイルで管理し、コードに直接記述しないでください。

## 📄 ドキュメント

-   **API仕様**: APIの仕様は [API_DOCUMENTATION.md](./docs/API_DOCUMENTATION.md) を参照してください。APIに変更を加えた場合は、必ずこのドキュメントも更新してください。
-   **アーキテクチャ**: プロジェクト全体のアーキテクチャは [ARCHITECTURE.md](./docs/ARCHITECTURE.md) を参照してください。
