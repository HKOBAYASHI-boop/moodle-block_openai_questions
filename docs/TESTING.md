# 検証記録 / Test record

## 日本語

検証日は2026-11-14です。実行時の修正は `api/question.php` と `lib.js` に限定しています。配布物ではバージョン情報と説明文も更新しています。

| 構成 | 実際に確認した値 |
|---|---|
| Moodle | 4.5.16 / Build 20261112 / `2024100716.00` |
| PHP | 8.3.6 |
| MariaDB | 10.11.14 |
| OS | Ubuntu 24.04.4 LTS |
| ブラウザー | Google Chrome / Windows |
| OpenAIモデル | `gpt-4o-mini` |
| ローカルのJavaScriptテスト | Node.js 22.21.0 |

### 画面で確認した

既存の検証用コースで正誤・短答・多肢選択を各1問生成しました。画面から問題バンクへ登録し、通常の既定カテゴリに「準備完了」で表示されること、強制再読み込み後も残ること、プレビューで正しい回答が1.00 / 1.00となることを確認しました。データベースの保存先と採点記録も照合しました。生成3回・登録3回のHTTP応答はすべて200でした。

この画面確認は、今回のリリースに含まれる2つの実行時ファイルのハッシュと一致する修正を使って行いました。配布作業のために同じ有料API要求を重ねて実行することはしていません。

### 保存処理を検証した

バックアップから復元した分離データベースで、実際のエンドポイントの保存ロジックとMoodle標準の保存処理を通しました。設定ファイルの読込先とHTTP本文の入力元だけを検証用に差し替え、保存処理自体は模倣していません。

1. 既定カテゴリが既にある正常系を確認しました。
2. カテゴリがないコースでの初期化と保存を確認しました。
3. 日本語のコースで通常の既定カテゴリが選ばれることを確認しました。
4. 短答問題の解答と満点率の保存を確認しました。
5. 多肢選択の2問をまとめて保存し、各問に4解答と満点率1の正答1件があることを確認しました。
6. 2問目の保存を失敗させ、一部の問題だけが残らないことを確認しました。

追加で、例外を捕捉しないPHPプロセスの終了後に、別接続から残存件数を確認しました。修正前は1問、修正版は0問でした。障害を起こすテストは本番データベースで実行していません。

### 画面処理を検証した

`tests/frontend.test.cjs` は、実際の `lib.js` を読み込み、HTTP失敗、JSON不正、失敗応答、保存件数不一致、通信断、正常保存、空の問題一覧、処理中の二重クリックを確認します。外部APIや実際のブラウザーには接続せず、通信部分と最小限の画面要素を検証用に置き換えます。

### 配布ZIPを検証した

完成ZIPは14ファイルで、直下は `openai_questions/` の1フォルダです。ZIP内の全ファイルと配布ソースの一致、検証済み2ファイルのハッシュ、バージョン情報、認証情報に該当する文字列パターンの検査に合格しました。同じ環境で別フォルダへ再作成したZIPも、SHA-256が一致しました。

ZIPのSHA-256は `98d167786db5d0418bee256fecb2d64ae9e1a68222474dbfa34dd8440a502a7e` です。

Moodle 4.5.16の `tool_installaddon_installer::detect_plugin_component()` は `block_openai_questions` を自動認識しました。標準の `core\update\validator` でも、ファイル構成、コンポーネント、Moodle必要バージョン、英語言語ファイル、配置先の検査を通過しました。既存プラグインがあることを示す `targetexists` の警告は想定どおりで、検査結果は合格です。この検査は分離したデータベースと一時領域を使うCLI検証で、プラグインのインストール・更新は行いません。

ZIPを非公開の検証領域へ展開し、PHP全10ファイルの構文検査を通しました。その展開済みエンドポイントを使って保存処理6項目を再実行し、すべて合格しました。未捕捉例外後の残存件数も0件でした。公開ソースの画面処理テスト8項目も合格しました。

保存処理の環境固有CLIハーネスについては、この文書に結果と方法を記録しています。公開リポジトリには、単独で実行できる画面処理のテストと、分離したMoodle環境で使える `tests/validate-moodle-package.php` を収録しています。後者は `QGEN_TEST_DB` で検証用データベース名を明示し、メールとcronを無効にした検証用設定ファイルを指定して実行します。設定ファイルやデータベースの実体は配布物へ含めていません。

### 検証の限界を示す

検証済みコードとの一致を維持するため、修正範囲外にある元プラグインの行末空白を除去する整形は行っていません。このため、初回コミット全体の `git diff --check` では元ファイルの行末空白が指摘されます。新規の配布用ファイルと、修正前後の実行時コードの追加行は分けて確認します。

Moodle全体のPHPUnitスイートは、実行用の依存関係が環境にないため未実施です。対応を確認した系列はMoodle 4.5で、他系列とすべてのOS・ブラウザーの組み合わせは未検証です。画面テストは機能確認用の教材を使っており、授業で用いる問題の内容妥当性を評価した結果ではありません。

本リリースのZIPを本番へ再インストールする作業は、配布作成の範囲には含めていません。Webインストールの可否には対象サーバーの書き込み権限も関係します。通信切断時には、保存が完了している可能性があるため、再試行前に問題バンクを確認する必要があります。処理中の二重クリック防止は、すべての再送に対する重複排除を保証するものではありません。

## English

Verification date: **2026-11-14**. The runtime patch is limited to `api/question.php` and `lib.js`; distribution metadata and documentation are also updated for this release.

The live environment was Moodle **4.5.16 / Build 20261112 / 2024100716.00**, PHP **8.3.6**, MariaDB **10.11.14**, Ubuntu **24.04.4 LTS**, Google Chrome on Windows and **gpt-4o-mini**. Local JavaScript checks use **Node.js 22.21.0**.

### Live workflow

One question of each type was generated in a test course, registered through the UI, displayed as ready in the ordinary default category after a forced reload and graded at **1.00 / 1.00** in preview. Database category and grading records were cross-checked. All three generation and three save requests returned HTTP 200. The distributed runtime hashes match the files used for this live verification; paid generation calls were not repeated solely for packaging.

### Regression checks

Six backend scenarios exercise the real endpoint logic and Moodle save functions against a restored, isolated database: existing category, missing category, Japanese category, Short Answer answers, a two-question Multiple Choice batch, and rollback on a later failure. Only configuration loading and HTTP-body input are adapted for the CLI harness. An additional uncaught-exception process check leaves zero partially saved questions after exit; the original code leaves one. Destructive failure scenarios are not run against production.

The eight frontend scenarios load the real `lib.js` and replace only network and minimal DOM boundaries. They cover HTTP failure, invalid JSON, application failure, unconfirmed count, network error, successful save, empty questions and concurrent duplicate clicks. The test does not call OpenAI or operate a real browser.

### Distribution checks

The final ZIP contains **14 files** under the single `openai_questions/` root. All packaged files match the distribution source. Verified runtime hashes, version metadata and credential-pattern checks pass. Rebuilding into a separate directory in the same environment produces an identical SHA-256:

`98d167786db5d0418bee256fecb2d64ae9e1a68222474dbfa34dd8440a502a7e`

Moodle 4.5.16's `tool_installaddon_installer::detect_plugin_component()` automatically detects `block_openai_questions`. Its standard `core\update\validator` passes the layout, component, required Moodle version, English language-file and target-location checks. The expected `targetexists` warning reports an existing plugin; the overall validation passes. This CLI check uses an isolated database and temporary files and does not install or upgrade the plugin.

All **10 packaged PHP files** pass syntax checks. The **six backend scenarios** are re-run against the endpoint extracted from the final ZIP and all pass; the uncaught-exception process check leaves **zero** partial questions. The **eight frontend scenarios** also pass against the published source.

The environment-specific backend harness is documented here through its method and results. The public repository includes the self-contained frontend tests and `tests/validate-moodle-package.php`, which can run against an isolated Moodle environment. Set `QGEN_TEST_DB` to its explicit database name and supply a test configuration with email and cron disabled. Configuration files and database contents are not distributed.

### Limitations

Pre-existing trailing whitespace outside the runtime patch is retained to preserve the verified source bytes. A whole-tree whitespace check of the initial import therefore reports inherited lines. Newly added distribution files and added lines in the runtime patch are checked separately.

The complete Moodle PHPUnit suite was not run because its development dependencies are not installed. Other Moodle branches and all possible browser/OS combinations have not been verified. Test questions establish functional behavior, not the educational validity of generated material.

Reinstalling this release ZIP onto production is outside the packaging task. Web installation also depends on server-side write permissions. If a connection is lost, the save may already have committed; check the bank before retrying. Concurrent double-click prevention is not a universal idempotency guarantee.
