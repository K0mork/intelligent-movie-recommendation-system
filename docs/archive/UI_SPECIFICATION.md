# UI仕様書 - インテリジェント映画レコメンドシステム

## 1. デザインシステム

### 1.1 デザイン原則
- **シンプル性**: 直感的で分かりやすいUI
- **一貫性**: 統一されたデザイン言語
- **アクセシビリティ**: 全てのユーザーが利用可能
- **レスポンシブ**: デバイスに最適化されたレイアウト

### 1.2 カラーパレット

#### 1.2.1 ライトテーマ
```scss
// Primary Colors
$primary-50: #f3e5f5;
$primary-100: #e1bee7;
$primary-500: #9c27b0; // Main brand color
$primary-700: #7b1fa2;
$primary-900: #4a148c;

// Secondary Colors
$secondary-50: #e8f5e8;
$secondary-500: #4caf50;
$secondary-700: #388e3c;

// Neutral Colors
$surface: #ffffff;
$background: #fafafa;
$on-surface: #1c1b1f;
$on-background: #1c1b1f;
$outline: #79747e;
```

#### 1.2.2 ダークテーマ
```scss
// Primary Colors (Dark)
$primary-200: #ce93d8;
$primary-300: #ba68c8;
$primary-400: #ab47bc;

// Neutral Colors (Dark)
$surface: #141218;
$background: #0f0d13;
$on-surface: #e6e0e9;
$on-background: #e6e0e9;
$outline: #938f99;
```

### 1.3 タイポグラフィ

#### 1.3.1 フォントスケール
```scss
// Display
$display-large: 57px/64px;
$display-medium: 45px/52px;
$display-small: 36px/44px;

// Headline
$headline-large: 32px/40px;
$headline-medium: 28px/36px;
$headline-small: 24px/32px;

// Title
$title-large: 22px/28px;
$title-medium: 16px/24px;
$title-small: 14px/20px;

// Body
$body-large: 16px/24px;
$body-medium: 14px/20px;
$body-small: 12px/16px;

// Label
$label-large: 14px/20px;
$label-medium: 12px/16px;
$label-small: 11px/16px;
```

#### 1.3.2 フォントウェイト
- **Regular**: 400
- **Medium**: 500
- **Bold**: 700

### 1.4 スペーシング
```scss
$spacing-4: 4px;
$spacing-8: 8px;
$spacing-12: 12px;
$spacing-16: 16px;
$spacing-24: 24px;
$spacing-32: 32px;
$spacing-48: 48px;
$spacing-64: 64px;
```

### 1.5 ボーダーラディウス
```scss
$radius-small: 8px;
$radius-medium: 12px;
$radius-large: 16px;
$radius-extra-large: 24px;
```

## 2. 画面仕様

### 2.1 サインイン画面

#### 2.1.1 レイアウト構成
```
┌─────────────────────────────────────────┐
│                                         │
│              [LOGO]                     │
│         Movie Recommend                 │
│                                         │
│    "映画の世界をAIと一緒に探検しよう"     │
│                                         │
│     [Sign in with Google Button]        │
│                                         │
│        [Continue as Guest]              │
│                                         │
│     ────────── or ──────────            │
│                                         │
│     映画を見る前に、まずは人気作品を     │
│          チェックしてみませんか？         │
│                                         │
│        [Browse Popular Movies]          │
│                                         │
└─────────────────────────────────────────┘
```

#### 2.1.2 コンポーネント仕様
- **ロゴ**: アニメーション付きブランドロゴ
- **Googleサインインボタン**: Material Design準拠
- **ゲストボタン**: セカンダリーボタンスタイル
- **背景**: グラデーション or 映画関連画像

### 2.2 ホーム画面

#### 2.2.1 レイアウト構成（デスクトップ）
```
┌─────────────────────────────────────────┐
│ [☰] Movie Recommend    [🔍] [👤]      │ <- AppBar
├─────────────────────────────────────────┤
│                                         │
│    あなたへのおすすめ                    │ <- Hero Section
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐  │
│  │Movie │ │Movie │ │Movie │ │Movie │  │
│  │ Card │ │ Card │ │ Card │ │ Card │  │
│  └──────┘ └──────┘ └──────┘ └──────┘  │
│                                         │
├─────────────────────────────────────────┤
│    人気の映画                            │
│  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐      │
│  │Movie│ │Movie│ │Movie│ │Movie│      │
│  └─────┘ └─────┘ └─────┘ └─────┘      │
│                              [もっと見る] │
├─────────────────────────────────────────┤
│    最新リリース                          │
│  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐      │
│  │Movie│ │Movie│ │Movie│ │Movie│      │
│  └─────┘ └─────┘ └─────┘ └─────┘      │
│                              [もっと見る] │
└─────────────────────────────────────────┘
```

#### 2.2.2 レイアウト構成（モバイル）
```
┌─────────────────┐
│ [☰] [🔍] [👤]  │ <- AppBar
├─────────────────┤
│  おすすめ映画    │
│ ┌─────────────┐ │ <- 水平スクロール
│ │  Movie Card │ │
│ │             │ │
│ └─────────────┘ │
├─────────────────┤
│  人気の映画      │
│ ┌─────┐ ┌─────┐ │ <- 2列グリッド
│ │Movie│ │Movie│ │
│ └─────┘ └─────┘ │
│ ┌─────┐ ┌─────┐ │
│ │Movie│ │Movie│ │
│ └─────┘ └─────┘ │
└─────────────────┘
```

### 2.3 映画詳細画面

#### 2.3.1 レイアウト構成
```
┌─────────────────────────────────────────┐
│ [←] Movie Title                [♡][⋯] │ <- AppBar
├─────────────────────────────────────────┤
│ ┌──────────┐                            │
│ │  Poster  │  Title (Headline Large)    │
│ │  Image   │  Release Date • Genre      │
│ │          │  ⭐ 4.2 (1,234 reviews)    │
│ │          │                            │
│ │          │  [レビューを書く]            │
│ └──────────┘                            │
├─────────────────────────────────────────┤
│ あらすじ                                │
│ Lorem ipsum dolor sit amet...           │
│                                         │
├─────────────────────────────────────────┤
│ キャスト                                │
│ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐        │
│ │Cast │ │Cast │ │Cast │ │Cast │        │
│ └─────┘ └─────┘ └─────┘ └─────┘        │
├─────────────────────────────────────────┤
│ レビュー                                │
│ ┌─────────────────────────────────────┐ │
│ │ [👤] User Name    ⭐⭐⭐⭐⭐ 2日前 │ │
│ │ Great movie! Really enjoyed...      │ │
│ │ [👍 12] [👎 1] [返信]               │ │
│ └─────────────────────────────────────┘ │
├─────────────────────────────────────────┤
│ 関連する映画                            │
│ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐        │
│ │Movie│ │Movie│ │Movie│ │Movie│        │
│ └─────┘ └─────┘ └─────┘ └─────┘        │
└─────────────────────────────────────────┘
```

### 2.4 検索・一覧画面

#### 2.4.1 検索バー
```
┌─────────────────────────────────────────┐
│ [🔍] 映画を検索...              [フィルタ] │
├─────────────────────────────────────────┤
│ フィルタ: [ジャンル ▼] [年代 ▼] [評価 ▼] │
└─────────────────────────────────────────┘
```

#### 2.4.2 映画一覧（グリッドビュー）
```
┌─────────────────────────────────────────┐
│ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐         │
│ │Movie│ │Movie│ │Movie│ │Movie│         │
│ │Card │ │Card │ │Card │ │Card │         │
│ └─────┘ └─────┘ └─────┘ └─────┘         │
│ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐         │
│ │Movie│ │Movie│ │Movie│ │Movie│         │
│ │Card │ │Card │ │Card │ │Card │         │
│ └─────┘ └─────┘ └─────┘ └─────┘         │
│                                         │
│            [さらに読み込む]               │
└─────────────────────────────────────────┘
```

### 2.5 マイページ

#### 2.5.1 レイアウト構成
```
┌─────────────────────────────────────────┐
│ [←] マイページ                  [設定]  │
├─────────────────────────────────────────┤
│ ┌────┐                                  │
│ │ 📷 │ User Name                        │
│ └────┘ user@example.com                │
│                                         │
├─────────────────────────────────────────┤
│ 📊 統計情報                             │
│ ┌─────────┐ ┌─────────┐ ┌─────────┐     │
│ │  レビュー │ │ 視聴映画 │ │平均評価 │     │
│ │   67件   │ │  45本   │ │ ⭐4.2  │     │
│ └─────────┘ └─────────┘ └─────────┘     │
├─────────────────────────────────────────┤
│ 📝 最近のレビュー                       │
│ ┌─────────────────────────────────────┐ │
│ │ Movie Title        ⭐⭐⭐⭐⭐ 1日前 │ │
│ │ Review comment preview...           │ │
│ └─────────────────────────────────────┘ │
├─────────────────────────────────────────┤
│ ❤️ お気に入り映画                       │
│ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐        │
│ │Movie│ │Movie│ │Movie│ │Movie│        │
│ └─────┘ └─────┘ └─────┘ └─────┘        │
└─────────────────────────────────────────┘
```

### 2.6 推薦画面

#### 2.6.1 レイアウト構成
```
┌─────────────────────────────────────────┐
│ [←] あなたへのおすすめ          [🔄]   │
├─────────────────────────────────────────┤
│ 🎯 あなたの好みに基づいて選びました      │
│ 最終更新: 2時間前                       │
├─────────────────────────────────────────┤
│ ┌─────────────────────────────────────┐ │
│ │ ┌──────┐                            │ │
│ │ │Poster│ Movie Title                │ │
│ │ │Image │ ⭐ 4.5 • 2024 • Action    │ │
│ │ │      │                            │ │
│ │ │      │ 📍 おすすめの理由:          │ │
│ │ │      │ • アクション映画がお好み   │ │
│ │ │      │ • 高評価した作品と類似     │ │
│ │ │      │                            │ │
│ │ └──────┘ [詳細] [興味なし]          │ │
│ └─────────────────────────────────────┘ │
├─────────────────────────────────────────┤
│ カテゴリ別おすすめ                      │
│                                         │
│ 🔥 トレンド中                          │
│ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐        │
│ │Movie│ │Movie│ │Movie│ │Movie│        │
│ └─────┘ └─────┘ └─────┘ └─────┘        │
│                                         │
│ 🎭 似た嗜好のユーザーが好きな作品        │
│ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐        │
│ │Movie│ │Movie│ │Movie│ │Movie│        │
│ └─────┘ └─────┘ └─────┘ └─────┘        │
└─────────────────────────────────────────┘
```

## 3. コンポーネント仕様

### 3.1 映画カード

#### 3.1.1 基本映画カード
```
┌─────────────┐
│             │
│   Poster    │ <- 16:9 or 2:3比率
│   Image     │
│             │
├─────────────┤
│ Movie Title │ <- Title Medium
│ ⭐ 4.2 • 2024│ <- Body Small
└─────────────┘
```

#### 3.1.2 推薦映画カード
```
┌─────────────────────────────┐
│ ┌──────┐                    │
│ │Poster│ Movie Title        │ <- Title Large
│ │Image │ ⭐ 4.5 • 2024      │ <- Body Medium
│ │      │                    │
│ │      │ 📍 おすすめ理由:    │
│ │      │ • アクション好み   │ <- Body Small
│ │      │ • 高評価作品類似   │
│ │      │                    │
│ └──────┘ [詳細] [興味なし]  │
└─────────────────────────────┘
```

### 3.2 星評価コンポーネント

#### 3.2.1 表示用
```
⭐⭐⭐⭐⭐ 4.5 (1,234)
```

#### 3.2.2 入力用
```
評価を選択してください:
☆☆☆☆☆ <- インタラクティブ
1  2  3  4  5
```

### 3.3 レビューカード

```
┌─────────────────────────────────────┐
│ ┌──┐                               │
│ │👤│ User Name     ⭐⭐⭐⭐⭐ 2日前│ <- Header
│ └──┘                               │
│                                    │
│ Great movie! Really enjoyed the    │ <- Body
│ action sequences and the story...  │
│                                    │
│ [👍 12] [👎 1] [💬 5] [⋯]          │ <- Actions
└─────────────────────────────────────┘
```

### 3.4 検索バー

```
┌─────────────────────────────────────┐
│ 🔍 映画のタイトルを入力...    [×]  │
├─────────────────────────────────────┤
│ 最近の検索:                         │
│ • アベンジャーズ                   │
│ • スタジオジブリ                   │
│ • 2024年公開                      │
└─────────────────────────────────────┘
```

### 3.5 フィルターチップ

```
┌─────────────────────────────────────┐
│ [ジャンル ▼] [年代 ▼] [評価 ▼]    │
│                                     │
│ 選択中: [Action ×] [2024 ×]        │
└─────────────────────────────────────┘
```

## 4. レスポンシブデザイン

### 4.1 ブレークポイント

```scss
// Mobile First Approach
$mobile: 480px;
$tablet: 768px;
$desktop: 1024px;
$wide: 1440px;
```

### 4.2 グリッドシステム

#### 4.2.1 映画カードグリッド
- **Mobile**: 2列
- **Tablet**: 3-4列
- **Desktop**: 4-6列
- **Wide**: 6-8列

#### 4.2.2 コンテンツ最大幅
- **最大幅**: 1200px
- **サイドマージン**: 16px (mobile), 24px (tablet+)

### 4.3 ナビゲーション

#### 4.3.1 デスクトップ
```
┌─────────────────────────────────────────┐
│ [Logo] ホーム 検索 マイページ    [🔍][👤]│
└─────────────────────────────────────────┘
```

#### 4.3.2 モバイル
```
┌─────────────────┐
│ [☰] Logo  [🔍]  │ <- Top AppBar
├─────────────────┤
│                 │
│    Content      │
│                 │
├─────────────────┤
│ [🏠][🔍][❤️][👤]│ <- Bottom Navigation
└─────────────────┘
```

## 5. アニメーション・インタラクション

### 5.1 トランジション

#### 5.1.1 画面遷移
- **Duration**: 300ms
- **Curve**: ease-in-out
- **Effect**: Slide transition

#### 5.1.2 カードホバー
```scss
.movie-card {
  transition: transform 0.2s ease-in-out, box-shadow 0.2s ease-in-out;

  &:hover {
    transform: translateY(-4px);
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
  }
}
```

### 5.2 ローディング状態

#### 5.2.1 スケルトン
```
┌─────────────┐
│ ░░░░░░░░░░░ │ <- グレーアニメーション
│ ░░░░░░░░░   │
│ ░░░░░░░     │
│ ░░░░░       │
└─────────────┘
```

#### 5.2.2 スピナー
- **サイズ**: 24px (small), 40px (medium), 56px (large)
- **色**: Primary color
- **アニメーション**: 回転

### 5.3 フィードバック

#### 5.3.1 ボタンリップル
```scss
.button {
  position: relative;
  overflow: hidden;

  &::before {
    content: '';
    position: absolute;
    background: rgba(255, 255, 255, 0.3);
    border-radius: 50%;
    transform: scale(0);
    animation: ripple 0.3s ease-out;
  }
}
```

#### 5.3.2 成功・エラー表示
- **成功**: 緑色チェックマークアイコン
- **エラー**: 赤色エラーアイコン
- **警告**: 橙色警告アイコン

## 6. アクセシビリティ

### 6.1 カラーコントラスト
- **AA準拠**: 4.5:1以上
- **大きなテキスト**: 3:1以上

### 6.2 フォーカス管理
```scss
.focusable {
  &:focus {
    outline: 2px solid $primary-500;
    outline-offset: 2px;
  }
}
```

### 6.3 スクリーンリーダー対応
```html
<img src="poster.jpg" alt="映画タイトル - ポスター画像">
<button aria-label="お気に入りに追加">❤️</button>
<div role="region" aria-label="おすすめ映画リスト">
```

## 7. パフォーマンス最適化

### 7.1 画像最適化
- **フォーマット**: WebP (fallback: JPEG/PNG)
- **圧縮**: 適切な品質設定
- **Lazy Loading**: スクロール時読み込み

### 7.2 アニメーション最適化
```scss
.optimized-animation {
  will-change: transform;
  transform: translateZ(0); // GPU加速
}
```

### 7.3 バンドルサイズ
- **コード分割**: 機能別分割
- **Tree Shaking**: 未使用コード除去
- **圧縮**: Gzip/Brotli圧縮
