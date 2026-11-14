# 1.2.1-hkobayashi.1

## 日本語

Moodle 4.5の問題バンク保存を修正したメンテナンス版です。添付の `block_openai_questions_moodle45_2026111400.zip` を「サイト管理 → プラグイン → プラグインをインストールする」からアップロードしてください。タイプは「ブロック」、コンポーネントは `block_openai_questions` として認識されます。

- 未作成の既定カテゴリを初期化し、日本語のカテゴリでも通常の既定カテゴリへ保存します。
- 保存結果を確認してから移動し、エラー時は生成した問題を保持します。
- 複数問の途中失敗をまとめて取り消し、処理中の二重クリックを防ぎます。
- バージョンは `2026111400`、対象はMoodle 4.5系です。

Moodle 4.5.16、PHP 8.3.6、MariaDB 10.11.14、Ubuntu 24.04.4 LTSで検証しました。実画面では正誤・短答・多肢選択の生成、登録、再読み込み後の表示、プレビューの満点判定を確認しています。詳細はリポジトリの `docs/TESTING.md` を参照してください。

添付の `SHA256SUMS.txt` でZIPの一致を確認できます。原作者はBryce Yoder氏で、ライセンスはGNU GPL v3以降です。

## English

This maintenance release fixes question-bank saves on Moodle 4.5. Upload the attached `block_openai_questions_moodle45_2026111400.zip` through **Site administration → Plugins → Install plugins**. Moodle detects type **Block** and component `block_openai_questions`.

- Initialize missing default categories and select the ordinary default category independently of its translated name.
- Confirm successful saves before redirecting and retain generated questions after errors.
- Roll back a failed batch and prevent concurrent double-click submissions.
- Plugin version: `2026111400`. Target branch: Moodle 4.5.

Verified with Moodle 4.5.16, PHP 8.3.6, MariaDB 10.11.14 and Ubuntu 24.04.4 LTS. Live generation, registration, display after reload and full-mark preview grading were checked for True/False, Short Answer and Multiple Choice. See `docs/TESTING.md` for details and limitations.

The attached `SHA256SUMS.txt` provides the ZIP checksum. Original author: Bryce Yoder. License: GNU GPL v3 or later.
