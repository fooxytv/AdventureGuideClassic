"""Build an Encounter Journal lore background from a source image.

Forever publishes no journal, so its dungeons ship no `UI-EJ-LOREBG-*` art and the
overview falls back to a flat dark panel. A lore background is not freehand work,
though: every retail one is a source picture dropped into the same torn frame, at
the same size, in the same place. That is a recipe, so this applies it.

    python tools/make_lorebg.py build <source> CityOfDalaran
    python tools/make_lorebg.py build <source> CityOfDalaran --zoom 1.3 --pan-y 0.3
    python tools/make_lorebg.py frame <dir-of-retail-UI-EJ-LOREBG-art>

`build` writes `images/UIEJLoreBG<Name>.png`; point the instance's `splash` at
`I.UIEJLoreBG<Name>`. `frame` regenerates the two templates beside this script and
is only needed if they are ever lost -- see *Where the frame comes from* below.

The source may be PNG, JPEG or BLP. Loading screens make good sources: Forever's
own live in the client under
`Interface/GLUES/LOADINGSCREENS/Camelot160/Main/`.

Needs Pillow; shares the BLP decoder with blp2png.py.

Where the frame comes from
--------------------------
Measured across 40 retail lore backgrounds, not guessed:

- The canvas is 512x512 and the picture occupies exactly (4, 4)-(394, 340).
- The torn edge is an alpha mask, identical in 99.4% of pixels across all 40.
- The frame is an overlay. Pixels near the edge barely vary between instances
  (a luminance spread of ~17 six pixels in, against ~100 forty pixels in), so
  `frame` separates the two by that spread: consistent means frame, varying
  means picture.
"""
import argparse
import os
import statistics
import sys

from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from blp2png import read_blp  # noqa: E402

HERE = os.path.dirname(os.path.abspath(__file__))
AG_ROOT = os.path.dirname(HERE)
MASK_PATH = os.path.join(HERE, "lorebg_mask.png")
FRAME_PATH = os.path.join(HERE, "lorebg_frame.png")

CANVAS = 512
BOX = (4, 4, 394, 340)
CONTENT = (BOX[2] - BOX[0], BOX[3] - BOX[1])

# Luminance spread, in levels, below which a pixel counts as frame and above
# which it counts as picture. Between the two the overlay fades out.
FRAME_LO, FRAME_HI = 18.0, 46.0


def open_any(path):
    """A PNG, JPEG or BLP as RGBA. read_blp returns (image or None, why)."""
    if path.lower().endswith(".blp"):
        im, description = read_blp(path)
        if im is None:
            sys.exit("cannot read %s: %s" % (path, description))
        return im.convert("RGBA")
    return Image.open(path).convert("RGBA")


def load_image(path):
    return open_any(path).convert("RGB")


# ---------- letterboxing ----------

def _spread(values):
    """The 2nd-to-98th percentile range, so one stray pixel cannot widen it."""
    values = sorted(values)
    n = len(values)
    return values[int(n * 0.98)] - values[int(n * 0.02)]


def _longest_run(flat):
    """Bounds of the longest stretch of non-flat lines."""
    best, start = (0, 0), None
    for index, is_flat in enumerate(flat + [True]):
        if not is_flat and start is None:
            start = index
        elif is_flat and start is not None:
            if index - start > best[1] - best[0]:
                best = (start, index)
            start = None
    return best


def trim_letterbox(im, tol=6):
    """Drop the flat bands a loading screen is padded with.

    The longest run rather than a walk in from each edge: a single noisy line at
    the very top is common and stops a walk dead, keeping the whole grey band.
    """
    px = im.load()
    w, h = im.size
    rows = [_spread([v for x in range(0, w, 11) for v in px[x, y]]) <= tol
            for y in range(h)]
    top, bottom = _longest_run(rows)
    cols = [_spread([v for y in range(top, bottom, 11) for v in px[x, y]]) <= tol
            for x in range(w)]
    left, right = _longest_run(cols)
    if right - left < 16 or bottom - top < 16:
        return im
    return im.crop((left, top, right, bottom))


# ---------- building ----------

def fit(im, zoom=1.0, pan_x=0.5, pan_y=0.5):
    """Crop the largest region of the right shape, then zoom and pan within it."""
    w, h = im.size
    want = CONTENT[0] / CONTENT[1]
    cw, ch = (h * want, h) if w / h > want else (w, w / want)
    cw, ch = cw / zoom, ch / zoom
    x, y = (w - cw) * pan_x, (h - ch) * pan_y
    crop = im.crop((round(x), round(y), round(x + cw), round(y + ch)))
    return crop.resize(CONTENT, Image.LANCZOS)


def build(source, zoom=1.0, pan_x=0.5, pan_y=0.5):
    for path in (MASK_PATH, FRAME_PATH):
        if not os.path.exists(path):
            sys.exit("missing %s -- run `frame` first" % os.path.relpath(path, AG_ROOT))
    mask = Image.open(MASK_PATH).convert("L")
    frame = Image.open(FRAME_PATH).convert("RGBA")
    picture = fit(trim_letterbox(load_image(source)), zoom, pan_x, pan_y)
    out = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
    out.paste(picture, (BOX[0], BOX[1]))
    out = Image.alpha_composite(out, frame)
    out.putalpha(mask)
    return out


def cmd_build(args):
    out = build(args.source, args.zoom, args.pan_x, args.pan_y)
    name = args.name
    for prefix in ("UIEJLoreBG", "I.UIEJLoreBG"):
        if name.startswith(prefix):
            name = name[len(prefix):]
    path = args.out or os.path.join(AG_ROOT, "images", "UIEJLoreBG%s.png" % name)
    if args.dry_run:
        print("would write %s" % os.path.relpath(path, AG_ROOT))
        return
    out.save(path)
    print("%s  %dx%d  %.0f KB" % (os.path.relpath(path, AG_ROOT).replace("\\", "/"),
                                  out.width, out.height,
                                  os.path.getsize(path) / 1024))
    print("    splash = I.UIEJLoreBG%s," % name)


def cmd_frame(args):
    """Rebuild the mask and frame templates from a folder of retail lore art."""
    names = sorted(n for n in os.listdir(args.source)
                   if "LOREBG" in n.upper() and "DEFAULT" not in n.upper()
                   and n.lower().endswith((".blp", ".png")))
    if len(names) < 8:
        sys.exit("found %d lore backgrounds in %s -- need at least 8 to separate "
                 "frame from picture" % (len(names), args.source))
    ims = []
    for name in names:
        im = open_any(os.path.join(args.source, name))
        if im.size != (CANVAS, CANVAS):
            print("  skipping %s (%dx%d)" % (name, *im.size))
            continue
        ims.append(im)
    print("sampling %d lore backgrounds" % len(ims))
    px = [im.load() for im in ims]

    mask = Image.new("L", (CANVAS, CANVAS))
    mp = mask.load()
    frame = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
    fp = frame.load()
    for y in range(CANVAS):
        for x in range(CANVAS):
            mp[x, y] = int(statistics.median(p[x, y][3] for p in px))
    for y in range(BOX[1], BOX[3]):
        for x in range(BOX[0], BOX[2]):
            vs = [p[x, y] for p in px]
            lum = sorted(sum(v[:3]) / 3 for v in vs)
            spread = lum[int(len(lum) * 0.9)] - lum[int(len(lum) * 0.1)]
            if spread >= FRAME_HI:
                continue
            alpha = 255 if spread <= FRAME_LO else int(
                255 * (FRAME_HI - spread) / (FRAME_HI - FRAME_LO))
            rgb = tuple(int(statistics.median(v[c] for v in vs)) for c in range(3))
            fp[x, y] = rgb + (alpha,)
    mask.save(MASK_PATH)
    frame.save(FRAME_PATH)
    print("wrote %s and %s" % (os.path.relpath(MASK_PATH, AG_ROOT),
                               os.path.relpath(FRAME_PATH, AG_ROOT)))
    print("picture window %s, mask bbox %s" % (str(CONTENT), str(mask.getbbox())))


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(required=True)

    b = sub.add_parser("build", help="make images/UIEJLoreBG<Name>.png from a picture")
    b.add_argument("source", help="PNG, JPEG or BLP")
    b.add_argument("name", help="instance name, no spaces, e.g. CityOfDalaran")
    b.add_argument("--zoom", type=float, default=1.0, help="above 1 crops in tighter")
    b.add_argument("--pan-x", type=float, default=0.5, help="0 left, 1 right")
    b.add_argument("--pan-y", type=float, default=0.5, help="0 top, 1 bottom")
    b.add_argument("--out", help="write here instead of images/")
    b.add_argument("--dry-run", action="store_true")
    b.set_defaults(func=cmd_build)

    f = sub.add_parser("frame", help="rebuild the mask and frame templates")
    f.add_argument("source", help="folder of retail UI-EJ-LOREBG-* art")
    f.set_defaults(func=cmd_frame)

    args = ap.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
