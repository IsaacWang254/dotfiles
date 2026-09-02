#!/usr/bin/env python3
"""Read or apply the dongle's QMK settings (tap-hold, Auto Shift, ...).

These live in the firmware's settings store, NOT in the keymap, so apply.py
does not touch them and keymap.bin does not capture them. They survive a keymap
rewrite and are lost by a settings reset -- which is why the values we care
about are tracked in settings.json.

Usage:
    python3 settings.py            # show current values, flag drift
    python3 settings.py --apply    # write settings.json to the dongle

Needs:  brew install hidapi  &&  pip install hid
"""
import json
import os
import sys

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
USAGE_PAGE, USAGE = 0xFF60, 0x61

# qsid -> (byte width, human name). Widths come from Vial's qmk_settings.json:
# bitfields are one byte, integers two.
FIELDS = {
    3: (1, "Auto Shift flags (bit0 = enable)"),
    4: (2, "Auto Shift timeout (ms)"),
    7: (2, "Tapping term (ms)"),
    8: (1, "Tap-hold flags (permissive hold, IMTI, force hold, retro)"),
}

HERE = os.path.dirname(os.path.abspath(__file__))
TRACKED = os.path.join(HERE, "settings.json")


def open_device():
    paths = [d["path"] for d in hid.enumerate(VID, PID)
             if d["usage_page"] == USAGE_PAGE and d["usage"] == USAGE]
    if not paths:
        sys.exit("dongle not found. Is it plugged in?")
    return hid.Device(path=paths[0])


def cmd(dev, *payload):
    dev.write(b"\x00" + bytes(payload) + b"\x00" * (32 - len(payload)))
    return bytes(dev.read(32, timeout=1000))


def get(dev, qsid, width):
    resp = cmd(dev, 0xFE, 0x0A, qsid & 0xFF, qsid >> 8)
    if resp[0] != 0:
        sys.exit(f"qsid {qsid}: device refused the read")
    return int.from_bytes(resp[1:1 + width], "little")


def put(dev, qsid, width, value):
    cmd(dev, 0xFE, 0x0B, qsid & 0xFF, qsid >> 8, *value.to_bytes(width, "little"))


def main():
    apply = "--apply" in sys.argv[1:]
    tracked = {int(k): v for k, v in json.load(open(TRACKED)).items()}
    dev = open_device()

    drift = 0
    for qsid, (width, name) in sorted(FIELDS.items()):
        if apply:
            put(dev, qsid, width, tracked[qsid])
        live = get(dev, qsid, width)
        want = tracked[qsid]
        flag = "" if live == want else f"  <- drift, settings.json says {want}"
        if live != want:
            drift += 1
        print(f"  qsid {qsid:>2}  {name:<56} = {live}{flag}")

    if apply:
        print("\napplied settings.json" if not drift else "\nAPPLY FAILED: values did not stick")
        sys.exit(1 if drift else 0)
    if drift:
        print(f"\n{drift} setting(s) differ from settings.json. To fix:  python3 settings.py --apply")
        sys.exit(1)
    print("\nall tracked settings match settings.json")


if __name__ == "__main__":
    main()
