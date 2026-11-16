# -*- coding: utf-8 -*-
"""Replaces physical left/right layout values by directional ones (RTL support)."""
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LIB = os.path.join(ROOT, 'lib')

SIMPLE = [
    (r'\bEdgeInsets\.fromLTRB\(', 'EdgeInsetsDirectional.fromSTEB('),
    (r'\bAlignment\.centerLeft\b', 'AlignmentDirectional.centerStart'),
    (r'\bAlignment\.centerRight\b', 'AlignmentDirectional.centerEnd'),
    (r'\bAlignment\.topLeft\b', 'AlignmentDirectional.topStart'),
    (r'\bAlignment\.topRight\b', 'AlignmentDirectional.topEnd'),
    (r'\bTextAlign\.right\b', 'TextAlign.end'),
    (r'\bTextAlign\.left\b', 'TextAlign.start'),
    (r'\bBorder\(left:', 'BorderDirectional(start:'),
    (r'\bBorder\(right:', 'BorderDirectional(end:'),
]


def fix_only(match):
    body = match.group(0)
    body = re.sub(r'\bleft:', 'start:', body)
    body = re.sub(r'\bright:', 'end:', body)
    return body.replace('EdgeInsets.only(', 'EdgeInsetsDirectional.only(', 1)


changed = 0
for dirpath, _, files in os.walk(LIB):
    if os.sep + 'l10n' in dirpath:
        continue
    for name in files:
        if not name.endswith('.dart'):
            continue
        path = os.path.join(dirpath, name)
        src = open(path, encoding='utf-8').read()
        out = src
        for pattern, repl in SIMPLE:
            out = re.sub(pattern, repl, out)
        out = re.sub(r'EdgeInsets\.only\([^)]*\b(?:left|right):[^)]*\)', fix_only, out)
        if out != src:
            open(path, 'w', encoding='utf-8', newline='\n').write(out)
            changed += 1
print('rtl: %d files changed' % changed)
