const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');
const test = require('node:test');
const path = require('node:path');

const source = fs.readFileSync(process.env.QGEN_JS_FILE || path.join(__dirname, '..', 'openai_questions', 'lib.js'), 'utf8');
const originalUrl = 'https://moodle.example.invalid/blocks/openai_questions/generate.php';

function browser(fetchImpl, empty = false) {
    const created = [];
    const button = {
        value: 'Add to question bank', disabled: false, style: {}, listeners: {},
        addEventListener(type, listener) { this.listeners[type] = listener; },
        parentNode: { insertBefore(node) { created.push(node); } },
    };
    const title = { value: 'A sample question?', removed: false };
    const question = {
        querySelector() { return title; },
        querySelectorAll() { return [{ value: 'True', dataset: { qid: 'A' }, classList: { contains: () => true } }]; },
        remove() { title.removed = true; },
    };
    const document = {
        querySelectorAll(selector) {
            return selector === '.block_openai_questions-question' && !empty ? [question] : [];
        },
        querySelector(selector) {
            if (selector === '#addToQBank') return button;
            if (selector === '#courseid') return { value: '18' };
            if (selector === '#qtype') return { value: 'truefalse' };
            if (selector === '#block_openai_questions-saveerror') return created[0] || null;
            return null;
        },
        createElement() {
            return { textContent: '', hidden: false, attributes: {}, setAttribute(name, value) { this.attributes[name] = value; } };
        },
    };
    const window = { location: { href: originalUrl }, setTimeout };
    vm.runInNewContext(source + '\ninit(null, 18, "https://moodle.example.invalid");', { document, window, fetch: fetchImpl, console });
    const click = () => button.listeners.click({ target: button, currentTarget: button, preventDefault() {} });
    return { button, window, title, created, click };
}

const success = { response: 200, data: { courseid: 18, savedcount: 1, categoryid: 16, questionids: [123] } };

for (const [name, response] of [
    ['HTTP failure keeps the generated question on screen', { ok: false, status: 404, json: async () => { throw new SyntaxError('HTML response'); } }],
    ['malformed success response does not navigate', { ok: true, status: 200, json: async () => { throw new SyntaxError('HTML response'); } }],
    ['application failure does not navigate', { ok: true, status: 200, json: async () => ({ response: 500 }) }],
    ['an unconfirmed save count does not navigate', { ok: true, status: 200, json: async () => ({ response: 200, data: { savedcount: 0 } }) }],
]) {
    test(name, async () => {
        const page = browser(async () => response);
        await assert.doesNotReject(page.click);
        assert.equal(page.window.location.href, originalUrl);
        assert.equal(page.button.value, 'Add to question bank');
        assert.equal(page.button.disabled, false);
        assert.equal(page.title.value, 'A sample question?');
        assert.equal(page.title.removed, false);
        assert.ok(page.created.some(node => node.attributes.role === 'alert' && node.textContent.length > 0));
        assert.match(page.created.find(node => node.attributes.role === 'alert').textContent, /check the question bank before trying again/i);
    });
}

test('network failure restores the save button and shows an error', async () => {
    const page = browser(async () => { throw new TypeError('Network unavailable'); });
    await assert.doesNotReject(page.click);
    assert.equal(page.window.location.href, originalUrl);
    assert.equal(page.button.disabled, false);
    assert.equal(page.button.value, 'Add to question bank');
    assert.ok(page.created.some(node => node.attributes.role === 'alert' && node.textContent.length > 0));
    assert.match(page.created.find(node => node.attributes.role === 'alert').textContent, /check the question bank before trying again/i);
});

test('a confirmed save navigates to the course question bank', async () => {
    const page = browser(async () => ({ ok: true, status: 200, json: async () => success }));
    await page.click();
    assert.equal(page.window.location.href, 'https://moodle.example.invalid/question/edit.php?courseid=18');
    assert.equal(page.created.length, 0);
});

test('an empty generated list sends no save request', async () => {
    let requests = 0;
    const page = browser(async () => { requests++; return { ok: true, json: async () => success }; }, true);
    await page.click();
    assert.equal(requests, 0);
    assert.equal(page.window.location.href, originalUrl);
});

test('a second click during a pending save sends no duplicate request', async () => {
    let finish;
    let requests = 0;
    const pending = new Promise(resolve => { finish = resolve; });
    const page = browser(() => { requests++; return pending; });
    const first = page.click();
    const second = page.click();
    finish({ ok: true, status: 200, json: async () => success });
    await Promise.all([first, second]);
    assert.equal(requests, 1);
});
