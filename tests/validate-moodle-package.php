<?php
// This validation helper does not install or upgrade the plugin.
if ($argc !== 3) {
    fwrite(STDERR, "Usage: QGEN_TEST_DB=isolated_db php tests/validate-moodle-package.php isolated-config.php plugin.zip\n");
    exit(2);
}
define('CLI_SCRIPT', true);
require $argv[1];
$expecteddb = getenv('QGEN_TEST_DB');
if (!$expecteddb || $CFG->dbname !== $expecteddb || empty($CFG->noemailever) || !empty($CFG->cron_enabled)) {
    throw new RuntimeException('An explicitly named isolated database with email and cron disabled is required.');
}
$zip = realpath($argv[2]);
if ($zip === false) {
    throw new RuntimeException('Package ZIP does not exist.');
}
require_once $CFG->dirroot . '/admin/tool/installaddon/classes/installer.php';
$component = tool_installaddon_installer::instance()->detect_plugin_component($zip);
if ($component !== 'block_openai_questions') {
    throw new RuntimeException('Moodle could not automatically detect the block component.');
}
$manager = core_plugin_manager::instance();
if ($manager->get_plugin_zip_root_dir($zip) !== 'openai_questions') {
    throw new RuntimeException('Moodle did not detect the expected single ZIP root.');
}
$extracted = make_request_directory();
$files = $manager->unzip_plugin_file($zip, $extracted);
$validator = \core\update\validator::instance($extracted, $files);
$validator->assert_plugin_type('block');
$validator->assert_moodle_version($CFG->version);
$passed = $validator->execute();
foreach ($validator->get_messages() as $message) {
    echo $message->level . ' ' . $message->msgcode . "\n";
}
if (!$passed) {
    throw new RuntimeException('Moodle package validation failed.');
}
$info = $validator->get_versionphp_info();
if ($info['version'] !== '2026111400' && (int)$info['version'] !== 2026111400) {
    throw new RuntimeException('Unexpected distribution version.');
}
echo 'PASS Moodle automatic component detection and standard package validation: ' . $component . "\n";
