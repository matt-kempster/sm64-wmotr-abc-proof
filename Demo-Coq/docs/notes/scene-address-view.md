# Explicit numerical view for selected scene operands

The gameplay verdict remains **OPEN**. `DemoSceneAddressView.v` connects the
unchanged generated numerical address helper to an explicit decoder view of a
supplied memory block. It is not a source/native execution simulation and does
not establish a loaded scene's level identity.

The operand comes from `DemoSceneSourceInventory.v`: an actual AREA geometry
or TERRAIN relocation in a checked selected source entry. Its numerical word
is checked against the existing authenticated US/JP script/ELF receipt. No demo
input header supplies the source owner.

`demo_scene_address_image` carries a supplied block, epoch, physical base,
start and length. Arithmetic bounds keep the calculation within the KSEG0
address domain. They do not prove that this block is active, that its bytes
are authentic, that its extent contains a complete geometry/collision asset,
or that the loader established its epoch. Those are separate requirements of
the future runtime correspondence. The epoch is explicit data, not a fact
inferred from the numerical address.

Under those bounds and the actual segment-table load, the theorem executes
the original `segmented_to_virtual` on the selected numerical operand and
decodes its result to the supplied block at offset0. The source-view load
equals `Mem.load` at that location. Equality alone can be `None = None`;
readability and actual data contents still require evidence.

The local witness chooses an arbitrary block and a one-byte extent. It proves
only that the arithmetic view's premises can be inhabited once the supplied
source/native operand conditions hold. It is not a complete asset, loader,
normal-boot, SDK or authenticated-gameplay witness.

The [actual builder diagnostic](scene-address-boundary.md) explains why this
view cannot be silently inserted as the caller's next ordinary Clight step:
symbolic operands fail the helper's bit shift, while numerical results fail
the subsequent actual builder dereference. A justified execution correspondence
must account for both crossings, loads/stores, indirect calls and active-image
lifetimes. This module supplies one explicit calculation component of that
work and closes no major unchecked gameplay obligation.
