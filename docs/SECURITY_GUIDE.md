# 🔒 FilmFlow セキュリティガイド

**重要**: このドキュメントは再発防止のために作成されました。APIキー漏洩を二度と起こさないために必ず従ってください。

## 🚨 2024年6月24日 セキュリティインシデント

### 発生した問題
- **APIキー漏洩**: Firebase APIキーとTMDb APIキーが `docs/archive/ERROR_ANALYSIS.md` に含まれた状態でGitHubに公開
- **検出**: GitHub Secret Scanningが自動検出
- **影響**: 公開リポジトリでAPIキーが露出状態

### 対応完了事項
- ✅ 漏洩したAPIキーの即座無効化
- ✅ 新しいAPIキーの生成・設定
- ✅ Git履歴からの完全除去
- ✅ 本番環境の復旧

## 🛡️ 実装済み再発防止策

### 1. Pre-commit Hook
**場所**: `.githooks/pre-commit`

```bash
# 設定確認
git config core.hooksPath
# 出力: .githooks

# 手動実行テスト
.githooks/pre-commit
```

**機能**:
- コミット前にAPIキー自動検出
- Firebase、TMDb、その他のAPIキーパターンをチェック
- 危険な文字列の検出
- プレースホルダーの除外

### 2. GitHub Actions Security Scan
**場所**: `.github/workflows/security-scan.yml`

**機能**:
- プッシュ・プルリクエスト時の自動スキャン
- Git履歴のスキャン
- CI/CDパイプラインでの自動拒否

### 3. Git Secrets Integration
**セットアップ**: `scripts/setup-git-secrets.sh`

```bash
# git-secretsのインストール（macOS）
brew install git-secrets

# 設定実行
./scripts/setup-git-secrets.sh
```

## 📋 開発者ルール

### ✅ DO（すること）

1. **環境変数を使用**
   ```bash
   # ✅ 正しい方法
   TMDB_API_KEY="YOUR_TMDB_API_KEY"
   FIREBASE_API_KEY="YOUR_FIREBASE_API_KEY"
   ```

2. **プレースホルダーを使用**
   ```dart
   // ✅ ドキュメントやサンプルコード
   final apiKey = EnvConfig.tmdbApiKey; // YOUR_API_KEY
   ```

3. **コミット前チェック**
   ```bash
   # ✅ 必ずコミット前に実行
   git secrets --scan
   .githooks/pre-commit
   ```

4. **APIキー管理**
   ```bash
   # ✅ .envファイルに保存（.gitignoreで除外済み）
   echo "TMDB_API_KEY=actual_key_here" >> .env
   ```

### ❌ DON'T（してはいけないこと）

1. **APIキーのハードコーディング**
   ```dart
   // ❌ 絶対にやってはいけない
   final apiKey = "<FIREBASE_API_KEY_PLACEHOLDER>";
   ```

2. **ドキュメントへの実キー記載**
   ```markdown
   <!-- ❌ 絶対にやってはいけない -->
   flutter run --dart-define=FIREBASE_API_KEY=<FIREBASE_API_KEY_PLACEHOLDER>...
   ```

3. **セキュリティツールの無効化**
   ```bash
   # ❌ 絶対にやってはいけない
   git commit --no-verify
   ```

4. **公開リポジトリでの機密情報**
   ```yaml
   # ❌ GitHub Actionsでも秘密情報は直接記載しない
   env:
     API_KEY: "actual_key_here"  # NG
   ```

## 🔍 セキュリティチェック手順

### 手動チェック
```bash
# 1. Pre-commitフックテスト
.githooks/pre-commit

# 2. Git secretsスキャン
git secrets --scan

# 3. 全ファイルスキャン
git secrets --scan-history

# 4. 特定パターン検索
rg -i "AIzaSy|api.*key.*=" --type-not md
```

### 自動チェック
- ✅ コミット時: Pre-commit hook
- ✅ プッシュ時: GitHub Actions
- ✅ プルリクエスト時: GitHub Actions
- ✅ 定期実行: GitHub Secrets Scanning

## 🚀 本番環境でのAPIキー管理

### ローカル開発
```bash
# .envファイル（.gitignoreで除外済み）
FIREBASE_API_KEY="<FIREBASE_API_KEY_PLACEHOLDER>"
TMDB_API_KEY="<TMDB_API_KEY_PLACEHOLDER>"
```

### Firebase Hosting
```bash
# dart-defineで渡す
flutter build web --dart-define=FIREBASE_API_KEY=$FIREBASE_API_KEY
```

### GitHub Actions
```yaml
# GitHub Secretsを使用
env:
  FIREBASE_API_KEY: ${{ secrets.FIREBASE_API_KEY }}
  TMDB_API_KEY: ${{ secrets.TMDB_API_KEY }}
```

## 🧪 セキュリティテスト

### 1. APIキー検出テスト
```bash
# テストファイル作成
echo 'api_key="<FIREBASE_API_KEY_PLACEHOLDER>"' > test.tmp

# 検出テスト
.githooks/pre-commit  # 検出されるべき
git secrets --scan test.tmp  # 検出されるべき

# クリーンアップ
rm test.tmp
```

### 2. プレースホルダーテスト
```bash
# プレースホルダーファイル作成
echo 'api_key="YOUR_API_KEY"' > placeholder.tmp

# 検出テスト（検出されないべき）
.githooks/pre-commit  # 通過するべき
git secrets --scan placeholder.tmp  # 通過するべき

# クリーンアップ
rm placeholder.tmp
```

## 📞 インシデント対応手順

### APIキー漏洩を発見した場合

1. **即座に作業停止**
2. **APIキーの無効化**
   - Google Cloud Console
   - TMDb Console
3. **Git履歴の修正**
   ```bash
   git commit --amend  # 最新コミットの場合
   git rebase -i HEAD~N  # 過去コミットの場合
   git push --force-with-lease
   ```
4. **新しいAPIキーの生成**
5. **環境変数の更新**
6. **本番環境の再デプロイ**

### 報告・連絡
- **GitHub Issues**: セキュリティラベル付きで報告
- **Slack/Discord**: チーム即座通知
- **ドキュメント更新**: 対応ログの記録

## 🔧 ツール設定

### IDE設定

#### VSCode
```json
// .vscode/settings.json
{
  "files.watcherExclude": {
    "**/.env": true
  },
  "search.exclude": {
    "**/.env": true
  }
}
```

#### IntelliJ/Android Studio
```xml
<!-- .idea/workspace.xml -->
<component name="PropertiesComponent">
  <property name="ignored.files" value=".env" />
</component>
```

### Gitignore確認
```bash
# .envファイルが除外されているか確認
git check-ignore .env
# 出力: .env (除外されている場合)
```

## 📚 参考資料

### セキュリティベストプラクティス
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [GitHub Security Best Practices](https://docs.github.com/en/code-security)
- [Firebase Security Rules Guide](https://firebase.google.com/docs/rules)

### 使用ツール
- [git-secrets](https://github.com/awslabs/git-secrets)
- [GitHub Secret Scanning](https://docs.github.com/en/code-security/secret-scanning)
- [pre-commit](https://pre-commit.com/)

## ⚡ クイックチェックリスト

コミット前に必ず確認：
- [ ] `.env`ファイルがコミット対象に含まれていない
- [ ] APIキーがハードコーディングされていない
- [ ] Pre-commitフックが有効になっている
- [ ] git secretsが設定されている
- [ ] ドキュメントにプレースホルダーを使用している

---

**🔒 セキュリティは全員の責任です。このガイドラインを必ず守ってください。**

**最終更新**: 2025年6月24日
**バージョン**: 1.0
**ステータス**: 🟢 アクティブ
