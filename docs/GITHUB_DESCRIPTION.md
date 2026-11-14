# GitHub用説明文 / GitHub descriptions

## About欄 / About field

OpenAI Question Generator for Moodle 4.5: reliable question-bank saves / Moodleの問題バンク登録を修正したメンテナンス版

## 日本語の説明文

Moodle 4.5向けOpenAI Question Generatorのメンテナンス版です。カテゴリ未作成時の保存失敗と、日本語の既定カテゴリを正しく選択できない問題を修正しました。保存結果を確認してから問題バンクへ移動し、エラー時は生成済みの問題を画面に残します。一括保存の途中失敗と処理中の二重送信にも対応しました。

Moodle 4.5.16、PHP 8.3.6、MariaDB 10.11.14、Ubuntu 24.04.4 LTS、Google Chrome、gpt-4o-miniの環境で、正誤・短答・多肢選択の生成、問題バンクへの登録、再読み込み後の表示、プレビュー採点を確認しています。専用ZIPからインストールできます。原作者Bryce Yoder氏の表示を維持し、GNU GPL v3以降で配布します。

## English description

A maintenance fork of OpenAI Question Generator for Moodle 4.5. It fixes saves when the default question category has not yet been created and corrects category selection in Japanese-language courses. The interface verifies the save result before redirecting and retains generated questions after an error. Batch rollback and concurrent duplicate-click prevention are included.

The generation, question-bank registration, display after reload and preview grading workflows were verified for True/False, Short Answer and Multiple Choice on Moodle 4.5.16, PHP 8.3.6, MariaDB 10.11.14, Ubuntu 24.04.4 LTS, Google Chrome and gpt-4o-mini. A dedicated installable ZIP is provided. Bryce Yoder's attribution is retained, and the distribution is licensed under GNU GPL v3 or later.
