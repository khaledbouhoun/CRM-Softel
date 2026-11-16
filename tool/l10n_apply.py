# -*- coding: utf-8 -*-
"""One-shot migration: replaces extracted French literals by `tr.<key>` and
writes lib/l10n/app_{fr,en,ar}.arb from tool/l10n_map.py.

Run from the project root:  python tool/l10n_apply.py
After that the ARB files are the source of truth (edit them directly).
"""
import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import l10n_extract as ex  # noqa: E402
from l10n_map import ENTRIES  # noqa: E402

ROOT = ex.ROOT
PLACEHOLDER = re.compile(r'\{(\w+)\}')


def unnamed(text):
    return PLACEHOLDER.sub('{}', text)


def build_index():
    by_flat = {}
    keys = {}
    for fr, key, en, ar in ENTRIES:
        flat = unnamed(fr)
        names = PLACEHOLDER.findall(fr)
        if flat in by_flat and by_flat[flat][0] != key:
            raise SystemExit('Same French text mapped to two keys: %r (%s / %s)' % (flat, by_flat[flat][0], key))
        by_flat[flat] = (key, names)
        if key in keys:
            if keys[key][1:3] != (en, ar):
                raise SystemExit('Key %s defined twice with different translations' % key)
            continue
        keys[key] = (fr, en, ar, names)
    return by_flat, keys


def relative_import(path):
    target = os.path.join(ex.LIB, 'app', 'l10n', 'l10n.dart')
    rel = os.path.relpath(target, os.path.dirname(path)).replace(os.sep, '/')
    return "import '%s';" % rel


def add_import(src, path):
    line = relative_import(path)
    if line in src:
        return src
    imports = list(re.finditer(r"^import [^\n]*;\n", src, re.M))
    if not imports:
        return line + '\n\n' + src
    last = imports[-1]
    return src[:last.end()] + line + '\n' + src[last.end():]


def write_arbs(keys):
    for lang, idx in (('fr', 0), ('en', 1), ('ar', 2)):
        path = os.path.join(ROOT, 'lib', 'l10n', 'app_%s.arb' % lang)
        out = {'@@locale': lang}
        for key, (fr, en, ar, names) in keys.items():
            out[key] = (fr, en, ar)[idx]
            if lang == 'fr' and names:
                out['@' + key] = {'placeholders': {n: {'type': 'Object'} for n in names}}
        with open(path, 'w', encoding='utf-8', newline='\n') as f:
            json.dump(out, f, ensure_ascii=False, indent=2)
            f.write('\n')


def main():
    by_flat, keys = build_index()
    items = ex.collect()
    by_file = {}
    missing = set()
    for path, start, end, parts, triple in items:
        flat = ex.flat_of(parts).replace('\x00DOLLAR', '$')
        flat = flat.replace('\x00DOLLAR', '$')
        if flat not in by_flat:
            missing.add(flat)
        by_file.setdefault(path, []).append((start, end, parts, flat))
    if missing:
        for m in sorted(missing):
            print('MISSING', repr(m))
        raise SystemExit('%d messages have no entry in l10n_map.py' % len(missing))

    for path, edits in by_file.items():
        src = open(path, encoding='utf-8').read()
        for start, end, parts, flat in sorted(edits, key=lambda e: -e[0]):
            key, names = by_flat[flat]
            args = [text for kind, text in parts if kind == 'e']
            call = 'tr.%s' % key if not args else 'tr.%s(%s)' % (key, ', '.join(args))
            src = src[:start] + call + src[end:]
        src = add_import(src, path)
        with open(path, 'w', encoding='utf-8', newline='\n') as f:
            f.write(src)
    write_arbs(keys)
    print('rewrote %d files, %d keys' % (len(by_file), len(keys)))


if __name__ == '__main__':
    main()
