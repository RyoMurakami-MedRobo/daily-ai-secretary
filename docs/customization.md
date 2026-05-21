# カスタマイズガイド

`GEMINI.md` を編集するだけで、AI秘書の挙動を自由に変えられます。
よくあるカスタマイズ例をまとめます。

---

## 1. 出力言語を変える

`GEMINI.md` の以下の行を編集：

```markdown
- 出力は **日本語**を基本とする
```

→ 英語にしたい場合：

```markdown
- All outputs must be in **English**
```

---

## 2. 業務に合わせたフォーマット

### 営業日報フォーマット

`GEMINI.md` の「毎日実行するタスク」に追加：

```markdown
9. **営業日報**：`gemini/sales-report-YYYY-MM-DD.md` を作成
   - 訪問先・案件・金額・次のアクションを表形式で
   - フォーマット：
     | 訪問先 | 案件 | 金額 | 次アクション | 期限 |
     |--------|------|------|--------------|------|
```

### 開発チーム向け（スクラム）

```markdown
9. **デイリースクラム準備**：daily-briefingの先頭に以下を追加
   - 昨日やったこと
   - 今日やること
   - ブロッカー
```

### 研究者向け

```markdown
9. **論文進捗トラッキング**：`gemini/papers-database.md` を更新
   - 各論文のステータス（Draft/Review/Submitted/Accepted）
   - 次の締切と必要なアクション
```

---

## 3. 読み込み対象フォルダの絞り込み

Vaultが巨大でコストが気になる場合、特定フォルダだけを対象にできます。

```markdown
## スコープ
以下のフォルダのみを読み込むこと：
- `0_Thoughts/Daily/`
- `meetings/`
- `projects/`
それ以外のフォルダは無視すること。
```

---

## 4. プライバシー保護フォルダの追加

```markdown
- 以下のフォルダは**絶対に読まない**：
  - `Private/`
  - `Not4AI/`
  - `Finances/`
  - `MedicalRecords/`
  - `Personal-Journal/`
```

---

## 5. 出力先フォルダ名の変更

`gemini/` を `ai-output/` に変えたい場合：

1. `GEMINI.md` 内の `gemini/` をすべて `ai-output/` に置換
2. `scripts/daily-routine.sh` の `mkdir -p "$VAULT_PATH/gemini/archive"` を書き換え

---

## 6. 別のLLM CLIに乗り換える

### Claude Code を使う場合

```bash
# scripts/daily-routine.sh の gemini コマンド部分を以下に置き換え
claude -p "$PROMPT" --dangerously-skip-permissions
```

なお、Claude Code は `CLAUDE.md` を自動読み込みするので、`GEMINI.md` を `CLAUDE.md` にコピーするか、シンボリックリンクを張ってください：

```bash
cd "$VAULT_PATH"
ln -s GEMINI.md CLAUDE.md
```

### OpenAI CLI を使う場合

OpenAI公式の対話CLIはないので、`openai` ライブラリを使う簡易ラッパーを書く必要があります。
詳しくは [examples/openai-wrapper.py](../examples/) を参照（将来追加予定）。

---

## 7. 実行頻度を変える

### 1日2回実行（朝・夕）

`crontab -e`:

```cron
0 7  * * * /bin/bash /path/to/daily-ai-secretary/scripts/daily-routine.sh
0 18 * * * /bin/bash /path/to/daily-ai-secretary/scripts/daily-routine.sh
```

夕方の実行で、その日に追加されたメモを早めに整理してもらえます。

### 平日のみ

```cron
0 7 * * 1-5 /bin/bash /path/to/daily-ai-secretary/scripts/daily-routine.sh
```

---

## 8. Slack / メール通知を追加する

`scripts/daily-routine.sh` の末尾に追加：

```bash
# Slack 通知（Incoming Webhook 必要）
if [ "$EXIT_CODE" -eq 0 ]; then
  SUMMARY=$(head -30 "$VAULT_PATH/gemini/daily-briefing.md")
  curl -X POST -H 'Content-type: application/json' \
    --data "{\"text\":\"今日のBriefingが生成されました\\n${SUMMARY}\"}" \
    "$SLACK_WEBHOOK_URL"
fi
```

---

## 9. 個別タスクをワンショット実行

毎日の routine ではなく、特定の用途で実行したい場合：

```bash
# 例：先週の振り返りだけ実行
cd "$VAULT_PATH"
gemini -m gemini-2.5-pro \
  -p "先週（過去7日）のメモを総括し、gemini/weekly-review.md を作成せよ" \
  --approval-mode yolo
```

複数のスクリプトを `scripts/` 配下に並べて、用途別に管理できます：

```
scripts/
├── daily-routine.sh      # 毎朝
├── weekly-review.sh      # 毎週末
└── project-handoff.sh    # 不定期、引き継ぎ資料生成
```

---

## 10. 既存ノートも書き換えてほしい場合

デフォルトではAIに **「既存ファイルを変更しない」** と厳命していますが、
あえて自動整理させたい場合：

`GEMINI.md` から以下の行を削除：

```markdown
- **既存のファイル・フォルダは一切変更しない**（読み取り専用）
```

代わりに、以下のような明示的な許可を書く：

```markdown
- 既存ファイルの変更を許可する対象：
  - `inbox/` 配下のノート（整理して `knowledge/` に移してよい）
  - `0_Thoughts/raw-notes/` のメモ（要約して短くしてよい）
- それ以外のフォルダの既存ファイルは変更しない
```

⚠️ **重要**: 必ず最初にVault全体をGitで管理するか、別の場所にバックアップを取ってください。

---

## カスタマイズのヒント

- 何かを追加する前に、**まず1週間そのままで運用する**こと
- 不満が出てきたら、その不満を `daily-briefing.md` の末尾に「コメント：」として書く
- フィードバック学習のループが、自然と GEMINI.md の改善方針を示してくれる
- 「自分専用にしすぎないよう」、汎用的な指示を残しておくと将来チームに広げやすい
