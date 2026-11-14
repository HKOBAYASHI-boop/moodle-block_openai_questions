# OpenAI Question Generator for Moodle 4.5

Moodleの問題バンクへの登録を修正したメンテナンス版です。日本語のコースでも、生成した問題を通常の既定カテゴリへ保存します。原作者はBryce Yoder氏で、元プロジェクトは [Limekiller/moodle-block_openai_questions](https://github.com/Limekiller/moodle-block_openai_questions) です。

This maintenance fork fixes question-bank registration for Moodle, including courses using Japanese category names. It is derived from Bryce Yoder's [OpenAI Question Generator](https://github.com/Limekiller/moodle-block_openai_questions).

**[インストール用ZIPをダウンロード / Download the installable ZIP](https://github.com/HKOBAYASHI-boop/moodle-block_openai_questions/releases/latest/download/block_openai_questions_moodle45_2026111400.zip)**

| 項目 / Item | 値 / Value |
|---|---|
| Component | `block_openai_questions` |
| Release | `1.2.1-hkobayashi.1` |
| Plugin version | `2026111400` |
| 対象 / Target | Moodle 4.5.x |
| 最低Moodleバージョン / Minimum Moodle version | `2024100700` / Moodle 4.5.0 |
| ライセンス / License | GPL-3.0-or-later |

## 日本語

### 変更点

- カテゴリがまだ存在しない場合、Moodle標準の処理で既定カテゴリを作成してから保存します。
- 英語の「Default」というカテゴリ名への依存をなくし、「top」ではなく通常の既定カテゴリを選びます。
- 複数問の保存途中で失敗した場合、同じ要求の保存全体を取り消します。
- 画面側がHTTP応答、JSON、保存件数を確認してから問題バンクへ移動します。
- 保存失敗時は生成済みの問題を画面に残し、エラーを表示して保存ボタンを復元します。
- 処理中の二重クリックを防ぎます。通信断などで結果が不明な場合は、再試行前に問題バンクを確認するよう案内します。

実行時の修正対象は `api/question.php` と `lib.js` です。配布に際して、バージョン情報、ZIPの構成、日英の説明文、ライセンス本文も整備しました。

### ZIPからインストールする

1. 上のリンク、または [Releases](https://github.com/HKOBAYASHI-boop/moodle-block_openai_questions/releases) から `block_openai_questions_moodle45_2026111400.zip` を取得します。
2. 更新前にMoodleのデータベースと対象プラグインをバックアップします。
3. 「サイト管理 → プラグイン → プラグインをインストールする」でZIPをアップロードします。
4. コンポーネント `block_openai_questions`、プラグインタイプ「ブロック」が認識されることを確認し、Moodleの検証・更新画面を進めます。
5. プラグイン設定で自身のOpenAI APIキーと利用可能なモデルを設定し、コースにQuestion Generatorブロックを追加します。

ZIPの直下は `openai_questions/` です。余分な `blocks/` フォルダは含めていません。手動配置する場合の保存先は `moodle/blocks/openai_questions/` です。Web画面からインストールする場合、Webサーバープロセスが `moodle/blocks/` に書き込める必要があります。

GitHubの「Code → Download ZIP」は開発用リポジトリ全体のアーカイブです。Moodleへアップロードするファイルには、上記の専用ZIPを使ってください。

### コース内で使う

「Generate questions」を開き、教材の文章、問題形式、問題数を指定します。生成された問題と解答を確認・編集し、「Add to question bank」で登録します。登録後はコースの問題バンクにある通常の既定カテゴリで表示・プレビューできます。対応形式は正誤、短答、多肢選択です。

### 動作確認した環境

| 構成 | 確認した値 |
|---|---|
| Moodle | 4.5.16 / Build 20261112 |
| PHP | 8.3.6 |
| MariaDB | 10.11.14 |
| OS | Ubuntu 24.04.4 LTS |
| 画面操作 | Google Chrome / Windows |
| OpenAIモデル | `gpt-4o-mini` |
| 回帰テスト | 保存処理6項目、画面処理8項目、未捕捉例外後の取り消し確認 |

2026-11-14に、実際のコースで3形式を各1問生成し、登録、強制再読み込み後の表示、プレビューの満点判定まで確認しました。配布する2つの実行時ファイルは、その検証済みファイルとSHA-256で一致します。[検証記録](docs/TESTING.md)に方法と限界を記載しています。Moodle 4.5以外の系列は未検証です。

### 開発時に確認する

追加のNode.js依存パッケージは不要です。リポジトリのルートで、構文検査と画面処理の回帰テストを実行します。

```powershell
node --check openai_questions/lib.js
node --test tests/frontend.test.cjs
```

PowerShellでZIPを再作成できます。既存の成果物を上書きしないよう、再作成時は新しい出力フォルダを指定します。

```powershell
pwsh -NoProfile -File scripts/Build-Package.ps1 -OutputDirectory ./tmp/rebuild
pwsh -NoProfile -File scripts/Verify-Package.ps1
```

ZIP内のファイル構成、ソースとの一致、検証済み2ファイルのハッシュ、バージョン情報、認証情報に該当する文字列パターンを検査します。ファイルの順序とZIP内の時刻は固定します。同じビルド環境での再作成を確認するための仕組みであり、異なる圧縮ライブラリ間でZIP全体のバイト一致を保証するものではありません。

## English

### Changes

- Initialize missing default question categories through Moodle's standard helper.
- Select the ordinary course default category without depending on the English word `Default` or using `top`.
- Wrap a batch in a transaction so a failed save does not leave partially registered questions.
- Check the HTTP response, JSON result and saved count before redirecting to the question bank.
- Retain generated questions and restore the save button after an error.
- Prevent concurrent double-click submissions. When the save result is unknown, ask the user to check the bank before retrying.

The runtime changes are limited to `api/question.php` and `lib.js`. Distribution metadata, package layout, bilingual documentation and the license text have also been prepared for this release.

### Install from ZIP

1. Download `block_openai_questions_moodle45_2026111400.zip` from the link above or [Releases](https://github.com/HKOBAYASHI-boop/moodle-block_openai_questions/releases).
2. Back up the database and existing plugin before upgrading.
3. In Moodle, open **Site administration → Plugins → Install plugins** and upload the ZIP.
4. Verify that Moodle detects component `block_openai_questions` and type **Block**, then complete validation and the upgrade screens.
5. Configure your own OpenAI API key and an available model, then add the Question Generator block to a course.

The ZIP has exactly one root directory, `openai_questions/`. For manual deployment, place it at `moodle/blocks/openai_questions/`. Web installation requires the web server process to be able to write to `moodle/blocks/`. Use the dedicated plugin ZIP for Moodle; GitHub's **Code → Download ZIP** contains the entire development repository.

### Use in a course

Open **Generate questions**, enter source text, choose the question type and count, then review the generated questions and answers. Select **Add to question bank**. The questions become available in the course's ordinary default category for viewing and previewing. Supported question types are True/False, Short Answer and Multiple Choice.

### Tested environment and scope

The live workflow was verified on **2026-11-14** with Moodle **4.5.16, Build 20261112**, PHP **8.3.6**, MariaDB **10.11.14**, Ubuntu **24.04.4 LTS**, Google Chrome on Windows and **gpt-4o-mini**. One question of each type was generated, saved, displayed after a forced reload and graded at full marks in preview.

The distributed runtime files match those verified files by SHA-256. Regression checks cover six backend scenarios, eight frontend scenarios and rollback following an uncaught save exception. See [the test record](docs/TESTING.md) for methods and limitations. Other Moodle branches have not been verified.

### Development checks

No additional Node.js packages are required. Run `node --check openai_questions/lib.js` and `node --test tests/frontend.test.cjs` from the repository root. Use `scripts/Build-Package.ps1` with a new `-OutputDirectory` to rebuild without overwriting existing artifacts, and `scripts/Verify-Package.ps1` to verify the distributed ZIP. File ordering and ZIP timestamps are fixed; byte-for-byte reproduction is intended for the same build environment, not guaranteed across different compression libraries.

## 出典とライセンス / Credits and license

Original author: **Bryce Yoder**. Upstream: [Limekiller/moodle-block_openai_questions](https://github.com/Limekiller/moodle-block_openai_questions). This release is based on the installed **1.2.0 / 2023121500** baseline. Maintenance modifications were made on **2026-11-14** by **HKOBAYASHI-boop**; they are described in [CHANGELOG.md](CHANGELOG.md).

原作者の著作権表示を保持しています。本修正版はGNU General Public License version 3 or laterで配布します。This modified distribution retains the original copyright notices and is licensed under the **GNU GPL version 3 or later**. See [LICENSE](LICENSE).

## 参照 / References

- [Moodle: plugin version metadata](https://moodledev.io/docs/4.5/apis/commonfiles/version.php)
- [Moodle: installing plugins](https://docs.moodle.org/405/en/plugins/index)
