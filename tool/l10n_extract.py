"""Finds user-visible French string literals in lib/ (development helper).

Usage: python tool/l10n_extract.py [--apply]

Without --apply it only prints the candidates. With --apply it rewrites the
sources to use `tr.<key>` and writes lib/l10n/app_fr.arb plus a
tool/l10n_todo.json file with the keys still waiting for en/ar translations.
"""
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LIB = os.path.join(ROOT, 'lib')

SKIP_FILES = {
    'api_endpoints.dart', 'api_client.dart', 'api_interceptors.dart', 'json_utils.dart',
    'key_value_store.dart', 'debouncer.dart', 'app_routes.dart', 'app_config.dart',
    'l10n.dart', 'app_localizations.dart', 'app_localizations_ar.dart',
    'app_localizations_en.dart', 'app_localizations_fr.dart',
}
SKIP_DIRS = {'l10n'}

IDENT = re.compile(r'^[a-z0-9_.\-/:\[\]*]+$')
FORMAT = re.compile(r"^[dMyHhmsEpSaLQ/:\-\s,.'+]+$")
CODE_LIKE = re.compile(r'^(http|/|#|\.|[A-Za-z]:\\)')


def tokenize_strings(src):
    """Yields (start, end, quote, parts) for each non-raw string literal.

    parts is a list of ('t', text) / ('e', expression_source) in order.
    """
    i, n = 0, len(src)
    out = []
    while i < n:
        c = src[i]
        if c == '/' and src.startswith('//', i):
            j = src.find('\n', i)
            i = n if j < 0 else j
            continue
        if c == '/' and src.startswith('/*', i):
            j = src.find('*/', i + 2)
            i = n if j < 0 else j + 2
            continue
        if c in '\'"':
            raw = i > 0 and src[i - 1] == 'r' and (i < 2 or not (src[i - 2].isalnum() or src[i - 2] == '_'))
            triple = src.startswith(c * 3, i)
            q = c * 3 if triple else c
            start = i - 1 if raw else i
            j = i + len(q)
            parts = []
            buf = []
            ok = True
            while j < n:
                ch = src[j]
                if not raw and ch == '\\':
                    nxt = src[j + 1]
                    buf.append({'n': '\n', 't': '\t', "'": "'", '"': '"', '\\': '\\', '$': '\x00DOLLAR'}.get(nxt, '\\' + nxt))
                    j += 2
                    continue
                if src.startswith(q, j):
                    j += len(q)
                    break
                if not raw and ch == '$':
                    if j + 1 < n and src[j + 1] == '{':
                        depth, k = 1, j + 2
                        while k < n and depth:
                            if src[k] == '{':
                                depth += 1
                            elif src[k] == '}':
                                depth -= 1
                            k += 1
                        if buf:
                            parts.append(('t', ''.join(buf)))
                            buf = []
                        parts.append(('e', src[j + 2:k - 1]))
                        j = k
                        continue
                    m = re.match(r'\$([A-Za-z_][A-Za-z0-9_]*)', src[j:])
                    if m:
                        if buf:
                            parts.append(('t', ''.join(buf)))
                            buf = []
                        parts.append(('e', m.group(1)))
                        j += m.end()
                        continue
                buf.append(ch)
                j += 1
            if buf:
                parts.append(('t', ''.join(buf)))
            out.append((start, j, q, parts, raw, triple))
            i = j
            continue
        i += 1
    return out


def is_directive(src, start):
    line_start = src.rfind('\n', 0, start) + 1
    return re.match(r'\s*(import|export|part)\b', src[line_start:start]) is not None


def has_letters(text):
    return re.search(r'[A-Za-zÀ-ÿ؀-ۿ]', text) is not None


EXCLUDE_FLAT = {'Segoe UI', 'SocketException', 'VALIDATION_FAILED', 'fr_FR'}


def classify(parts, raw):
    if raw:
        return False
    if any(k == 'e' and ("'" in p or '"' in p) for k, p in parts):
        return False  # nested string inside ${...}: translated by hand
    text = ''.join(p if k == 't' else '' for k, p in parts)
    if not has_letters(text):
        return False
    flat = ''.join(p if k == 't' else '{}' for k, p in parts)
    if CODE_LIKE.match(flat) or flat in EXCLUDE_FLAT:
        return False
    if flat.startswith('[') or re.match(r'^[A-Za-z]+\(\{\}', flat):  # debug logs, toString()
        return False
    if re.match(r'^[a-z]+(-[a-z]+)*-\{\}(-\{\})?$', flat):  # widget keys / tags
        return False
    if FORMAT.match(flat) and ' ' not in flat.strip():
        return False
    if FORMAT.match(flat):
        return False
    if IDENT.match(flat):
        return False
    if re.match(r'^[A-Za-z]+(-[A-Za-z]+)*$', flat) and flat[0].isupper() and flat in {
        'Accept', 'Content-Type', 'Authorization'}:
        return False
    if re.match(r'^[a-z]+([A-Z][a-z0-9]*)+$', flat):  # camelCase identifier
        return False
    return True


def merge_adjacent(src, toks):
    """Adjacent literals ('a ' 'b') are one Dart string: merge them."""
    merged = []
    for tok in toks:
        if merged:
            start, end, q, parts, raw, triple = merged[-1]
            nstart, nend, nq, nparts, nraw, ntriple = tok
            if not (raw or nraw or triple or ntriple) and src[end:nstart].strip() == '':
                combined = list(parts)
                for kind, text in nparts:
                    if combined and combined[-1][0] == 't' and kind == 't':
                        combined[-1] = ('t', combined[-1][1] + text)
                    else:
                        combined.append((kind, text))
                merged[-1] = (start, nend, q, combined, raw, triple)
                continue
        merged.append(tok)
    return merged


def flat_of(parts):
    return ''.join(p if k == 't' else '{}' for k, p in parts)


def collect():
    items = []
    for dirpath, dirs, files in os.walk(LIB):
        dirs[:] = [d for d in dirs if d not in SKIP_DIRS]
        for f in files:
            if not f.endswith('.dart') or f in SKIP_FILES:
                continue
            path = os.path.join(dirpath, f)
            src = open(path, encoding='utf-8').read()
            for start, end, q, parts, raw, triple in merge_adjacent(src, tokenize_strings(src)):
                if is_directive(src, start):
                    continue
                if classify(parts, raw):
                    items.append((path, start, end, parts, triple))
    return items


def main():
    items = collect()
    if '--unique' in sys.argv:
        seen = {}
        for path, start, end, parts, triple in items:
            seen.setdefault(flat_of(parts), 0)
            seen[flat_of(parts)] += 1
        for flat in sorted(seen):
            print(repr(flat))
        print('UNIQUE', len(seen))
        return
    by_file = {}
    for it in items:
        by_file.setdefault(it[0], []).append(it)
    if '--apply' not in sys.argv:
        for path, its in sorted(by_file.items()):
            print('##', os.path.relpath(path, ROOT), len(its))
            src = open(path, encoding='utf-8').read()
            for _, start, end, parts, triple in its:
                print('   ', src[start:end].replace('\n', '\\n')[:140])
        print('TOTAL', len(items), 'in', len(by_file), 'files')


if __name__ == '__main__':
    main()
