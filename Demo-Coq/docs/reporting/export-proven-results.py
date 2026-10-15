#!/usr/bin/env python3
"""Export checked statements and readable conditions; never launches Coq."""
from pathlib import Path
import hashlib
import json
import re
import zipfile

ROOT = Path(__file__).resolve().parents[2]


def comment_mask(source):
    output = list(source)
    depth = 0
    quoted = False
    i = 0
    while i < len(source):
        pair = source[i:i+2]
        if not quoted and pair == '(*':
            depth += 1
            output[i:i+2] = [' ', ' ']
            i += 2
            continue
        if depth and pair == '*)':
            depth -= 1
            output[i:i+2] = [' ', ' ']
            i += 2
            continue
        if depth:
            if source[i] != '\n':
                output[i] = ' '
        elif source[i] == '"':
            if quoted and pair == '""':
                i += 2
                continue
            quoted = not quoted
        i += 1
    assert depth == 0
    return ''.join(output)


def statements(source):
    masked = comment_mask(source)
    rows = []
    pattern = r'(?m)^(?:Local\s+|Global\s+)?(Theorem|Lemma|Corollary|Fact|Remark|Proposition|Example)\s+([A-Za-z_][A-Za-z_0-9\']*)\b'
    for match in re.finditer(pattern, masked):
        end = re.search(r'\.(?=\s|$)', masked[match.end():])
        assert end, match[2]
        stop = match.end()+end.end()
        rows.append({'name':match[2], 'kind':match[1],
                     'line':source.count('\n',0,match.start())+1,
                     'statement':source[match.start():stop]})
    return rows


def main():
    catalog = json.loads((ROOT/'docs/notes/proven-results-catalog.json').read_text(encoding='utf-8'))
    validation = json.loads((ROOT/'docs/notes/validation.json').read_text(encoding='utf-8'))
    modules = []
    for path in sorted((ROOT/'proofs').glob('*.v')):
        source = path.read_text(encoding='utf-8')
        digest = hashlib.sha256(path.read_bytes()).hexdigest()
        assert digest == validation['source_sha256'][path.relative_to(ROOT).as_posix()], path
        modules.append({'module':path.stem,'file':path.relative_to(ROOT).as_posix(),
                        'sha256':digest,'statements':statements(source)})
    covered={name for family in catalog['families'] for name in family['modules']}
    assert {row['module'] for row in modules}-covered == {'MainTheorem'}
    staged=[]
    stopped=json.loads((ROOT/'docs/notes/paused-draft-validation.json').read_text(encoding='utf-8'))
    assert stopped['independent_kernel_check_return_code']==0
    archive=ROOT/stopped['archive']
    assert hashlib.sha256(archive.read_bytes()).hexdigest()==stopped['archive_sha256']
    with zipfile.ZipFile(archive) as snapshot:
        for row in stopped['results']:
            if row['return_code']!=0:
                continue
            source=snapshot.read(row['source'])
            assert hashlib.sha256(source).hexdigest()==row['sha256']
            staged.append({'module':row['module'],'file':row['source'],'sha256':row['sha256'],
                           'scope':stopped['passed_limits'][Path(row['source']).stem],
                           'statements':statements(source.decode('utf-8'))})
    formal = {'checked_proof_checkpoint':catalog['checked_proof_checkpoint'],
              'scope':'Literal declarations from checked source, not freshly inferred/unfolded types. All defining predicates and proofs remain in the complete linked source files.',
              'modules':modules,'module_count':len(modules),
              'statement_count':sum(len(row['statements']) for row in modules),
              'validated_staging_outside_capstone':staged}
    (ROOT/'docs/notes/proven-statements.json').write_text(json.dumps(formal,indent=2)+'\n',encoding='utf-8',newline='\n')
    lines=['# What is proved, with its conditions','',catalog['status']+'.','',
           'Checked proof checkpoint: `'+catalog['checked_proof_checkpoint']+'`.','',
           'This report covers all '+str(len(modules))+' registered proof modules at that checkpoint. '+
           'The capstone is a conjunction of conditional components, not the requested gameplay theorem.','',
           '## Conditions shared across the results','']
    lines += ['- '+text for text in catalog['shared_conditions']]
    for family in catalog['families']:
        lines += ['', '## '+family['title'],'', '**Proved result.** '+family['result'],'',
                  '**Conditions.** '+family['conditions'],'', '**Limits.** '+family['limits'],'',
                  '**Complete statements, predicate definitions and proofs:** '+', '.join(
                      '['+name+'](../proofs/'+name+'.v)' for name in family['modules'])+'.']
    lines += ['', '## Exact formal conditions','',
              'The [statement catalog](notes/proven-statements.json) lists every named theorem/lemma declaration in the checked source, with source lines and hashes. It is a literal text export, not a new Coq type-inference or premise-expansion result. Its '+str(formal['statement_count'])+' declarations retain their quantifiers and hypotheses. The complete source files also retain every helper predicate, layout/resource definition and proof. Imported CompCert semantics and generated ASTs are fixed by the environment/source receipt.','',
              'A clean axiom audit does not discharge hypotheses written in those types. Inspect the statement and its defining predicates together. The private site provides a searchable full-source appendix for that purpose.','',
              '## Validated staging outside the capstone','',
              'The final bounded validation found four additional staged files that type-check and pass the independent kernel checker. They remain unregistered staging and are excluded from the 62-module capstone snapshot. Three other staged files fail to compile. The [stopping record](notes/stopping-point.md) and [validation results](notes/paused-draft-validation.json) preserve that distinction.','']
    lines += ['- `'+row['module']+'`: '+row['scope']+'.' for row in staged]
    lines += ['', 'The joint witness proves local satisfiability for every one of the nine selected descriptors, both source versions and both read kinds, with explicit scalar source-view allocation/store, RAM allocation/code/data stores, matching image/byte ranges, generated cenv/temps, exact native PCs and base GPR. Its source allocation is only the one-byte/two-byte read extent and data is deliberately placed at 0x80040000. It is not initialized asset memory, an active image or a boot/gameplay history. The other staged results only check finite instruction data and generic partial-model structural properties; no complete helper/caller execution is proved. All exact declarations and full defining source are shown separately in the site appendix.','',
              '## External finite evidence','',catalog['external_finite_evidence'],'',
              '## Stopping verdict','',catalog['unproved_end_state'],'']
    (ROOT/'docs/proven-results.md').write_text('\n'.join(lines),encoding='utf-8',newline='\n')
    print('Exported '+str(len(modules))+' hash-matched modules / '+str(formal['statement_count'])+' exact declarations; no Coq process launched.')


if __name__ == '__main__':
    main()
