# Retail JP call handoff

Experimental call-level integration, not a Coq proof or completed inverse
gameplay search. See [scope and results](../../docs/notes/rank1-emulator-call-handoff.md).

1. In Ubuntu-24.04 WSL, run `bash instrumentation/rank1-emulator-handoff/capture.sh /path/to/baserom.jp.z64` from the SSL project. It authenticates the ROM, compiles the read-only observer and replays the existing clean no-A controller schedule. The output directory is printed. The only setup is the accepted pre-entry level-select flag.
2. Export a **retail-matching** JP ELF symbol table with `mips-linux-gnu-nm --defined-only` to an ignored file. A nonmatching local build was caught by the instruction checks during development; matching symbol names alone are insufficient. The checked retail map has gMarioStates at 0x80339e00 and find_floor at 0x80381900. Never remove authentication to accommodate a different map.
3. With the existing Python/Z3 environment, run `python instrumentation/rank1-emulator-handoff/check.py --capture PATH/raw.log --rom PATH/baserom.jp.z64 --symbols PATH/retail-jp-symbols.txt --output build/rank1-backward-search/handoff.json`. It checks each anchored reply against an actual generated caller and rejects conflicting replies.
4. Attempt the broad horizon with `python instrumentation/rank1-backward-search/search_updates.py --updates 30 --versions jp --emulator-capture PATH/raw.log --output build/rank1-backward-search/hybrid-run --timeout 180 --solver-seconds 30`. Add `--lazy-calls` to construct a relaxed proposal before expanding all other source bodies. Exit code 2 means coverage remains incomplete, including when the relaxed solver returns SAT.

The replay window defaults to polls 2651–2680. Set R1_HANDOFF_FIRST for a
different 30-poll observer window. Check the actual completed checkpoint count;
30 polls are not universally 30 Mario updates. The current window ends with
the top timer at 131 and no retained platform.

The bridge's case key is capture SHA256 + event ID + version. This key is a
scope restriction, not a proof that a symbolic predecessor reaches that event.
Mapped bytes cover pads and position vectors; other memory and devices are
not framed. Native observations map targets to generated bodies and Object
slots; they do not establish universal live-script persistence. The checker
does not splice emulator addresses into the symbolic address space.

The source-expansion attempt timed out; the lazy query is only an unverified
proposal with 64 pending sites. Neither is a finished one-second exhaustive
search, and neither measures the cost of longer exhaustive searches.
