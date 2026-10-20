'use strict';
const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const assert = require('node:assert/strict');
const manifest = JSON.parse(fs.readFileSync(path.join(__dirname, 'manifest.json'), 'utf8'));
const unit = path.resolve(__dirname, '../..');
let originals = 0;
let replacedLogs = 0;
for (const entry of manifest.entries) {
  const bytes = fs.readFileSync(path.join(__dirname, entry.file));
  assert.equal(bytes.length, entry.bytes, entry.file + ' byte length');
  assert.equal(crypto.createHash('sha256').update(bytes).digest('hex'),
    entry.sha256, entry.file + ' SHA-256');
  const original = path.join(unit, entry.original_unit_relative_path);
  if (fs.existsSync(original)) {
    const equal = bytes.equals(fs.readFileSync(original));
    if (!equal && entry.kind === 'historical_compiler_log') {
      // A later pipeline check replaces its live log at the original path.
      // The saved historical bytes must still pass the manifest hash above.
      replacedLogs++;
    } else {
      assert.ok(equal, entry.file + ' differs from original scratch record');
      originals++;
    }
  }
}
console.log('PASS: ' + manifest.entries.length + ' archived records match their hashes; ' +
  originals + ' available originals are byte-identical; ' + replacedLogs +
  ' live compiler logs have been replaced by later checks. This is an integrity check, not proof validation.');
