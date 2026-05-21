# Daily AI Secretary

> Obsidian × Gemini CLI で「自分専用のAI秘書」を動かす、最小構成のオープンソーステンプレート

毎朝、AIがあなたのObsidian Vaultを読み込み、**昨日との差分**を分析して以下を自動生成します。

- 📋 **Daily Briefing**（今日やること・昨日のメモの要約・提案）
- 🧠 **ナレッジマップ**（ノート間のつながりの可視化）
- ✅ **タスク抽出**（雑多なメモから自動でTODOを生成）
- 📚 **フィードバック学習**（あなたのコメントから日々賢くなる）

シェルスクリプト1本 + 指示書（GEMINI.md）1枚という、誰でも読めるシンプルな構成です。

---

## 🎯 こんな人におすすめ

- 毎朝、複数のメモ・タスク・予定を整理するのに時間がかかっている
- ChatGPTやGeminiを「単発のQA」だけでなく**継続的な秘書**として使いたい
- 自分のメモ（プライベートな情報）をクラウドに丸ごと預けたくない（ローカル完結）
- Obsidianを使っているが、AIと連携させる方法に悩んでいる

---

## ✨ このプロジェクトの特徴

| 特徴 | 内容 |
|---|---|
| **ローカル完結** | Vaultはローカル（またはiCloud Drive）に置いたまま。APIに送るのは必要なノートだけ |
| **編集権限の分離** | AIは既存ファイルを**一切変更しない**。出力は `gemini/` フォルダ内のみ |
| **指示書ベース** | 動作はすべて `GEMINI.md` というMarkdown1枚に集約。エンジニアでなくても編集可 |
| **フィードバックループ** | 毎日のbriefingにあなたが書いたコメントを翌日のAIが読み、行動を改善 |
| **拡張可能** | Gemini CLI を別のLLM CLI（Claude Code, OpenAI CLI など）に差し替え可能 |

---

## 🚀 クイックスタート（5分）

### 1. 前提条件

- macOS / Linux（Windowsは WSL 推奨）
- [Obsidian](https://obsidian.md/)
- [Gemini CLI](https://github.com/google-gemini/gemini-cli) のインストールと認証

```bash
# Gemini CLI のインストール例
npm install -g @google/gemini-cli
gemini  # 初回起動で認証
```

### 2. このリポジトリをクローン

```bash
git clone https://github.com/YOUR_USERNAME/daily-ai-secretary.git
cd daily-ai-secretary
```

### 3. Vault に AI 用ファイルを配置

```bash
# あなたのObsidian Vaultのパスを指定
export VAULT_PATH="/path/to/your/ObsidianVault"

# 指示書を Vault のルートにコピー
cp GEMINI.md "$VAULT_PATH/"

# 出力先フォルダを作成
mkdir -p "$VAULT_PATH/gemini/archive"
```

### 4. スクリプトを実行

```bash
# パスを編集
vim scripts/daily-routine.sh   # VAULT_PATH を自分の環境に書き換え

# 実行
bash scripts/daily-routine.sh
```

数分後、`$VAULT_PATH/gemini/daily-briefing.md` が更新されます。Obsidianで開いてみてください。

### 5. 毎朝自動実行する（任意）

macOSの `launchd` または `cron` で毎朝7時に実行する例：

```bash
# crontab に追加
0 7 * * * /bin/bash /path/to/daily-ai-secretary/scripts/daily-routine.sh
```

詳しくは [docs/setup.md](docs/setup.md) を参照。

---

## 📁 ディレクトリ構成

```
daily-ai-secretary/
├── README.md                    # このファイル
├── GEMINI.md                    # AIへの指示書（Vaultに配置するテンプレート）
├── scripts/
│   └── daily-routine.sh         # 毎日実行するシェルスクリプト
├── docs/
│   ├── setup.md                 # セットアップ詳細
│   ├── architecture.md          # 仕組みの解説
│   └── customization.md         # カスタマイズの仕方
├── examples/
│   └── sample-vault/            # ダミーのObsidian Vault
│       ├── GEMINI.md            # ↑のコピー
│       ├── 0_Thoughts/Daily/    # 入力：あなたのデイリーノート
│       ├── meetings/            # 入力：会議メモ
│       └── gemini/              # 出力：AIが生成したもの
│           ├── daily-briefing.md       # ← メインの出力
│           ├── nord-map.md             # ナレッジマップ
│           ├── task-database.md        # 抽出されたタスク
│           ├── learning-from-feedback.md # フィードバック学習ログ
│           └── archive/                # 過去のbriefingスナップショット
├── LICENSE
└── .gitignore
```

---

## 🔍 動作イメージ

### 入力（あなたが書く）

`0_Thoughts/Daily/2026-05-20.md`:
```markdown
# 2026-05-20

- 10:00 営業会議：来期計画について議論。山田部長が新商品Aに乗り気
- 14:00 開発チームと打ち合わせ、API仕様の見直しが必要
- 思いついた：競合B社の動向をまとめておきたい #idea
```

### 出力（AIが書く）

`gemini/daily-briefing.md`:
```markdown
# Daily Briefing — 2026-05-21

## 📌 当日メモ欄
（ここに今日のメモを雑に書いてください。明日のAIが整理します）

## 🎯 今日やること
- [ ] API仕様の見直しドラフトを作成（昨日の開発会議より）
- [ ] 競合B社調査メモを作る（昨日の #idea より）

## 📰 昨日の振り返り
- 営業会議で「新商品A」が前向きに議論された
  - → 来期計画書ドラフトのアクションを task-database.md に追加しました
...
```

詳しいサンプルは [examples/sample-vault/gemini/daily-briefing.md](examples/sample-vault/gemini/daily-briefing.md) を見てください。

---

## 🛠 仕組み

```
┌─────────────────────┐
│  あなたの Obsidian   │
│   Vault（既存）       │  ← AIは読むだけ
└─────────┬───────────┘
          │
          ▼
┌─────────────────────┐
│  GEMINI.md          │  ← Vaultルートに置かれた指示書
│  （指示書）          │     Gemini CLIが自動的に読み込む
└─────────┬───────────┘
          │
          ▼
┌─────────────────────┐
│  Gemini CLI         │  ← scripts/daily-routine.sh から起動
│  （gemini-2.5-pro）  │
└─────────┬───────────┘
          │
          ▼
┌─────────────────────┐
│  gemini/ フォルダ     │  ← ここにだけ書き込む
│  - daily-briefing   │
│  - nord-map         │
│  - task-database    │
│  - archive/         │
└─────────────────────┘
```

詳細は [docs/architecture.md](docs/architecture.md) へ。

---

## 🔧 カスタマイズ

「うちの会社では英語にしたい」「営業日報のフォーマットに合わせたい」など、
すべての挙動は `GEMINI.md` を書き換えるだけで変更できます。

例：
- 出力言語を変える → `GEMINI.md` の「出力はできるだけ日本語で」を編集
- タスクの記法を変える → タスクプラグインの設定に合わせて記載
- 出力先フォルダを変える → `gemini/` を別の名前に

詳しくは [docs/customization.md](docs/customization.md) を参照。

---

## ⚠️ 注意事項

- **APIコスト**：Gemini CLI は無料枠がありますが、Vaultが大きい場合は有償枠が必要になることがあります
- **プライバシー**：AIに送るのはGEMINI.mdで指定された範囲だけですが、APIに送る以上、機密情報の扱いには注意してください
- **データ保護**：`GEMINI.md` の中で「絶対に読まないフォルダ」（例：`Not4Gemini/`）を指定できます
- **既存ファイルの保護**：本テンプレートではAIに**読み取り専用**を厳命していますが、`--approval-mode yolo` を使うため、念のため重要なVaultはバックアップしてください

---

## 📜 ライセンス

MIT License — 自由に使い、改変し、再配布してください。

---

## 🙋 貢献・フィードバック

- Issue / Pull Request 歓迎です
- 「こんな使い方をしてみた」報告も大歓迎

---

## 🔗 関連リンク

- [Obsidian](https://obsidian.md/)
- [Gemini CLI (公式)](https://github.com/google-gemini/gemini-cli)
- [PKM（パーソナル・ナレッジ・マネジメント）について](https://en.wikipedia.org/wiki/Personal_knowledge_management)
