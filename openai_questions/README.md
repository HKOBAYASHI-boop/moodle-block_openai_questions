# OpenAI Question Generator for Moodle 4.5

## 日本語

リリース `1.2.1-hkobayashi.1`、バージョン `2026111400`。Moodle 4.5向けのメンテナンス版です。2026-11-14にHKOBAYASHI-boopが、問題バンクへの保存とエラー表示を修正しました。

`api/question.php` はMoodle標準の処理で通常の既定カテゴリを取得・初期化し、途中で失敗した場合は同じ要求の保存全体を取り消します。`lib.js` は保存成功を確認してから問題バンクへ移動し、失敗時は生成済みの問題を画面に残します。結果が不明な場合は再試行前に問題バンクを確認してください。

ZIPの直下は `openai_questions/` です。「サイト管理 → プラグイン → プラグインをインストールする」からZIPをアップロードすると、プラグインタイプは「ブロック」として検出されます。Webサーバープロセスが `moodle/blocks/` に書き込める必要があります。手動配置先は `moodle/blocks/openai_questions/` です。

自身のOpenAI APIキーと利用可能なモデルを設定してコースにブロックを追加します。「Generate questions」で教材文、問題形式、問題数を指定し、生成内容を確認して「Add to question bank」で登録します。正誤、短答、多肢選択に対応します。

## English

Release `1.2.1-hkobayashi.1`, version `2026111400`. This Moodle 4.5 maintenance distribution was modified on 2026-11-14 by HKOBAYASHI-boop to fix question-bank saves and error reporting.

`api/question.php` initializes and selects the ordinary default category using Moodle's standard helper and rolls back the batch if saving fails. `lib.js` checks the save result before redirecting and retains generated questions after errors. Check the bank before retrying when the result is unknown.

Upload the dedicated ZIP in **Site administration → Plugins → Install plugins**. Moodle detects type **Block**. The ZIP root is `openai_questions/`, and the manual installation path is `moodle/blocks/openai_questions/`. The web server process needs write access to `moodle/blocks/` for web installation.

Configure your own OpenAI API key and an available model, add the block to a course, generate questions from text, review them and select **Add to question bank**. True/False, Short Answer and Multiple Choice are supported.

## 出典・詳細 / Credits and details

Original author: **Bryce Yoder**. Upstream: https://github.com/Limekiller/moodle-block_openai_questions . Original copyright notices are retained. Licensed under **GNU GPL version 3 or later**; see `COPYING.txt`.

日英の変更履歴と検証環境 / Bilingual changes and test environment: https://github.com/HKOBAYASHI-boop/moodle-block_openai_questions
