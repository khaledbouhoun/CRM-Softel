# -*- coding: utf-8 -*-
"""Helper to append keys to the three ARB files (fr is the template).

    add_many([dict(key='k', fr='...', en='...', ar='...', params={'count': 'int'})])

Existing keys are overwritten, so a script can be re-run safely.
"""
import json
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def _path(lang):
    return os.path.join(ROOT, 'lib', 'l10n', 'app_%s.arb' % lang)


def _load(lang):
    with open(_path(lang), encoding='utf-8') as f:
        return json.load(f)


def _save(lang, data):
    with open(_path(lang), 'w', encoding='utf-8', newline='\n') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        f.write('\n')


def add_many(entries):
    docs = {lang: _load(lang) for lang in ('fr', 'en', 'ar')}
    for e in entries:
        for lang in ('fr', 'en', 'ar'):
            docs[lang][e['key']] = e[lang]
        if e.get('params'):
            docs['fr']['@' + e['key']] = {
                'placeholders': {n: {'type': t} for n, t in e['params'].items()}}
    for lang, data in docs.items():
        _save(lang, data)
    print('added %d keys' % len(entries))


def edit(path, old, new):
    """Exact, unique replacement in a source file."""
    full = os.path.join(ROOT, path)
    with open(full, encoding='utf-8') as f:
        src = f.read()
    if old not in src:
        raise SystemExit('pattern not found in %s: %r' % (path, old[:80]))
    with open(full, 'w', encoding='utf-8', newline='\n') as f:
        f.write(src.replace(old, new, 1))
