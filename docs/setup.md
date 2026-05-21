# セットアップガイド

## 1. 必要なもの

| ツール | 用途 | リンク |
|---|---|---|
| **Obsidian** | メインのノートアプリ | https://obsidian.md/ |
| **Gemini CLI** | AIの実行エンジン | https://github.com/google-gemini/gemini-cli |
| **Node.js (v18+)** | Gemini CLI の依存 | https://nodejs.org/ |
| **Bash / Zsh** | スクリプト実行 | (macOS/Linux 標準) |

> Windowsの場合は **WSL2 (Ubuntu)** 環境を推奨します。

---

## 2. Gemini CLI のセットアップ

```bash
# インストール
npm install -g @google/gemini-cli

# 初回起動 → Googleアカウントで認証
gemini

# 動作確認
gemini -p "hello" --output-format text
```

無料枠だけで十分に試せます。日常利用する場合は[料金プラン](https://ai.google.dev/pricing)を確認してください。

---

## 3. このリポジトリの導入

```bash
git clone https://github.com/RyoMurakami-MedRobo/daily-ai-secretary.git
cd daily-ai-secretary
```

---

## 4. Obsidian Vault への配置

### 4-1. Vaultのパスを確認

Obsidianを開き、左下の歯車 → 「Vaultについて」でVaultのパスを確認します。
よくある場所：

| OS | パス例 |
|---|---|
| macOS (iCloud) | `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/<VaultName>` |
| macOS (ローカル) | `~/Documents/ObsidianVault` |
| Linux | `~/Documents/ObsidianVault` |
| Windows (WSL) | `/mnt/c/Users/<User>/Documents/ObsidianVault` |

### 4-2. GEMINI.md を Vault のルートに配置

```bash
export VAULT_PATH="/path/to/your/ObsidianVault"
cp GEMINI.md "$VAULT_PATH/"
```

### 4-3. 出力フォルダを作成

```bash
mkdir -p "$VAULT_PATH/gemini/archive"
```

### 4-4. （任意）プライバシー保護用フォルダを作成

AIに**絶対に読ませたくない**ノートがある場合：

```bash
mkdir -p "$VAULT_PATH/Private"
mkdir -p "$VAULT_PATH/Not4AI"
```

`GEMINI.md` ではこの2つのフォルダを読み込まないように指示しています。

---

## 5. スクリプトの編集

```bash
# 任意のエディタで開く
vim scripts/daily-routine.sh
```

`VAULT_PATH` の行を自分の環境に書き換えてください：

```bash
VAULT_PATH="${VAULT_PATH:-/path/to/your/ObsidianVault}"
```

---

## 6. 動作確認

```bash
bash scripts/daily-routine.sh
```

完了後、Obsidianで以下のファイルを開いてみてください：

- `gemini/daily-briefing.md` ← メインの出力
- `gemini/nord-map.md` ← ナレッジマップ
- `gemini/task-database.md` ← 抽出されたタスク

---

## 7. 毎朝自動実行（cron）

```bash
crontab -e
```

以下を追加：

```cron
# 毎朝7時に Daily AI Secretary を実行
0 7 * * * /bin/bash /path/to/daily-ai-secretary/scripts/daily-routine.sh
```

### macOS で確実に動かすコツ

- Macがスリープしていると cron は動きません。`pmset` で起動スケジュールを組むか、`launchd` を使ってください
- iCloud Drive 上の Vault を使っている場合、同期完了を待つために 7:00 → 7:05 など少し遅らせるとよいです

### `launchd` を使う場合の例

`~/Library/LaunchAgents/com.you.daily-ai-secretary.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.you.daily-ai-secretary</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>/Users/YOU/path/to/daily-ai-secretary/scripts/daily-routine.sh</string>
  </array>
  <key>StartCalendarInterval</key>
  <dict>
    <key>Hour</key><integer>7</integer>
    <key>Minute</key><integer>0</integer>
  </dict>
  <key>StandardOutPath</key>
  <string>/tmp/daily-ai-secretary.out</string>
  <key>StandardErrorPath</key>
  <string>/tmp/daily-ai-secretary.err</string>
</dict>
</plist>
```

ロード：

```bash
launchctl load ~/Library/LaunchAgents/com.you.daily-ai-secretary.plist
```

---

## 8. トラブルシューティング

### `gemini: command not found`
→ `npm install -g @google/gemini-cli` で再インストール。`npm bin -g` でグローバルbinのパスを確認し、PATHを通す。

### `GEMINI.md not found in Vault root`
→ `cp GEMINI.md "$VAULT_PATH/"` でVaultルートに配置できているか確認。

### iCloud Drive 上の Vault で同期が遅い
→ 出力ファイルがすぐに反映されない場合があります。`brctl monitor ~/Library/Mobile\ Documents` で同期状況を確認できます。

### 出力が英語になってしまう
→ `GEMINI.md` の「出力は日本語を基本とする」が読み込まれているか確認。プロンプトに `日本語で出力してください` を追記しても効果的です。

### コストが心配
→ Vaultのサイズを `du -sh "$VAULT_PATH"` で確認。大きい場合は `GEMINI.md` で対象フォルダを絞ってください。
