# 変更履歴 / Changelog

## 1.2.1-hkobayashi.1 / 2026111400 / 2026-11-14

### 日本語

HKOBAYASHI-boopによるメンテナンス修正です。原作者Bryce Yoder氏の表示とGNU GPL v3以降のライセンスを維持します。

- `api/question.php`: 通常の既定カテゴリをMoodle標準の関数で初期化・取得し、コースへの所属と親カテゴリを検証します。英語名の「Default」への依存を廃止します。
- `api/question.php`: 保存全体をトランザクションにまとめ、成功時に件数・カテゴリ番号・問題番号を返します。途中で失敗した場合は保存全体を取り消します。
- `lib.js`: HTTP・JSON・保存件数を確認してから移動します。エラー時は問題を残して保存ボタンを復元し、結果不明時は問題バンクを先に確認するよう案内します。処理中の二重クリックも防ぎます。
- 配布物の `version.php`: バージョンを `2023121500` から `2026111400` へ更新し、最低Moodleバージョンを4.5、対象系列を4.5として明示します。
- 配布物: ZIPの直下を `openai_questions/` に統一します。日英のREADME、ライセンス本文、検証記録、回帰テスト、パッケージ作成・検査スクリプトを追加します。

### English

Maintenance changes by HKOBAYASHI-boop. Bryce Yoder's copyright notices and the GNU GPL v3-or-later license are retained.

- `api/question.php`: Initialize and select the ordinary default category through Moodle's standard helper, validate its context and parent, and remove the English `Default` name dependency.
- `api/question.php`: Save a batch in one transaction and return its count, category and question IDs. Roll back the whole batch on failure.
- `lib.js`: Validate HTTP, JSON and saved count before redirecting. Keep generated questions after errors, restore the button, advise checking the bank when the result is unknown, and prevent concurrent duplicate clicks.
- Distribution metadata: Increase the plugin version from `2023121500` to `2026111400`, require Moodle 4.5 and declare the 4.5 branch as the target.
- Distribution: Use one `openai_questions/` ZIP root and add bilingual documentation, the full license, a test record, regression tests and packaging scripts.

## 基準版 / Baseline

この修正版は、導入済みのリリース `1.2.0`、プラグインバージョン `2023121500` を基準にしています。上流の現在の最新コミットと同一であるとの主張はしていません。

The baseline is the installed release `1.2.0`, plugin version `2023121500`. It is not represented as the current upstream HEAD.
