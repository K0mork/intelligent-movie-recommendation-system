#!/bin/bash

# FilmFlow Git History Cleanup Script
# BFGを使用してAPIキーをGit履歴から完全除去

set -e

echo "🔒 FilmFlow Git History Cleanup"
echo "================================="

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'
BOLD='\033[1m'

# BFGのインストール確認
if ! command -v bfg &> /dev/null; then
    echo -e "${YELLOW}⚠️  BFG Repo-Cleaner がインストールされていません${NC}"
    echo -e "${BLUE}インストール方法:${NC}"
    echo -e "  macOS: ${GREEN}brew install bfg${NC}"
    echo -e "  Linux: ${GREEN}wget https://repo1.maven.org/maven2/com/madgag/bfg/1.14.0/bfg-1.14.0.jar${NC}"
    echo -e "  Manual: ${GREEN}https://rtyley.github.io/bfg-repo-cleaner/${NC}"
    echo -e "\n${RED}⚠️  警告: BFGはGit履歴を永久的に変更します！${NC}"
    echo -e "${YELLOW}続行前にリポジトリをバックアップしてください${NC}"
    exit 1
fi

echo -e "${GREEN}✅ BFG Repo-Cleaner が見つかりました${NC}"

# バックアップの作成を推奨
echo -e "\n${YELLOW}${BOLD}⚠️  重要な警告${NC}"
echo -e "${RED}この操作はGit履歴を永久的に変更します！${NC}"
echo -e "${YELLOW}続行前にリポジトリの完全バックアップを作成することを強く推奨します${NC}"
echo -e "\n${BLUE}バックアップ方法:${NC}"
echo -e "  ${GREEN}cp -r . ../filmflow-backup${NC}"
echo -e "\n続行しますか？ (yes/no): "
read -r response

if [[ ! "$response" =~ ^[Yy]es$ ]]; then
    echo -e "${YELLOW}操作がキャンセルされました${NC}"
    exit 0
fi

# 検出されたAPIキーのリスト
echo -e "\n${BLUE}🔍 検出されたAPIキー:${NC}"
LEAKED_KEYS=(
    "<FIREBASE_API_KEY_PLACEHOLDER>"
    "<TMDB_API_KEY_PLACEHOLDER>"
    "<FIREBASE_API_KEY_PLACEHOLDER>"
    "<TMDB_API_KEY_PLACEHOLDER>"
    "<TMDB_API_KEY_PLACEHOLDER>"
    "<FIREBASE_API_KEY_PLACEHOLDER>"
)

for key in "${LEAKED_KEYS[@]}"; do
    echo -e "  🚨 ${key}"
done

# APIキーを置換用ファイルに出力
echo -e "\n${BLUE}📝 置換ルールを作成中...${NC}"
cat > api-key-replacements.txt << 'EOF'
# Firebase APIキー置換ルール
regex:AIzaSy[0-9A-Za-z_-]{33}==><FIREBASE_API_KEY_PLACEHOLDER>

# TMDb APIキー置換ルール
regex:[0-9a-f]{32}==><TMDB_API_KEY_PLACEHOLDER>

# 特定の漏洩キー（既にプレースホルダーに置換済み）
<FIREBASE_API_KEY_PLACEHOLDER>==><FIREBASE_API_KEY_PLACEHOLDER>
<TMDB_API_KEY_PLACEHOLDER>==><TMDB_API_KEY_PLACEHOLDER>
EOF

echo -e "${GREEN}✅ 置換ルールファイル作成完了${NC}"

# 現在のブランチを確認
current_branch=$(git branch --show-current)
echo -e "\n${BLUE}📊 現在のブランチ: ${current_branch}${NC}"

# BFGによる履歴クリーンアップ実行
echo -e "\n${BLUE}🧹 BFGによる履歴クリーンアップを実行中...${NC}"
echo -e "${YELLOW}これには数分かかる場合があります...${NC}"

# BFGの実行
if bfg --replace-text api-key-replacements.txt --no-blob-protection .; then
    echo -e "\n${GREEN}✅ BFGクリーンアップ完了${NC}"
else
    echo -e "\n${RED}❌ BFGクリーンアップ失敗${NC}"
    exit 1
fi

# Gitの参照とログを更新
echo -e "\n${BLUE}🔄 Git参照を更新中...${NC}"
git reflog expire --expire=now --all
git gc --prune=now --aggressive

# 結果の確認
echo -e "\n${BLUE}🔍 クリーンアップ結果を確認中...${NC}"
if git log --all --full-history -- "*" | grep -E "AIzaSy[0-9A-Za-z_-]{33}|[0-9a-f]{32}" | grep -v "PLACEHOLDER"; then
    echo -e "\n${RED}⚠️  まだAPIキーが残っている可能性があります${NC}"
    echo -e "${YELLOW}手動確認が必要です${NC}"
else
    echo -e "\n${GREEN}${BOLD}✅ Git履歴からAPIキーが完全に除去されました！${NC}"
fi

# フォースプッシュの必要性を通知
echo -e "\n${YELLOW}${BOLD}📋 次のステップ:${NC}"
echo -e "1. ${RED}git push --force-with-lease origin ${current_branch}${NC}"
echo -e "   ${YELLOW}⚠️  これはリモートリポジトリの履歴を書き換えます${NC}"
echo -e "2. チームメンバーに履歴書き換えを通知"
echo -e "3. 他の開発者は ${GREEN}git pull --rebase${NC} で同期"

# クリーンアップ
rm -f api-key-replacements.txt

echo -e "\n${GREEN}${BOLD}🎉 Git履歴クリーンアップ完了！${NC}"
echo -e "${BLUE}セキュリティが大幅に向上しました${NC}"
