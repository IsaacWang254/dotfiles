# Corne (w-corne-choc, 2.4GHz)

42-key split (3x6 + 3 thumbs), Keyclicks W-corne on an STM32 dongle running a
QMK/Vial vendor fork. The **dongle** holds the firmware and the keymap; the
halves only report matrix events over 2.4GHz. So there is nothing to flash and
no cable involved — the keymap is written to the dongle over raw HID.

The halves' USB-C ports are charge-only. Typing while wired is not a thing this
board does.

## Device identity

| | |
|---|---|
| USB | VID `0xFEED`, PID `0x0007`, product `w-corne-choc(STM32)` |
| Raw HID | usage page `0xFF60`, usage `0x61` |
| VIA protocol | 9 (new-generation keycodes: `MO(n)` = `0x5220+n`) |
| Vial protocol | 6, unlocked |
| Dynamic keymap | 8 layers x 5 rows x 14 cols = 1120 bytes |

Matrix: cols 1-6 are the left half (col 1 = outer), cols 8-13 the right half
(col 8 = outer, col 13 = inner). Row 3 holds the thumbs at cols 4/5/6 and
11/12/13. Cols 0 and 7 and row 4 are unused.

## Layout

Based on <https://github.com/charlietlamb/corne-config> (`crkbd-2.layout.json`),
translated onto this board's matrix.

```
Layer 0
 Tab   Q  W  E  R  T  ‖  Y  U  I  O  P   BSpc
 Ctrl  A  S  D  F  G  ‖  H  J  K  L  ;   '
 Shift Z  X  C  V  B  ‖  N  M  ,  .  /   RShift
        Cmd  MO1  Spc ‖ Ent  MO2  Esc*

Layer 1 (hold MO1, left thumb)      Layer 2 (hold MO2, right thumb)
 Tab   ! @ # $ %  ‖ ^ & * ( )  BSpc  F1..F6        ‖ F7..F12
 Ctrl  1 2 3 4 5  ‖ ` - = { }  \     Media/Volume  ‖ <- v ^ ->  \  `
 Shift 6 7 8 9 0  ‖ ~ _ + [ ]  |     RGB/prev-next ‖ _ + { } |  RAlt
```

`Esc*` is `MT(MOD_RALT, KC_ESC)` — tap for Escape, hold for Right Alt. It is the
only Alt on the base layer, which is why the AeroSpace bindings in this repo use
`alt` plus a base-layer *letter* rather than a number (digits live on layer 1, so
`alt-1` would need both thumbs). See `../aerospace/aerospace.toml`.

Layer 3 is the tri-layer (hold both MO1 and MO2) and carries `QK_BOOT` plus RGB
controls. This board has no RGB, and the firmware probably has no tri-layer, so
it is almost certainly unreachable. `QK_BOOT` there would put the *dongle* into
bootloader, not the halves.

## Applying it

Two ways in. The raw-HID path is the one that has actually been exercised:

```sh
brew install hidapi
pip install hid
python3 apply.py            # writes keymap.bin, then verifies by reading back
```

Or import `keymap.layout.json` at <https://vial.rocks> in Chrome/Edge, which
needs nothing installed. Same keymap in VIA's export format.

To capture the dongle's current state before changing anything:

```sh
python3 apply.py --read backup.bin
python3 apply.py backup.bin     # ...and to put it back
```

`keymap.bin` is the exact 1120-byte dynamic keymap buffer read off the device;
`keymap.layout.json` is the same thing as keycode names.

## Tap-hold settings

These live in the firmware's QMK settings, not the keymap, and `apply.py` does
not touch them. Current values, readable and writable over the same raw HID
interface (Vial exposes 21 settings here):

| Setting | Value |
|---|---|
| Tapping Term | 200 ms |
| Permissive Hold / Ignore Mod Tap Interrupt / Tapping Force Hold / Retro Tapping | all off |
| Combo term | 50 ms |

If home-row mods ever go on this board, those are the knobs to turn — no reflash
needed.

## Gotchas

- No pairing procedure exists. Power the halves on and they associate with the
  dongle in a few seconds. If nothing types, it is batteries or the power
  sliders, not pairing.
- Keep the dongle off a USB hub if keys start dropping — hubs are 2.4GHz noise.
