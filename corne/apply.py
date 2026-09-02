#!/usr/bin/env python3
"""Write keymap.bin to the Corne's 2.4GHz dongle over Vial's raw HID interface.

The dongle holds the QMK keymap; the halves only report matrix events. So the
keymap lives on the dongle and is written here, with no reflash and no cable.

Usage:
    python3 apply.py                 # write keymap.bin (next to this script)
    python3 apply.py other.bin       # write some other dump
    python3 apply.py --read out.bin  # dump the dongle's current keymap instead

Needs:  brew install hidapi  &&  pip install hid
"""
import os
import struct
import sys

# The `hid` package resolves libhidapi through dyld, which does not search
# Homebrew's prefix by default. DYLD_LIBRARY_PATH is only read at process
# launch, so re-exec ourselves once with it set rather than failing.
try:
    import hid
except Exception:
    if os.environ.get("_CORNE_REEXEC") != "1":
        env = dict(os.environ, _CORNE_REEXEC="1")
        for prefix in ("/opt/homebrew/lib", "/usr/local/lib"):
            if os.path.exists(os.path.join(prefix, "libhidapi.dylib")):
                env["DYLD_LIBRARY_PATH"] = prefix
                os.execve(sys.executable, [sys.executable] + sys.argv, env)
    sys.exit("could not load hidapi. Try:  brew install hidapi && pip install hid")

VID, PID = 0xFEED, 0x0007
USAGE_PAGE, USAGE = 0xFF60, 0x61     # Vial/VIA raw HID interface
LAYERS, ROWS, COLS = 8, 5, 14        # this board's dynamic keymap dimensions
SIZE = LAYERS * ROWS * COLS * 2

HERE = os.path.dirname(os.path.abspath(__file__))


def open_device():
    paths = [d["path"] for d in hid.enumerate(VID, PID)
             if d["usage_page"] == USAGE_PAGE and d["usage"] == USAGE]
    if not paths:
        sys.exit("dongle not found. Is it plugged in?")
    return hid.Device(path=paths[0])


def cmd(dev, *payload):
    dev.write(b"\x00" + bytes(payload) + b"\x00" * (32 - len(payload)))
    return bytes(dev.read(32, timeout=1000))


def read_keymap(dev):
    buf = b""
    while len(buf) < SIZE:
        off, n = len(buf), min(28, SIZE - len(buf))
        buf += cmd(dev, 0x12, (off >> 8) & 0xFF, off & 0xFF, n)[4:4 + n]
    return buf


def main():
    args = sys.argv[1:]
    dev = open_device()

    if args and args[0] == "--read":
        dest = args[1] if len(args) > 1 else os.path.join(HERE, "keymap.bin")
        open(dest, "wb").write(read_keymap(dev))
        print(f"read {SIZE} bytes -> {dest}")
        return

    src = args[0] if args else os.path.join(HERE, "keymap.bin")
    buf = open(src, "rb").read()
    if len(buf) != SIZE:
        sys.exit(f"{src}: expected {SIZE} bytes, got {len(buf)}")

    written = 0
    for layer in range(LAYERS):
        for row in range(ROWS):
            for col in range(COLS):
                kc = struct.unpack(">H", buf[((layer * ROWS + row) * COLS + col) * 2:][:2])[0]
                cmd(dev, 0x05, layer, row, col, (kc >> 8) & 0xFF, kc & 0xFF)
                written += 1

    after = read_keymap(dev)
    bad = sum(1 for i in range(0, SIZE, 2) if after[i:i + 2] != buf[i:i + 2])
    print(f"wrote {written} keys from {os.path.basename(src)}, "
          f"verified {written - bad}/{written}")
    if bad:
        sys.exit(f"{bad} keys did not match after write")


if __name__ == "__main__":
    main()
