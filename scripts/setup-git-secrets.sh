#!/bin/bash

# FilmFlow Git Secrets Setup Script
# git-secretsツールの自動設定スクリプト

set -e

echo "🔒 FilmFlow Git Secrets Setup"
echo "=============================="

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'
BOLD='\033[1m'

# git-secretsのインストール確認
if ! command -v git-secrets &> /dev/null; then
    echo -e "${YELLOW}⚠️  git-secrets がインストールされていません${NC}"
    echo -e "${BLUE}インストール方法:${NC}"
    echo -e "  macOS: ${GREEN}brew install git-secrets${NC}"
    echo -e "  Ubuntu: ${GREEN}sudo apt-get install git-secrets${NC}"
    echo -e "  Manual: ${GREEN}git clone https://github.com/awslabs/git-secrets.git && cd git-secrets && make install${NC}"
    exit 1
fi

echo -e "${GREEN}✅ git-secrets が見つかりました${NC}"

# git-secretsの初期化
echo -e "${BLUE}🔧 git-secrets を初期化中...${NC}"
git secrets --install --force

# パターンの追加
echo -e "${BLUE}📝 API キー検出パターンを追加中...${NC}"

# Firebase APIキー
git secrets --add 'AIzaSy[0-9A-Za-z_-]{33}'
echo -e "  ✅ Firebase API Key パターン追加"

# TMDb APIキー
git secrets --add '[0-9a-f]{32}'
echo -e "  ✅ TMDb API Key パターン追加"

# 一般的なAPIキー
git secrets --add '[Aa][Pp][Ii]_?[Kk][Ee][Yy].*['\''"][0-9A-Za-z_-]{20,}['\''"]'
echo -e "  ✅ Generic API Key パターン追加"

# シークレット
git secrets --add '[Ss][Ee][Cc][Rr][Ee][Tt].*['\''"][0-9A-Za-z_-]{20,}['\''"]'
echo -e "  ✅ Secret パターン追加"

# トークン
git secrets --add '[Tt][Oo][Kk][Ee][Nn].*['\''"][0-9A-Za-z_-]{20,}['\''"]'
echo -e "  ✅ Token パターン追加"

# 特定のAPIキー設定文字列
git secrets --add 'firebase.*api.*key.*='
git secrets --add 'tmdb.*api.*key.*='
git secrets --add 'api_key.*=.*['\''"][0-9a-zA-Z_-]{20,}['\''"]'
git secrets --add 'apiKey.*=.*['\''"][0-9a-zA-Z_-]{20,}['\''"]'
echo -e "  ✅ API設定パターン追加"

# 許可パターンの追加（プレースホルダー等）
echo -e "${BLUE}✅ 許可パターンを追加中...${NC}"
git secrets --add --allowed 'YOUR_API_KEY'
git secrets --add --allowed 'YOUR_FIREBASE_API_KEY'
git secrets --add --allowed 'YOUR_TMDB_API_KEY'
git secrets --add --allowed 'PLACEHOLDER'
git secrets --add --allowed 'EXAMPLE'
git secrets --add --allowed 'TEST_KEY'
git secrets --add --allowed 'TEMPLATE'
echo -e "  ✅ プレースホルダーパターン許可"

# 設定の確認
echo -e "\n${BLUE}📋 現在の設定:${NC}"
git config --list | grep secrets || echo "  設定確認中..."

echo -e "\n${GREEN}${BOLD}🎉 git-secrets セットアップ完了！${NC}"
echo -e "${GREEN}今後のコミットでAPIキーが自動検出されます${NC}"

# テスト実行
echo -e "\n${BLUE}🧪 設定テスト中...${NC}"
echo "api_key=\"<TEST_API_KEY_PLACEHOLDER>\"" > test_secret.tmp
if git secrets --scan test_secret.tmp 2>/dev/null; then
    echo -e "${RED}❌ テスト失敗: 秘密情報が検出されませんでした${NC}"
else
    echo -e "${GREEN}✅ テスト成功: 秘密情報が正しく検出されました${NC}"
fi
rm -f test_secret.tmp

echo -e "\n${YELLOW}💡 使用方法:${NC}"
echo -e "  全ファイルスキャン: ${GREEN}git secrets --scan${NC}"
echo -e "  履歴スキャン: ${GREEN}git secrets --scan-history${NC}"
echo -e "  特定ファイル: ${GREEN}git secrets --scan filename${NC}"
