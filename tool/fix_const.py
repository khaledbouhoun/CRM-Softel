# -*- coding: utf-8 -*-
"""Removes the `const` that makes analyzer report non-constant arguments.

Usage: python tool/fix_const.py <analyzer output file>
Handles invalid_constant, non_constant_list_element and
const_with_non_constant_argument by deleting the nearest enclosing `const`.
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CODES = ('invalid_constant', 'non_constant_list_element', 'const_with_non_constant_argument',
         'non_constant_record_field')
LINE = re.compile(r'^\s+error - .* - (?P<path>\S.*?):(?P<line>\d+):(?P<col>\d+) - (?P<code>\w+)$')
OPEN, CLOSE = '([{', ')]}'


def offset_of(src, line, col):
    pos = 0
    for _ in range(line - 1):
        pos = src.index('\n', pos) + 1
    return pos + col - 1


def find_const(src, pos):
    """Index of the `const` keyword of the nearest construct enclosing pos."""
    depth = 0
    i = pos - 1
    while i >= 0:
        c = src[i]
        if c in CLOSE:
            depth += 1
        elif c in OPEN:
            if depth == 0:
                # text before the bracket: [const] [Type[.name]|<T>] bracket
                head = src[max(0, i - 80):i]
                m = re.search(r'\bconst\s+(?:[A-Za-z_][\w.<>?, ]*)?\s*$', head)
                if m:
                    return i - len(head) + m.start()
                m = re.search(r'\bconst\s*$', head)
                if m:
                    return i - len(head) + m.start()
            else:
                depth -= 1
        i -= 1
    return None


def main():
    entries = {}
    for raw in open(sys.argv[1], encoding='utf-8', errors='replace'):
        m = LINE.match(raw.rstrip('\n'))
        if m and m.group('code') in CODES:
            entries.setdefault(m.group('path'), []).append((int(m.group('line')), int(m.group('col'))))
    fixed = 0
    for rel, positions in entries.items():
        path = os.path.join(ROOT, rel)
        src = open(path, encoding='utf-8').read()
        starts = set()
        for line, col in positions:
            start = find_const(src, offset_of(src, line, col))
            if start is not None:
                starts.add(start)
        # delete from the end so earlier offsets stay valid
        for start in sorted(starts, reverse=True):
            m = re.match(r'const\s+', src[start:])
            if m:
                src = src[:start] + src[start + m.end():]
                fixed += 1
        open(path, 'w', encoding='utf-8', newline='\n').write(src)
    print('removed %d const keywords' % fixed)


if __name__ == '__main__':
    main()
