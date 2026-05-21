#!/bin/bash

# ============================================================================
# Daily AI Secretary — 毎日実行スクリプト
# ----------------------------------------------------------------------------
# Obsidian Vault に対して Gemini CLI を起動し、GEMINI.md の指示に従って
# daily-briefing.md やナレッジマップなどを自動更新します。
#
# 使い方:
#   1. 下の VAULT_PATH を自分の Obsidian Vault のパスに書き換える
#   2. (任意) MODEL を変更する
#   3. bash scripts/daily-routine.sh
#
# cron で毎朝自動実行する例:
#   0 7 * * * /bin/bash /path/to/daily-ai-secretary/scripts/daily-routine.sh
# ============================================================================

# --- 設定 -------------------------------------------------------------------

# 環境変数 VAULT_PATH があればそれを優先、なければデフォルトを使用
VAULT_PATH="${VAULT_PATH:-$HOME/Documents/ObsidianVault}"

# 使用するモデル
MODEL="${GEMINI_MODEL:-gemini-2.5-pro}"

# プロンプト（GEMINI.md が読み込まれる前提のため、簡潔でよい）
PROMPT="今日のObsidian routineを完全に実行せよ。GEMINI.mdの全指示に従い、既存ファイルは一切変更せず、gemini/フォルダ内にのみ出力せよ。"

# ログ出力先（任意）
LOG_DIR="${LOG_DIR:-$HOME/.local/share/daily-ai-secretary/logs}"
LOG_FILE="$LOG_DIR/daily-$(date +%Y-%m-%d).log"

# --- 事前チェック -----------------------------------------------------------

if [ ! -d "$VAULT_PATH" ]; then
  echo "[ERROR] Vault path not found: $VAULT_PATH" >&2
  echo "        スクリプト先頭の VAULT_PATH を編集するか、環境変数で指定してください。" >&2
  exit 1
fi

if [ ! -f "$VAULT_PATH/GEMINI.md" ]; then
  echo "[ERROR] GEMINI.md not found in Vault root: $VAULT_PATH/GEMINI.md" >&2
  echo "        リポジトリ直下の GEMINI.md を Vault ルートにコピーしてください。" >&2
  exit 1
fi

if ! command -v gemini >/dev/null 2>&1; then
  echo "[ERROR] gemini CLI が見つかりません。" >&2
  echo "        インストール: npm install -g @google/gemini-cli" >&2
  exit 1
fi

mkdir -p "$LOG_DIR"
mkdir -p "$VAULT_PATH/gemini/archive"

# --- 実行 -------------------------------------------------------------------

cd "$VAULT_PATH" || exit 1

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting daily AI secretary routine..." | tee -a "$LOG_FILE"
echo "  Vault: $VAULT_PATH" | tee -a "$LOG_FILE"
echo "  Model: $MODEL" | tee -a "$LOG_FILE"

gemini \
  -m "$MODEL" \
  -p "$PROMPT" \
  --approval-mode yolo \
  --output-format text \
  2>&1 | tee -a "$LOG_FILE"

EXIT_CODE=${PIPESTATUS[0]}

if [ "$EXIT_CODE" -eq 0 ]; then
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Done." | tee -a "$LOG_FILE"
else
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Failed with exit code $EXIT_CODE" | tee -a "$LOG_FILE" >&2
fi

exit "$EXIT_CODE"
