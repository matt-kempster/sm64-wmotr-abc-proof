#!/usr/bin/env python3
"""Reproducible source index for the position-split catalog, not a proof.

Read the generator's pinned Git revision, never the modified game checkout.
Index position references throughout src/ (including unused/debug/render code)
and direct coordinate-lvalue shapes in every generated US/JP unit. This text
index deliberately does not infer receiver ownership or gameplay reachability.
Coq's PositionSplitCatalog supplies the separately checked source claims.
"""
import argparse
import hashlib
import io
import json
import pathlib
import re
import subprocess
import tarfile

ROOT = pathlib.Path(__file__).resolve().parents[1]
REVISION = "9921382a68bb0c865e5e45eb594d9c64db59b1af"


def mask_comments_strings(text):
    return re.sub(r'/\*.*?\*/|//[^\n]*|"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'',
                  lambda m: re.sub(r"[^\n]", " ", m[0]), text, flags=re.S)


def c_functions(text):
    """Index definition-to-next-definition spans, not preprocessed C bodies.

    Version #if branches sometimes contain two signatures or opening braces
    with one shared closing brace. Keeping both textual spans indexes those
    alternatives without pretending to preprocess or parse their semantics.
    """
    clean = mask_comments_strings(text)
    pattern = r"(?m)^((?:[A-Za-z_]\w*(?:\([^()\n]*\))?[ \t*]+)+)([A-Za-z_]\w*)\s*\([^;{}]*\)\s*\{"
    matches = list(re.finditer(pattern, clean))
    for i, m in enumerate(matches):
        start = m.end() - 1
        end = matches[i+1].start() if i+1 < len(matches) else len(clean)
        yield m[2], clean.count("\n", 0, m.start()) + 1, clean[start:end], text[start:end]


def assignment_lvalues(body):
    # Generated Sassign operands are parenthesized constructor expressions.
    for m in re.finditer(r"\bSassign\s*\(", body):
        start, depth, end = m.end() - 1, 1, m.end()
        while end < len(body) and depth:
            depth += (body[end] == "(") - (body[end] == ")")
            end += 1
        if depth:
            raise ValueError("unclosed generated assignment")
        yield body[start:end]


def generated_index():
    rows, counts, hashes = [], {}, {}
    for version in ("us", "jp"):
        files = sorted((ROOT / "generated").glob(version + "_*.v"))
        assert len(files) == 39, (version, len(files))
        counts[version] = {"units": len(files), "functions": 0, "assignments": 0}
        for path in files:
            text = path.read_text(encoding="utf-8")
            hashes[path.name] = hashlib.sha256(text.encode()).hexdigest()
            for m in re.finditer(r"Definition f_(\w+) := \{\|(.*?)\|\}\.", text, re.S):
                counts[version]["functions"] += 1
                lhs = list(assignment_lvalues(m[2]))
                counts[version]["assignments"] += len(lhs)
                tags = []
                if any(re.search(r"\b_pos\b", x) for x in lhs):
                    tags.append("named_pos_lvalue")
                if any(re.search(r"\b_pos\b", x) and re.search(r"\b_gfx\b", x) for x in lhs):
                    tags.append("gfx_pos_lvalue")
                if any(re.search(r"\b_rawData\b", x) for x in lhs):
                    tags.append("raw_union_lvalue")
                if any(re.search(r"\b_throwMatrix\b", x) for x in lhs):
                    tags.append("throw_matrix_lvalue")
                if tags:
                    rows.append(dict(unit=path.stem, function=m[1],
                                     line=text.count("\n", 0, m.start()) + 1, tags=tags))
    return counts, hashes, rows


def source_index(repo):
    archive = subprocess.check_output(["git", "-c", "safe.directory=" + str(repo),
        "-C", str(repo), "archive", "--format=tar", REVISION, "src", "data", "levels", "include"])
    files = {}
    with tarfile.open(fileobj=io.BytesIO(archive)) as tar:
        for member in tar:
            if member.isfile() and member.name.endswith((".c", ".h")):
                files[member.name] = tar.extractfile(member).read().decode("utf-8")
    refs, function_map = [], {}
    total_functions = 0
    candidate = re.compile(r"(?:->|\.)\s*(?:pos\b|oPos[XYZ]\b|throwMatrix\b)|\bset_mario_pos\s*\(")
    for path, text in sorted(files.items()):
        if not path.startswith("src/") or not path.endswith(".c"):
            continue
        for name, line, clean, original in c_functions(text):
            total_functions += 1
            function_map.setdefault(name, []).append(dict(path=path, line=line))
            if candidate.search(clean):
                examples = [s.strip() for s in original.splitlines() if candidate.search(s)]
                refs.append(dict(path=path, function=name, line=line,
                                 matching_lines=len(examples), examples=examples[:3]))
    return files, total_functions, function_map, refs


def make_index(repo, catalog):
    files, function_count, functions, refs = source_index(repo)
    counts, hashes, generated = generated_index()
    for row in catalog["situations"]:
        if row["section"] not in ("proved", "catalog"):
            raise ValueError(f"{row['id']}: invalid presentation section")
        if (row["section"] == "proved") != bool(row.get("proof")):
            raise ValueError(f"{row['id']}: missing or misplaced proof reference")
        if row['section'] == 'catalog' and any(not row.get('gap', {}).get(key)
                for key in ('amount', 'verdict', 'detail', 'limit', 'basis')):
            raise ValueError(f"{row['id']}: incomplete backward gap review")
        if row['section'] == 'catalog':
            review = row.get('review', {})
            if review.get('group') not in {g['id'] for g in catalog['gapReviewGroups']} or not review.get('summary'):
                raise ValueError(f"{row['id']}: missing role in the gap review")
        insufficient = row.get('gap', {}).get('insufficiency')
        if insufficient:
            if any(not insufficient.get(key) for key in ('card', 'module', 'theorem', 'scope')):
                raise ValueError(f"{row['id']}: incomplete insufficiency proof reference")
            module = ROOT / insufficient['module']
            if not re.search(r"\b(?:Theorem|Lemma|Corollary)\s+" + re.escape(insufficient['theorem']) + r"\b", module.read_text(encoding='utf-8')):
                raise ValueError(f"{row['id']}: missing insufficiency theorem")
        if row.get("proof"):
            proof = row["proof"]
            module = ROOT / proof["module"]
            if not proof["claim"] or not proof["scope"] or row["availability"] != "absent":
                raise ValueError(f"{row['id']}: incomplete stock-list exclusion")
            if not re.search(r"\bTheorem\s+" + re.escape(proof["theorem"]) + r"\b", module.read_text(encoding="utf-8")):
                raise ValueError(f"{row['id']}: missing referenced theorem")
        for name in row["functions"]:
            if name not in functions:
                raise ValueError(f"{row['id']}: unindexed source function {name}")
    named = sorted({r["function"] for r in generated if "named_pos_lvalue" in r["tags"]})
    covered = {f for row in catalog["situations"] for f in row["functions"]}
    unclassified = sorted(set(named) - covered)
    if unclassified:
        raise ValueError("unclassified generated named-pos writers: " + ", ".join(unclassified))
    return {
        "revision": REVISION,
        "scope": "Pinned whole-game C source-reference index plus 39 generated units per version; no alias or reachability theorem.",
        "limitations": ["C definition spans include preprocessor alternatives and are not parsed C bodies, semantics or exhaustive alias analysis.",
            "Named-pos lvalue coverage does not cover writes through generic pointers, unions, byte stores, callees or externals.",
            "References and receiver-neutral stores are candidates, not evidence of a useful Mario split.",
            "Only SSL level scripts are in the generated corpus; other course scripts are read from the pinned source."],
        "source_c_files": sum(p.startswith("src/") and p.endswith(".c") for p in files),
        "indexed_source_functions": function_count,
        "generated_counts": counts,
        "generated_sha256": hashes,
        "named_pos_functions": named,
        "catalog_function_locations": {n:functions[n] for n in sorted(covered)},
        "ssl_locality": check_ssl_locality(files),
        "coordinate_references": refs,
        "generated_lvalue_functions": generated,
    }


def check_ssl_locality(files):
    """Small literal stock-data check; not live-actor or action-history closure."""
    paths = ['levels/ssl/script.c', 'levels/ssl/areas/1/collision.inc.c',
             'levels/ssl/areas/1/macro.inc.c', 'levels/ssl/areas/2/collision.inc.c',
             'levels/ssl/pyramid_top/collision.inc.c', 'include/special_presets.inc.c',
             'include/macro_presets.inc.c', 'data/behavior_data.c']
    clean = {p: mask_comments_strings(files[p]) for p in paths}
    script = clean[paths[0]]
    arrays = dict(re.findall(r'LevelScript\s+(\w+)\[\]\s*=\s*\{(.*?)\};', script, re.S))
    areas = dict(re.findall(r'\bAREA\(\s*(\d+)\s*,[^)]*\)(.*?)END_AREA\(\)', script, re.S))
    assert set(areas) == {'1', '2', '3'}
    def expanded(body, visited=()):
        for name in re.findall(r'JUMP_LINK\(\s*(\w+)\s*\)', body):
            assert name in arrays and name not in visited
            body += expanded(arrays[name], visited+(name,))
        return body
    selectors = {area: re.findall(r'\bbhv\w+', expanded(body)) for area, body in areas.items()}
    pole_counts = {area: names.count('bhvPoleGrabbing') for area, names in selectors.items()}
    assert pole_counts == {'1': 0, '2': 2, '3': 0}
    assert 'INSTANT_WARP' not in areas['1']
    assert re.findall(r'INSTANT_WARP\(\s*\d+,\s*\d+,\s*(-?\d+),\s*(-?\d+),\s*(-?\d+)\)', script) == [('0','0','0'), ('0','0','0')]
    trees = re.findall(r'SPECIAL_OBJECT\(\s*special_palm_tree,\s*(-?\d+),\s*(-?\d+),\s*(-?\d+)\)', clean[paths[1]])
    assert trees == [('-5989', '0', '-4850')]
    assert re.search(r'\{\s*special_palm_tree,[^}]*\bbhvTree\s*\}', clean[paths[5]])
    assert re.search(r'/\*\s*macro_hidden_1up_in_pole\s*\*/\s*\{\s*bhvHidden1UpInPoleSpawner', files[paths[6]])
    tree = re.search(r'BehaviorScript\s+bhvTree\[\]\s*=\s*\{(.*?)\};', clean[paths[7]], re.S)[1]
    assert re.search(r'SET_INT\(oInteractType,\s*INTERACT_POLE\)', tree)
    assert re.search(r'SET_HITBOX\(\s*80,\s*500\)', tree)
    assert 'SURFACE_HANGABLE' not in clean[paths[1]]
    assert 'SURFACE_HANGABLE' not in clean[paths[4]]
    assert re.findall(r'COL_TRI_INIT\(SURFACE_HANGABLE,\s*(\d+)\)', clean[paths[3]]) == ['6']
    return {'scope': 'Literal stock SSL script helpers, tree preset and named collision assets; no dynamic-actor history claim.',
            'poleGrabbingSelectorsByArea': pole_counts, 'area1PalmTree': [-5989,0,-4850],
            'treePoleHitbox': {'radius':80, 'height':500},
            'area1InstantWarps':0, 'area2and3InstantWarpDisplacements':[[0,0,0],[0,0,0]],
            'hangableTriangles':{'area1Static':0, 'pyramidTop':0, 'area2Static':6},
            'sha256':{p:hashlib.sha256(files[p].encode()).hexdigest() for p in paths}}


def render_markdown(catalog, index):
    lines = ["# Where a useful position split could come from", "",
        "Gameplay catalog updated 4 October 2026; source-unit census refreshed 29 October 2026 after adding the real Bob-omb animation data. The full catalog is also on the private "
        "[Fine Print site](https://pyramid-proof-fine-print.tra38.chatgpt.site/#split-catalog).", "",
        "Mario has three position records. Usually, the game keeps them together. We want to "
        "know which tricks can pull them apart, and whether SSL can supply the ingredients "
        "before the next copy puts them back together. If an enemy's stock spawn path is "
        "impossible, cross off that path. A different actor using the same helper still needs "
        "its own check.", "",
        "This catalog groups whole-game source mechanisms into 27 cases. It includes actual "
        "writers, ways to preserve a gap, and tempting false positives. It is not a list of "
        "27 demonstrated Ink routes or a completed classification of every live memory write.", "",
        "## What counts as useful?", "",
        "**State** is MarioState.pos, **collision** is MarioObject's raw oPosX/Y/Z, and "
        "**display** is the stored header.gfx.pos vector. A rendered animation or camera offset "
        "is not necessarily a change to that display vector. The target is immediately after "
        "the upper nonfading SSL warp returns success, still in Area 1 and before act_disappeared. "
        "State = display with different collision coordinates qualifies; all three need not differ. "
        "Useful final Area-1 top capture is reported separately.", "",
        "Ordinary controller gameplay and defined, in-bounds execution remain the scope. "
        "The negative-depth and valid-reward grants are diagnostic assumptions, not a grant of "
        "the useful split, failed first query, contact or timer. Arbitrary state injection, "
        "memory corruption and debug-action injection are not routes in this catalog.", "",
        "## The result so far", "",
        "Chuckya and King Bob-omb's shared anchor, Dorrie's lift, the LLL/BitFS tilting pyramids, "
        "Hoot, Heave-Ho, the named bullies, Bowser's shockwave, whirlpools and butterflies have "
        "no stock Area-1 selector in the checked paths. The new source checks supplement the "
        "existing Chuckya/King Bob-omb and butterfly proofs. These are selector exclusions, "
        "not an assumed all-gameplay object-lifetime invariant.", "",
        "SSL still has ordinary geometry correction and floor retry, platform movement, "
        "floor alignment, palm-tree pushes, interactions, a cannon, Tweesters, a shell, "
        "quicksand, dialogs and an oasis. A particularly concrete case is normal cannon firing: "
        "it moves State and returns before the display copy, but that branch requires an A press. "
        "Ordinary confinement refreshes display. Swimming offsets also cannot be excluded just "
        "by calling SSL a desert.", "",
        "The accepted-warp action tail preserves any gap it receives. The successful supplied "
        "JP Ink fixture remains conditional; the clean replay has all three records equal. "
        "No new clean installation or all-history impossibility has been established. "
        "Atlas route estimates are unchanged; no probability is assigned to these source rows.", "",
        "Seven proved stock-list exclusions now appear in **01 · Already proved** below "
        "and on the site. The other 20 entries remain separate. This is a clearer presentation "
        "of existing proofs, not seven new route closures. The summaries start with what "
        "happens to Mario; the exact scope and proof references remain attached.", "",
        "## Working backward: how much gap can each case create?", "",
        "The supplied vertical setup needs actual and collision Y=768 with display "
        "Y=1938.8648681640625: an upward gap of **1170.8648681640625** before the first "
        "floor query. This is one successful supplied setup, not a universal minimum for "
        "every possible Ink installation. After the retry, movement can equal display "
        "while collision remains low. A platform changing only movement does not create "
        "that display-versus-collision difference by itself.", "",
        "These 20 reviewed cases are not 20 unresolved gap producers. A zero at a named copy "
        "is not a theorem about every surrounding update. Formula-dependent rows still "
        "need real incoming values; an unknown maximum is not an unlimited reachable gap. "
        "We defer travel to the warp until a producer passes this first test. See the "
        "[backward review](ink-gap-backward.md) and [finite arithmetic receipt](ink-gap-arithmetic.json).", "",
        "**Stopping rule.** A proved upper bound below **1170.8648681640625** counts as "
        "**Insufficient — already proved**, under its stated conditions and checkpoint. "
        "The normal Tweester and completed ground copies qualify with zero gap. The "
        "shell, water, ledge and cannon shortfalls keep their source/finite evidence "
        "labels; unknown bounds remain open. A keeper or consumer of an existing gap "
        "is not ruled out in that supporting role. This threshold is specific to the "
        "supplied setup, not every Ink installation.", "",
        "The [four concrete producer review](ink-concrete-producers.md) adds actual US/JP "
        "execution connections for the accepted floor snap, reached nonrotating platform tail, "
        "bounded live bounce snap and real sink magnitude. The families remain open beyond "
        "those cuts. The supplied Variant uses a different 1093-unit movement/collision split; "
        "zero display/movement gap alone does not exclude it.", "",
        "The review separates six scoped insufficient cases, five helpers, four concrete "
        "unresolved producers, four other-context/lookalike cases, and one ownership question. "
        "There is no pole beside the Area-1 upper warp. Its distant palm tree uses pole "
        "actions; the two regular SSL poles belong to Area 2. The checked Area-1 static "
        "mesh and pyramid top have no hangable triangles; Area 2 has six. These are "
        "pinned stock-data checks, not new Coq or all-history exclusions.", "",
        "| Case | Role in this review | Gap at the stated checkpoint | Verdict |", "| --- | --- | --- | --- |"]
    for row in catalog['situations']:
        if row['section'] == 'catalog':
            gap = row['gap']
            title = next(g['title'] for g in catalog['gapReviewGroups'] if g['id'] == row['review']['group'])
            outcome = "<br>".join(catalog["outcomeCategories"][o["category"]]["label"] + ": " + o["scope"] for o in row["outcomes"])
            lines.append(f"| [{row['number']:02} — {row['id']}](#split-{row['id']}) | {title} | {gap['amount']} | {outcome}<br>{gap['verdict']} |")
    lines += ["", "## All 27 cases at a glance", "",
        "| # | Situation | SSL / current verdict |", "| --- | --- | --- |"]
    for row in catalog["situations"]:
        lines.append(f"| {row['number']:02} | [{row['title']}](#split-{row['id']}) | {row['status']} |")
    grouped_rows = [row for section in ("proved", "catalog")
                    for row in catalog["situations"] if row["section"] == section]
    previous_section = None
    for row in grouped_rows:
        if row["section"] != previous_section:
            previous_section = row["section"]
            if previous_section == "proved":
                lines += ["", "## 01 · Already proved: these stock spawn choices are ruled out", "",
                    "These lists cannot select the named actors. That is the completed claim. "
                    "Unexpected later object creation remains a separate question; it is not "
                    "silently declared impossible here."]
            else:
                lines += ["", "### Already proved: insufficient for this supplied gap", ""]
                for proved_row in catalog['situations']:
                    result = proved_row.get('gap', {}).get('insufficiency')
                    if result:
                        lines += [f"**[{proved_row['title']}](#split-{proved_row['id']}) — Insufficient.** "
                            + result['scope'], "",
                            f"Proof: [`{result['theorem']}`](../../{result['module']}).", ""]
                lines += ["", "## 02 · Remaining cases and other contexts", "",
                    "These entries include open gameplay questions and things that only look "
                    "like useful producers. Being listed here does not mean a route works."]
        lines += ["", f"<a id=\"split-{row['id']}\"></a>", "", f"### {row['number']:02} — {row['title']}", ""]
        if row.get("proof"):
            proof = row["proof"]
            lines += [f"**Ruled out.** {proof['claim']}", "", f"**Scope.** {proof['scope']}", "",
                f"Proof: [`{proof['theorem']}`](../../{proof['module']}).", ""]
        if row.get('gap'):
            gap = row['gap']
            lines += [f"**Role in this review.** {row['review']['summary']}", ""]
            lines += [f"**Gap sizing: {gap['amount']}.** {gap['verdict']}", "",
                gap['detail'], "", f"**Limits.** {gap['limit']}", "",
                f"**Evidence level.** {gap['basis']}", ""]
            if gap.get('insufficiency'):
                result = gap['insufficiency']
                lines += [f"**Already proved — Insufficient.** {result['scope']}", "",
                    f"Proof: [`{result['theorem']}`](../../{result['module']}).", ""]
        for key, label in (("effect", "What happens to Mario"), ("prerequisite", "What we would need"),
                ("area1", "Can SSL supply it"), ("timing", "Does the gap last long enough"),
                ("evidence", "What we know"), ("missing", "What this does not rule out" if row.get("proof") else "What is left to check")):
            lines += [f"**{label}.** {row[key]}", ""]
        links = []
        for name in row["functions"]:
            loc = index["catalog_function_locations"][name][0]
            url = f"https://github.com/n64decomp/sm64/blob/{REVISION}/{loc['path']}#L{loc['line']}"
            links.append(f"[{name}]({url})")
        lines += ["Stock source: " + "; ".join(links) + ".", "",
            "Related atlas ranks: " + ", ".join(row["ranks"]) + "."]
    lines += ["", "## Exactly what was checked", "",
        "[PositionSplitCatalog.v](../../proofs/PositionSplitCatalog.v), exposed as "
        "`MainTheorem.current_f02_position_split_catalog`, checks the actual generated US/JP "
        "program objects. Across all 39 generated units per version, the direct callers of "
        "`set_mario_pos` are exactly `dorrie_raise_head`, `bhv_tilting_inverted_pyramid_loop` "
        "and `apply_platform_displacement`. Twelve named actor behaviors fail the stock selector "
        "checks; tree, Tweester, Tox Box and closed cannon provide positive controls. The regular "
        "script test conservatively reads the whole SSL script, while macro and special checks "
        "use Area 1. Special-preset IDs reuse the earlier checked collision-data receipt.", "",
        "The passing audit is `build/audit/20260924-104903-5dt7xgd1`: 595 registered sources, "
        "425 of 519 proof modules in MainTheorem's import closure, 94 standalone modules, "
        "and no proof-hole/link problems. The catalog boundary and setter census each use four "
        "allowed foundations, the absent-selector theorem uses none, and the existing main "
        "Ink boundary still uses nine. Foundation counts do not count explicit gameplay premises.", "",
        f"The separate [source index](position-split-source-index.json) scans {index['source_c_files']} "
        f"pinned src C files, recognizes {index['indexed_source_functions']} textual definition spans "
        f"and records {len(index['coordinate_references'])} coordinate-reference spans, including "
        "other courses, debug, camera and rendering code. It scans all 78 generated files "
        "(2,567 US and 2,561 JP function definitions; 9,156 and 9,110 assignments). All 50 "
        "distinct function names whose generated assignment destination contains `_pos` have "
        "a catalog home. This text check includes local arrays and other receivers and is "
        "deliberately broader than Mario writes. It is not a Coq coverage theorem.", "",
        "The index reads the generator's pinned Git revision, never the modified decomp checkout. "
        "It records generated-file hashes. Five focused tests cover comments/strings, macro return "
        "types, version-alternative signatures, assignment destination versus read, and malformed "
        "assignment rejection. C spans retain preprocessor alternatives rather than pretending "
        "to be parsed bodies. Pointer aliases, union/byte writes, callees, externals and actual "
        "receivers remain semantic obligations. A syntactic named-position census cannot close those.", "",
        "Regenerate with `python3 pipeline/split_catalog.py`; check both the index and this "
        "document with `python3 pipeline/split_catalog.py --check`. Run the scanner tests with "
        "`python3 pipeline/test_split_catalog.py`. The canonical prose is "
        "[position-split-catalog.json](position-split-catalog.json); this document and the private "
        "site use the same rows.", "",
        "## How this becomes an exclusion proof", "",
        "The remaining task is to prove that every reached write relevant to the fixed checkpoint "
        "belongs to the checked cases, with its real receiver and action/actor prerequisites. "
        "For each applicable case, prove either that its preconditions cannot occur there or "
        "that the next copy/contact/query removes its usefulness. Compose those results through "
        "the actual callback and interaction order. This classification is not presently a "
        "discharged theorem or an accepted premise.", "",
        "The most focused next gameplay batch remains the pre-action geometry/retry interval "
        "fed by platform or floor alignment, with the raised display's last writer identified. "
        "Palm-tree pushes and water/cannon/shell transfers have separate catalog entries, so "
        "a proof for that interval will not silently claim to settle them all. Close a named "
        "case when its conditions and boundary match; expand only if another row actually "
        "reaches that boundary.", ""]
    return "\n".join(lines)


def encode_index(result):
    # One line per machine-indexed function keeps the receipt reviewable.
    row_keys = ("coordinate_references", "generated_lvalue_functions")
    encoded = json.dumps({k: v for k, v in result.items() if k not in row_keys},
                         ensure_ascii=False, indent=2).rstrip()[:-1].rstrip()
    for key in row_keys:
        rows = ",\n".join("    " + json.dumps(row, ensure_ascii=False) for row in result[key])
        encoded += ',\n  "' + key + '": [\n' + rows + '\n  ]'
    return encoded + "\n}\n"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=pathlib.Path, default=ROOT.parents[2]/"reference-sm64-decomp")
    parser.add_argument("--catalog", type=pathlib.Path, default=ROOT/"docs/notes/position-split-catalog.json")
    parser.add_argument("--output", type=pathlib.Path, default=ROOT/"docs/notes/position-split-source-index.json")
    parser.add_argument("--document", type=pathlib.Path, default=ROOT/"docs/notes/position-split-catalog.md")
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    catalog = json.loads(args.catalog.read_text(encoding="utf-8"))
    result = make_index(args.source.resolve(), catalog)
    encoded = encode_index(result)
    assert json.loads(encoded) == result
    document = render_markdown(catalog, result)
    if args.check:
        if args.output.read_text(encoding="utf-8") != encoded:
            raise SystemExit("source index is stale; inspect and regenerate")
        if args.document.read_text(encoding="utf-8") != document:
            raise SystemExit("catalog document is stale; inspect and regenerate")
    else:
        args.output.write_text(encoded, encoding="utf-8", newline="\n")
        args.document.write_text(document, encoding="utf-8", newline="\n")
    print(json.dumps({k:result[k] for k in ("source_c_files", "indexed_source_functions", "generated_counts")}))
    print(f"Indexed {len(result['coordinate_references'])} coordinate-reference functions; "
          f"classified {len(result['named_pos_functions'])} generated named-pos writer names.")


if __name__ == "__main__":
    main()
