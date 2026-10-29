"""Build an instance's tile and portrait art from its loading screen.

The instance list draws a 174x96 tile per instance, and the overview header draws
a round 64x64 portrait of the same place. Forever ships neither, so both are cut
from the dungeon's loading screen -- the same source the lore background uses.

    python tools/make_dungeonbutton.py build <source> CityOfDalaran
    python tools/make_dungeonbutton.py build <source> CityOfDalaran --pan-x 0.5
    python tools/make_dungeonbutton.py check <source> TheHallOfThanes

`build` writes `images/UIEJDungeonButton<Name>.png` and
`images/UIEJDungeonPortrait<Name>.png`, and prints the two data lines to wire up.
`check` rebuilds an existing pair and reports how closely it reproduces them,
which is how the recipe below was confirmed.

The source may be PNG, JPEG or BLP. Forever's loading screens live in the client
under `Interface/GLUES/LOADINGSCREENS/Camelot160/Main/`.

Needs Pillow; shares the BLP decoder with blp2png.py.

The recipe
----------
Recovered from the five tiles that already shipped, by correlating each against
its loading screen on luminance -- the paintings are single-hue, so a colour
difference finds nothing and says the art is unrelated when it is not.

- The loading screen is letterboxed: grey bars above and below a wide painted
  band. Everything is cut from the band, never from the full file.
- The tile is the *left* of the band, cropped to the tile's aspect and taking the
  band's full height. Left, not centre: these paintings put their subject left of
  centre, and the five that shipped are all anchored there.
- The art occupies (3, 3)-(172, 88) of a 256x128 canvas and is transparent
  elsewhere. The margin is not decoration -- the button draws a frame around the
  art, and art without the margin runs under it.
- The portrait is the centre square of that same crop, at 128x128. It carries a
  mask at runtime, so it must not be given tex coords; see commit 642716a.
"""
import argparse
import os
import sys

from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from blp2png import read_blp  # noqa: E402

HERE = os.path.dirname(os.path.abspath(__file__))
AG_ROOT = os.path.dirname(HERE)
IMAGES = os.path.join(AG_ROOT, "images")

# The tile canvas, and where the picture sits on it.
TILE_CANVAS = (256, 128)
TILE_BOX = (3, 3, 172, 88)
PORTRAIT = 128

# A row counts as letterbox if it is flat, and the same grey as the corner. The
# bars are a flat 127-148 but carry compression noise, so "flat" has to mean a
# spread of around ten rather than none; the painted rows spread 60 and more, so
# there is a wide gap to put the line in.
BAR_SPREAD = 25
BAR_DISTANCE = 25


def open_any(path):
    """A PNG, JPEG or BLP as RGB."""
    if path.lower().endswith(".blp"):
        im, description = read_blp(path)
        if im is None:
            raise SystemExit("could not read %s: %s" % (path, description))
        return im.convert("RGB")
    return Image.open(path).convert("RGB")


def art_band(im):
    """The painted band, with the grey letterbox bars taken off.

    Returns (top, bottom). An image with no bars returns its full height, so a
    source that has already been trimmed passes through untouched.
    """
    width, height = im.size
    grey = im.convert("L")
    row_px = [list(grey.crop((0, y, width, y + 1)).getdata()) for y in range(height)]
    corner = grey.getpixel((0, 0))

    def is_bar(y):
        px = row_px[y]
        lo, hi = min(px), max(px)
        if hi - lo > BAR_SPREAD:
            return False
        return abs(sum(px) / float(len(px)) - corner) <= BAR_DISTANCE

    top = 0
    while top < height and is_bar(top):
        top += 1
    bottom = height
    while bottom > top and is_bar(bottom - 1):
        bottom -= 1
    if bottom - top < height // 4:
        # Nothing sensible found; treat the whole image as the band.
        return 0, height
    return top, bottom


def tile_crop(im, pan_x):
    """The region of the source the tile is cut from, as a box.

    Full band height, width set by the tile's aspect, slid horizontally by
    pan_x (0 = hard left, which is what the shipped art uses).
    """
    top, bottom = art_band(im)
    band_h = bottom - top
    tile_w = TILE_BOX[2] - TILE_BOX[0]
    tile_h = TILE_BOX[3] - TILE_BOX[1]
    want_w = min(im.size[0], round(band_h * tile_w / float(tile_h)))
    max_x = im.size[0] - want_w
    x0 = int(round(max_x * pan_x))
    return (x0, top, x0 + want_w, bottom)


def build(source_path, name, pan_x):
    im = open_any(source_path)
    box = tile_crop(im, pan_x)
    top, bottom = box[1], box[3]
    print("source %dx%d, painted band y=%d..%d, tile crop %s"
          % (im.size[0], im.size[1], top, bottom, (box,)))

    picture = im.crop(box)

    # The tile: the crop, on a transparent canvas, inside the frame margin.
    tile_w = TILE_BOX[2] - TILE_BOX[0]
    tile_h = TILE_BOX[3] - TILE_BOX[1]
    tile = Image.new("RGBA", TILE_CANVAS, (0, 0, 0, 0))
    tile.paste(picture.resize((tile_w, tile_h), Image.LANCZOS),
               (TILE_BOX[0], TILE_BOX[1]))

    # The portrait: the centre square of the same crop.
    side = min(picture.size)
    left = (picture.size[0] - side) // 2
    topc = (picture.size[1] - side) // 2
    portrait = picture.crop((left, topc, left + side, topc + side))
    portrait = portrait.resize((PORTRAIT, PORTRAIT), Image.LANCZOS).convert("RGBA")

    tile_path = os.path.join(IMAGES, "UIEJDungeonButton%s.png" % name)
    portrait_path = os.path.join(IMAGES, "UIEJDungeonPortrait%s.png" % name)
    tile.save(tile_path)
    portrait.save(portrait_path)
    print("wrote %s" % tile_path)
    print("wrote %s" % portrait_path)
    print()
    print("Wire it up in the instance's data file:")
    print("\ticon = I.UIEJDungeonPortrait%s," % name)
    print("\tthumbnail = I.UIEJDungeonButton%s," % name)
    return tile, portrait


def zncc(a, b):
    """Correlation on luminance, so colour grading cannot flatter or spoil it."""
    ap = [p / 255.0 for p in a.convert("L").getdata()]
    bp = [p / 255.0 for p in b.convert("L").getdata()]
    am = sum(ap) / len(ap)
    bm = sum(bp) / len(bp)
    num = sum((x - am) * (y - bm) for x, y in zip(ap, bp))
    da = sum((x - am) ** 2 for x in ap) ** 0.5 or 1.0
    db = sum((y - bm) ** 2 for y in bp) ** 0.5 or 1.0
    return num / (da * db)


def cmd_build(args):
    build(args.source, args.name, args.pan_x)


def cmd_check(args):
    """Rebuild art that already ships and say how well the recipe reproduces it."""
    existing_tile = os.path.join(IMAGES, "UIEJDungeonButton%s.png" % args.name)
    existing_portrait = os.path.join(IMAGES, "UIEJDungeonPortrait%s.png" % args.name)
    keep = {}
    for path in (existing_tile, existing_portrait):
        if os.path.exists(path):
            keep[path] = open(path, "rb").read()
    try:
        tile, portrait = build(args.source, args.name, args.pan_x)
        print()
        for path, made in ((existing_tile, tile), (existing_portrait, portrait)):
            if path not in keep:
                print("%s: nothing to compare against" % os.path.basename(path))
                continue
            import io
            was = Image.open(io.BytesIO(keep[path])).convert("RGBA")
            crop = was.getchannel("A").getbbox()
            print("%s: zncc=%.4f over %s"
                  % (os.path.basename(path), zncc(was.crop(crop), made.crop(crop)),
                     (crop,)))
    finally:
        for path, data in keep.items():
            with open(path, "wb") as fh:
                fh.write(data)
        print("\nrestored the art that was already there")


def main():
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = p.add_subparsers(dest="command", required=True)

    b = sub.add_parser("build", help="make the tile and portrait for an instance")
    b.add_argument("source", help="loading screen: PNG, JPEG or BLP")
    b.add_argument("name", help="CamelCase instance name, e.g. CityOfDalaran")
    b.add_argument("--pan-x", type=float, default=0.0,
                   help="0 = left (the default, and what the shipped art uses)")
    b.set_defaults(func=cmd_build)

    c = sub.add_parser("check", help="rebuild existing art and score the recipe")
    c.add_argument("source")
    c.add_argument("name")
    c.add_argument("--pan-x", type=float, default=0.0)
    c.set_defaults(func=cmd_check)

    args = p.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
