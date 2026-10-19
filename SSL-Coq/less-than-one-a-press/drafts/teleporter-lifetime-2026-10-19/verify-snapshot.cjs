'use strict';
const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const assert = require('node:assert/strict');
const manifest = JSON.parse(fs.readFileSync(path.join(__dirname, 'manifest.json'), 'utf8'));
const unit = path.resolve(__dirname, '../..');
let originals = 0;
for (const entry of manifest.entries) {
  const bytes = fs.readFileSync(path.join(__dirname, entry.file));
  assert.equal(bytes.length, entry.bytes, entry.file + ' byte length');
  assert.equal(crypto.createHash('sha256').update(bytes).digest('hex'),
    entry.sha256, entry.file + ' SHA-256');
  const original = path.join(unit, entry.original_unit_relative_path);
  if (fs.existsSync(original)) {
    assert.ok(bytes.equals(fs.readFileSync(original)), entry.file + ' differs from original scratch record');
    originals++;
  }
}
console.log('PASS: ' + manifest.entries.length + ' archived records match their hashes; ' +
  originals + ' available originals are byte-identical. This is an integrity check, not proof validation.');
