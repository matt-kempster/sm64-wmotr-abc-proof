#!/usr/bin/env python3
"""Authenticate selected generated script initializers against actual retail bytes.

The matching ELF supplies symbol placements; every selected initializer byte is
compared with the clean authenticated ROM.  No emulator or source mutation.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import struct
import subprocess

PROJECT = next(path for path in Path(__file__).resolve().parents
               if (path / '_CoqProject').is_file() and path.name == 'Demo-Coq')
PROOF = PROJECT.parent
SOURCE = PROOF.parent / 'reference-sm64-decomp'
CACHE = PROOF / 'Pedro-Coq/instrumentation/ttc-runtime-snapshot/build/retail-map-9921382'
PIN = '9921382a68bb0c865e5e45eb594d9c64db59b1af'


def elf_symbols(path):
    data = path.read_bytes()
    if data[:6] != b'\x7fELF\x01\x02':
        raise ValueError('expected big-endian ELF32')
    shoff = struct.unpack_from('>I', data, 32)[0]
    shsize, shcount = struct.unpack_from('>HH', data, 46)
    sections = [struct.unpack_from('>10I', data, shoff+i*shsize) for i in range(shcount)]
    symbols = {}
    for section in sections:
        if section[1] != 2:
            continue
        string_section = sections[section[6]]
        strings = data[string_section[4]:string_section[4]+string_section[5]]
        for offset in range(section[4], section[4]+section[5], section[9]):
            name, value, size, info, other, index = struct.unpack_from('>IIIBBH', data, offset)
            name = strings[name:strings.find(b'\0', name)].decode()
            content = None
            if 0 < index < len(sections):
                target = sections[index]
                start = target[4]+value-target[3]
                content = data[start:start+size]
            if name:
                if name in symbols and symbols[name]['address'] != value:
                    raise ValueError('ambiguous symbol ' + name)
                symbols[name] = {'address': value, 'size': size, 'data': content,
                                 'section_index': index}
    return symbols


def elf_section(path, index):
    data = path.read_bytes()
    shoff = struct.unpack_from('>I', data, 32)[0]
    shsize = struct.unpack_from('>H', data, 46)[0]
    section = struct.unpack_from('>10I', data, shoff+index*shsize)
    if section[1] != 1:
        raise ValueError('expected a PROGBITS script section')
    return section[3], data[section[4]:section[4]+section[5]]


ITEM = re.compile(r'Init_int32\s+\(Int\.repr\s+(\(?-?\d+\)?)\)|'
                  r'Init_addrof\s+(_\w+)\s+\(Ptrofs\.repr\s+(\(?-?\d+\)?)\)')


def generated_initializers(path, version):
    source = path.read_text()
    if f'Decomp revision: {PIN}' not in source or f'Game version:    VERSION_{version.upper()}' not in source:
        raise ValueError('wrong generated source pin/version')
    result = {}
    for match in re.finditer(r'(?ms)^Definition v_(\w+) := \{\|(.*?)^\|\}\.', source):
        name, definition = match.groups()
        body = re.search(r'gvar_init :=\s*(.*?);', definition, re.S)[1].strip()
        if body == 'nil':
            continue
        if not (body.startswith('(') and body.endswith(')')):
            raise ValueError('unhandled initializer ' + name)
        body = body[1:-1]
        residue = ITEM.sub('', body).replace('::', '').replace('nil', '').strip()
        if residue:
            raise ValueError('unhandled initializer syntax ' + name + ': ' + residue)
        result[name] = [('scalar', int(item[1].strip('()')) & 0xffffffff)
                        if item[1] is not None else
                        ('relocation', item[2], int(item[3].strip('()')) & 0xffffffff)
                        for item in ITEM.finditer(body)]
    return result


def check_unit(version, unit, segment, root, symbols, elf, rom):
    generated = PROJECT / f'generated/{version}_{unit}.v'
    initializers = generated_initializers(generated, version)
    virtual_start = symbols[f'_{segment}SegmentStart']['address']
    rom_start = symbols[f'_{segment}SegmentRomStart']['address']
    rom_end = symbols[f'_{segment}SegmentRomEnd']['address']
    section_start, section = elf_section(elf, symbols[root]['section_index'])
    if section_start != virtual_start:
        raise ValueError('section/segment start disagreement ' + unit)
    placements = {name: symbols[name]['address'] for name in initializers if name in symbols}
    pending, checked, relocations = list(placements), {}, {}
    if root not in placements:
        raise ValueError('missing root placement ' + root)
    while pending:
        name = pending.pop(0)
        if name in checked:
            continue
        address = placements[name]
        items = initializers[name]
        size = 4*len(items)
        relative = address-virtual_start
        offset = rom_start+relative
        if relative < 0 or address % 4 or offset+size > rom_end:
            raise ValueError('script outside authenticated segment ' + name)
        data = rom[offset:offset+size]
        if data != section[relative:relative+size] or len(data) != size:
            raise ValueError('ELF/ROM script byte mismatch ' + name)
        if name in symbols and symbols[name]['size'] != size:
            raise ValueError('ELF/source script size mismatch ' + name)
        words = list(struct.unpack(f'>{len(items)}I', data))
        for item, word in zip(items, words):
            if item[0] == 'scalar':
                if word != item[1]:
                    raise ValueError('generated/retail scalar mismatch ' + name)
                continue
            _, atom, displacement = item
            referenced = atom[1:]
            if referenced in placements:
                target = placements[referenced]
            elif referenced in initializers:
                target = (word-displacement) & 0xffffffff
                placements[referenced] = target
                pending.append(referenced)
            elif referenced in symbols:
                target = symbols[referenced]['address']
            else:
                raise ValueError('unresolved actual relocation ' + atom)
            if word != (target+displacement) & 0xffffffff:
                raise ValueError('generated/ELF relocation mismatch ' + atom)
            if atom in relocations and relocations[atom] != target:
                raise ValueError('inconsistent relocation ' + atom)
            relocations[atom] = target
        checked[name] = {'address': address, 'rom_offset': offset, 'size': size,
                         'sha256': hashlib.sha256(data).hexdigest(), 'words': words}
    if set(checked) != set(initializers):
        raise ValueError('unreached static initializers: ' + repr(set(initializers)-set(checked)))
    ordered = sorted((row['address'], row['address']+row['size'], name)
                     for name, row in checked.items())
    if any(previous[1] > current[0] for previous, current in zip(ordered, ordered[1:])):
        raise ValueError('overlapping script initializer placements ' + unit)
    return {'unit': unit, 'segment': segment,
            'generated_sha256': hashlib.sha256(generated.read_text().encode()).hexdigest(),
            'initializers': checked, 'relocations': relocations}


def emit_coq(result):
    text = '''From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight Ctypes Globalenvs Integers Values.
From Demo.Generated Require Import us_level_scripts jp_level_scripts.
From Demo.Proofs Require Import DemoScriptDispatchFacts.
Import ListNotations.
Open Scope Z_scope.
Module SU := us_level_scripts.
Module SJ := jp_level_scripts.

(** Authenticated finite numeric word transcriptions. Authentication and ELF
    placement are checked outside Coq; the kernel checks each complete selected
    initializer against this explicit relocation-word representation. No new
    Clight dereference, call, or pointer/integer cast rule is introduced. *)
Fixpoint demo_numeric_relocation id (placements : list (ident * int)) : option int :=
  match placements with
  | [] => None
  | (name, address) :: rest =>
      if Pos.eqb id name then Some address else demo_numeric_relocation id rest
  end.

Definition demo_numeric_initializer_word placements datum : option int :=
  match datum with
  | Init_int32 word => Some word
  | Init_addrof id offset =>
      match demo_numeric_relocation id placements with
      | Some address => Some (Int.add address (Int.repr (Ptrofs.unsigned offset)))
      | None => None
      end
  | _ => None
  end.

Definition demo_initializer_word_representation placements datum word : Prop :=
  demo_numeric_initializer_word placements datum = Some word.

Definition demo_initializer_image_representation placements data words : Prop :=
  Forall2 (demo_initializer_word_representation placements) data words.

Fixpoint demo_initializer_image_matches placements data words : bool :=
  match data, words with
  | [], [] => true
  | datum :: rest, word :: remaining =>
      match demo_numeric_initializer_word placements datum with
      | Some expected => Int.eq expected word &&
          demo_initializer_image_matches placements rest remaining
      | None => false
      end
  | _, _ => false
  end.

Lemma demo_initializer_image_matches_sound : forall placements data words,
  demo_initializer_image_matches placements data words = true ->
  demo_initializer_image_representation placements data words.
Proof.
  intros placements data. induction data as [|datum rest IH];
    intros words Hcheck; destruct words as [|word remaining];
    cbn [demo_initializer_image_matches] in Hcheck; try discriminate.
  - constructor.
  - destruct (demo_numeric_initializer_word placements datum) as [expected|]
      eqn:Hvalue; [| discriminate].
    apply Bool.andb_true_iff in Hcheck as [Hhead Htail].
    pose proof (Int.eq_spec expected word) as Hequal.
    rewrite Hhead in Hequal. subst word.
    constructor; [exact Hvalue | apply IH; exact Htail].
Qed.

Inductive demo_symbol_address_representation (ge : Clight.genv) placements : val -> val -> Prop :=
| demo_symbol_address_represents : forall id block offset address,
    Genv.find_symbol ge id = Some block ->
    demo_numeric_relocation id placements = Some address ->
    demo_symbol_address_representation ge placements
      (Vptr block offset) (Vint (Int.add address (Int.repr (Ptrofs.unsigned offset)))).

Lemma demo_symbolic_pointer_is_not_integer_injection :
  forall injection block offset address,
    ~ Val.inject injection (Vptr block offset) (Vint address).
Proof. intros injection block offset address H; inversion H. Qed.

Fixpoint decode_demo_numeric_equality_arms fuel words : option (list (int * int)) :=
  match fuel with
  | O => None
  | S remaining =>
      match words with
      | [exit] => if Int.eq exit (Int.repr 33816576) then Some [] else None
      | jump :: argument :: target :: rest =>
          if Int.eq jump (Int.repr 202113536)
          then match decode_demo_numeric_equality_arms remaining rest with
               | Some arms => Some ((argument, target) :: arms)
               | None => None
               end
          else None
      | _ => None
      end
  end.

Fixpoint lookup_demo_numeric_arm header arms : option int :=
  match arms with
  | [] => None
  | (argument, target) :: rest =>
      if Int.eq header argument then Some target
      else lookup_demo_numeric_arm header rest
  end.

Definition checked_demo_numeric_dispatch_target header words : option int :=
  match words with
  | read :: rest =>
      if Int.eq read (Int.repr 1006895363)
      then match decode_demo_numeric_equality_arms (length words) rest with
           | Some arms => lookup_demo_numeric_arm (Int.repr header) arms
           | None => None
           end
      else None
  | _ => None
  end.

Definition demo_expected_numeric_route placements (route : option (ident * ident)) : option int :=
  match route with
  | Some (script, entry) => demo_numeric_relocation script placements
  | None => None
  end.

'''
    names = ['level_main_scripts_entry', 'script_exec_level_table']
    names += [f'script_exec_{name}' for name in ('bbh', 'ccm', 'hmc', 'jrb', 'wf', 'pss', 'bowser_1', 'bitdw')]
    claims = []
    for version, module in (('us', 'SU'), ('jp', 'SJ')):
        unit = result['versions'][version]['units'][0]
        text += f'Definition demo_{version}_script_numeric_relocations : list (ident * int) :=\n  ['
        text += ';\n   '.join(f'({module}.{atom}, Int.repr {address})'
                              for atom, address in sorted(unit['relocations'].items())) + '].\n\n'
        for name in names:
            words = unit['initializers'][name]['words']
            text += f'Definition demo_{version}_numeric_{name} : list int :=\n  map Int.repr\n  ['
            text += ';\n   '.join('; '.join(str(word) for word in words[i:i+8])
                                  for i in range(0, len(words), 8)) + '].\n\n'
            claims.append(f'demo_initializer_image_representation demo_{version}_script_numeric_relocations\n'
                          f'    (gvar_init {module}.v_{name}) demo_{version}_numeric_{name}')
    text += 'Definition demo_script_numeric_image_claim_us_jp : Prop :=\n  '
    text += ' /\\\n  '.join(claims) + '.\n\n'
    text += '''Theorem generated_demo_script_numeric_images_us_jp :
  demo_script_numeric_image_claim_us_jp.
Proof.
  unfold demo_script_numeric_image_claim_us_jp.
  repeat match goal with |- _ /\\ _ => split end;
    apply demo_initializer_image_matches_sound; vm_compute; reflexivity.
Qed.

Definition demo_script_numeric_dispatch_claim_us_jp : Prop :=
  map (fun header => checked_demo_numeric_dispatch_target header
         demo_us_numeric_script_exec_level_table) demo_dispatch_headers =
    map (demo_expected_numeric_route demo_us_script_numeric_relocations)
      expected_demo_dispatch_routes /\\
  map (fun header => checked_demo_numeric_dispatch_target header
         demo_jp_numeric_script_exec_level_table) demo_dispatch_headers =
    map (demo_expected_numeric_route demo_jp_script_numeric_relocations)
      expected_demo_dispatch_routes.

Theorem generated_demo_script_numeric_dispatch_us_jp :
  demo_script_numeric_dispatch_claim_us_jp.
Proof. vm_compute. split; reflexivity. Qed.

Definition demo_script_numeric_image_boundary_claim_us_jp : Prop :=
  demo_script_numeric_image_claim_us_jp /\\
  demo_script_numeric_dispatch_claim_us_jp /\\
  (forall injection block offset address,
    ~ Val.inject injection (Vptr block offset) (Vint address)).

Theorem generated_demo_script_numeric_image_boundary_us_jp :
  demo_script_numeric_image_boundary_claim_us_jp.
Proof.
  exact (conj generated_demo_script_numeric_images_us_jp
    (conj generated_demo_script_numeric_dispatch_us_jp
      demo_symbolic_pointer_is_not_integer_injection)).
Qed.
'''
    return text


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--inspect', action='store_true')
    parser.add_argument('--write', type=Path)
    parser.add_argument('--write-coq', type=Path)
    parser.add_argument('--check-receipt', type=Path)
    parser.add_argument('--check-coq', type=Path)
    args = parser.parse_args()
    result = {'scope': 'authenticated finite script/relocation images; not execution simulation',
              'source_revision': PIN, 'versions': {}}
    for version in ('us', 'jp'):
        path = CACHE / f'build/{version}/sm64.{version}.elf'
        symbols = elf_symbols(path)
        selected = ('_scriptsSegmentStart', '_scriptsSegmentRomStart', '_scriptsSegmentRomEnd',
                    'level_main_scripts_entry', 'script_exec_level_table',
                    'script_exec_bowser_1', 'level_bowser_1_entry',
                    '_bowser_1SegmentStart', '_bowser_1SegmentRomStart',
                    '_mainSegmentStart', '_mainSegmentRomStart',
                    'lvl_init_from_save_file', 'lvl_set_current_level', 'lvl_init_or_update')
        if args.inspect:
            result['versions'][version] = {name: {key: value for key, value in symbols[name].items()
                                                 if key != 'data'}
                                           for name in selected if name in symbols}
            continue
        rom_path = SOURCE / f'baserom.{version}.z64'
        rom = rom_path.read_bytes()
        expected_sha1 = subprocess.check_output(['git', '-c', f'safe.directory={SOURCE}',
            '-C', str(SOURCE), 'show', f'{PIN}:sm64.{version}.sha1']).decode().split()[0]
        if hashlib.sha1(rom).hexdigest() != expected_sha1:
            raise ValueError('wrong clean ROM SHA-1')
        cache_rom = CACHE / f'build/{version}/sm64.{version}.z64'
        if rom != cache_rom.read_bytes():
            raise ValueError('matching ELF build ROM differs from clean ROM')
        units = [('level_scripts', 'scripts', 'level_main_scripts_entry')]
        units += [(f'{name}_level_script', name, f'level_{name}_entry')
                  for name in ('bbh', 'ccm', 'hmc', 'jrb', 'wf', 'pss', 'bowser_1', 'bitdw')]
        checked = [check_unit(version, unit, segment, root, symbols, path, rom)
                   for unit, segment, root in units]
        code = {}
        for name in ('lvl_init_from_save_file', 'lvl_set_current_level', 'lvl_init_or_update'):
            row = symbols[name]
            offset = (symbols['_mainSegmentRomStart']['address'] + row['address'] -
                      symbols['_mainSegmentStart']['address'])
            if row['data'] != rom[offset:offset+row['size']] or not row['size']:
                raise ValueError('retail callback code mismatch ' + name)
            code[name] = {'address': row['address'], 'size': row['size'], 'rom_offset': offset,
                          'sha256': hashlib.sha256(row['data']).hexdigest()}
        result['versions'][version] = {'rom_sha1': expected_sha1,
            'rom_sha256': hashlib.sha256(rom).hexdigest(),
            'elf_sha256': hashlib.sha256(path.read_bytes()).hexdigest(),
            'units': checked, 'callbacks': code}
    if args.write_coq:
        args.write_coq.write_text(emit_coq(result))
    if args.check_coq and args.check_coq.read_text() != emit_coq(result):
        raise ValueError('Coq numeric-image transcription differs from authenticated words')
    if not args.inspect:
        for version in result['versions'].values():
            for unit in version['units']:
                for row in unit['initializers'].values():
                    del row['words']
    text = json.dumps(result, indent=2) + '\n'
    if args.write:
        args.write.write_text(text)
        print('Authenticated US/JP script units and callback bytes; receipt:', args.write)
    else:
        if args.check_receipt:
            if args.check_receipt.read_text() != text:
                raise ValueError('script-image metadata receipt differs')
            print('Authenticated US/JP complete selected script images, relocations and callback bytes OK.')
        else:
            print(text)


if __name__ == '__main__':
    main()
