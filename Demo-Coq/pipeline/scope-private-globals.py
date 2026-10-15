#!/usr/bin/env python3
"""Freshen only source-private global atoms in normalized clightgen output.

CompCert rejects shared private global names.  public_idents is the authority
for linkage.  Fail closed if a private global identifier occurs outside the
global-name positions handled here, protecting fields, composites, locals and
temporaries.  Coq definition names are deliberately unchanged.
"""
import argparse
from pathlib import Path
import re

IDENT = re.compile(r'^Definition (_\w+) : ident := \$"([^"\n]+)"\.$', re.M)


def inventory(text):
    aliases = dict(IDENT.findall(text))
    definitions = text.split('Definition global_definitions', 1)[1].split('Definition public_idents', 1)[0]
    public_text = text.split('Definition public_idents', 1)[1].split('Definition prog', 1)[0]
    globals_ = set(re.findall(r'\(\s*(_\w+)\s*,\s*G(?:fun|var)\b', definitions))
    public = set(re.findall(r'\b_\w+\b', public_text))
    if not globals_ or not globals_ <= aliases.keys() or not public <= aliases.keys():
        raise ValueError('unrecognized global/public identifier inventory')
    private = globals_ - public
    masked = text
    for name in sorted(private):
        token = re.escape(name)
        masked = re.sub(r'^Definition ' + token + r' : ident := .*?\n', '', masked, flags=re.M)
        masked = re.sub(r'\bInit_addrof\s+' + token + r'\b', 'Init_addrof SCOPED', masked)
        masked = re.sub(r'\bEvar\s+' + token + r'\b', 'Evar SCOPED', masked)
        masked = re.sub(r'\(\s*' + token + r'\s*,\s*G(fun|var)\b', r'(SCOPED, G\1', masked)
    for name in sorted(private):
        if re.search(r'\b' + re.escape(name) + r'\b', masked):
            raise ValueError('private global also used in an unhandled namespace/position: ' + name)
    return aliases, globals_, public, private


def scope_for(path):
    match = re.fullmatch(r'(?:us|jp)_(\w+)', Path(path).stem)
    if not match:
        raise ValueError('expected a version-prefixed generated filename')
    return match[1]


def scoped_atom(scope, name, old_atom=None):
    if name.startswith('___stringlit_'):
        # Retain the established version-specific string naming exactly.
        if old_atom is None:
            raise ValueError('literal atoms require the version-prefixed scope')
        return '__' + old_atom + '_stringlit_' + name[len('___stringlit_'):]
    # US/JP are alternative programs. Shared unit scope preserves genuine
    # equality of their generated bodies while separating different C units.
    return '__demo_' + scope + '_' + name[1:]


def transform(text, scope, literal_scope):
    aliases, globals_, public, private = inventory(text)
    changed = IDENT.sub(lambda m: 'Definition ' + m[1] + ' : ident := $"' +
                        (scoped_atom(scope, m[1], literal_scope) if m[1] in private else m[2]) + '".', text)
    after, globals_after, public_after, private_after = inventory(changed)
    if (globals_, public, private) != (globals_after, public_after, private_after):
        raise ValueError('freshening changed the generated linkage inventory')
    if any(after[name] != atom for name, atom in aliases.items() if name not in private):
        raise ValueError('freshening changed a public/non-global identifier')
    if len(set(after.values())) != len(after):
        raise ValueError('freshening introduced an identifier collision')
    return changed


def check(path):
    text = path.read_text()
    aliases, globals_, public, private = inventory(text)
    scope = scope_for(path)
    if f'private globals scoped by translation unit {scope}' not in text:
        raise ValueError('missing private-global hygiene header: ' + path.name)
    if any(aliases[name] != scoped_atom(scope, name, path.stem) for name in private):
        raise ValueError('unscoped private global: ' + path.name)
    return aliases, globals_, public, private


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('input', type=Path)
    parser.add_argument('--output-name')
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    if args.check:
        check(args.input)
    else:
        if not args.output_name:
            parser.error('--output-name requires a version-prefixed generated filename')
        print(transform(args.input.read_text(), scope_for(args.output_name),
                        Path(args.output_name).stem), end='')


if __name__ == '__main__':
    main()
