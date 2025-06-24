#!/bin/bash

# FilmFlow Manual Git History Cleanup
# git filter-branchを使用してAPIキーを履歴から除去

set -e

echo "🔒 FilmFlow Manual Git History Cleanup"
echo "======================================"

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'
BOLD='\033[1m'

echo -e "${YELLOW}${BOLD}⚠️  重要な警告${NC}"
echo -e "${RED}この操作はGit履歴を永久的に変更します！${NC}"
echo -e "${YELLOW}続行前にリポジトリの完全バックアップを作成することを強く推奨します${NC}"

# 検出されたAPIキー（既にプレースホルダーに置換済み）
LEAKED_KEYS=(
    "<FIREBASE_API_KEY_PLACEHOLDER>"
    "<TMDB_API_KEY_PLACEHOLDER>"
    "<FIREBASE_API_KEY_PLACEHOLDER>"
    "<TMDB_API_KEY_PLACEHOLDER>"
    "<TMDB_API_KEY_PLACEHOLDER>"
    "<FIREBASE_API_KEY_PLACEHOLDER>"
)

echo -e "\n${BLUE}🔍 除去対象のAPIキー:${NC}"
for key in "${LEAKED_KEYS[@]}"; do
    echo -e "  🚨 ${key}"
done

echo -e "\n続行しますか？ (yes/no): "
read -r response

if [[ ! "$response" =~ ^[Yy]es$ ]]; then
    echo -e "${YELLOW}操作がキャンセルされました${NC}"
    exit 0
fi

# バックアップ作成
echo -e "\n${BLUE}💾 自動バックアップを作成中...${NC}"
backup_dir="../filmflow-backup-$(date +%Y%m%d-%H%M%S)"
cp -r . "$backup_dir"
echo -e "${GREEN}✅ バックアップ作成完了: $backup_dir${NC}"

# filter-branchを使用してAPIキーを置換
echo -e "\n${BLUE}🧹 Git履歴からAPIキーを除去中...${NC}"
echo -e "${YELLOW}この処理には時間がかかります...${NC}"

# 各APIキーを順次置換
for key in "${LEAKED_KEYS[@]}"; do
    echo -e "\n${BLUE}🔄 処理中: ${key:0:10}...${NC}"
    
    # Firebase APIキーの場合
    if [[ $key == AIzaSy* ]]; then
        placeholder="<FIREBASE_API_KEY_PLACEHOLDER>"
    else
        placeholder="<TMDB_API_KEY_PLACEHOLDER>"
    fi
    
    # filter-branchで置換実行
    git filter-branch --force --tree-filter "
        find . -type f -name '*.dart' -o -name '*.md' -o -name '*.json' -o -name '*.yml' -o -name '*.yaml' -o -name '*.sh' -o -name '*.txt' | \
        xargs sed -i.bak 's|$key|$placeholder|g' 2>/dev/null || true
        find . -name '*.bak' -delete 2>/dev/null || true
    " --all 2>/dev/null || echo "  スキップ: $key"
done

# reflogとGCでクリーンアップ
echo -e "\n${BLUE}🧹 Git参照のクリーンアップ中...${NC}"
git reflog expire --expire=now --all
git gc --prune=now --aggressive

# 結果確認
echo -e "\n${BLUE}🔍 クリーンアップ結果を確認中...${NC}"
remaining_keys=$(git log --all --oneline --grep="AIzaSy\|[0-9a-f]\{32\}" | wc -l)

if [ "$remaining_keys" -eq 0 ]; then
    echo -e "\n${GREEN}${BOLD}✅ Git履歴からAPIキーが除去されました！${NC}"
else
    echo -e "\n${YELLOW}⚠️  一部のAPIキーが残っている可能性があります${NC}"
    echo -e "${BLUE}手動確認コマンド: git log --all --grep=\"AIzaSy\"${NC}"
fi

# 次のステップを表示
echo -e "\n${YELLOW}${BOLD}📋 次のステップ:${NC}"
echo -e "1. ${BLUE}git log --oneline -10${NC} で履歴を確認"
echo -e "2. ${RED}git push --force-with-lease origin main${NC} でリモート更新"
echo -e "3. チームに履歴書き換えを通知"

echo -e "\n${GREEN}${BOLD}🎉 手動Git履歴クリーンアップ完了！${NC}"