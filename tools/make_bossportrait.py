"""Build an Encounter Journal boss portrait from a picture of the model.

The journal draws a boss as a 128x64 cut-out standing on the bottom edge. Making
one means removing the background, cropping to the model, scaling it to the right
height and placing it -- four mechanical steps that are slow by hand and identical
every time, which is the whole of this script.

    python tools/make_bossportrait.py build shot.png LynTheIgnored
    python tools/make_bossportrait.py build shot.png LynTheIgnored --tolerance 40
    python tools/make_bossportrait.py build "<retail UI-EJ-BOSS art>.blp" TheButcher

It writes `images/UIEJBoss<Name>.png` and prints the line to paste into the
encounter. What it cannot do is produce the model: that still comes from the game,
through the addon's own model viewer (`/run AGC_NpcPreview(id)`), or from retail
art for a boss that already has some.

Shoot the model against a flat background of a colour the model does not contain --
the removal floods in from the edges, so it will not punch holes in the middle of a
creature that happens to share the backdrop's colour.

Needs Pillow; shares the BLP decoder with blp2png.py.

The format, measured from the 59 portraits already shipped and confirmed against
retail's own (also 128x64):

- the canvas is 128x64 and the model stands on the bottom edge
- it fills most of the height -- 60 of 64 on average -- and about 96 of 128 across
- it sits a little left of centre, at x 59 rather than 64
"""
import argparse
import glob
import os
import re
import sys
from collections import deque

from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from blp2png import read_blp  # noqa: E402

HERE = os.path.dirname(os.path.abspath(__file__))
AG_ROOT = os.path.dirname(HERE)

WIDTH, HEIGHT = 128, 64
# What the shipped portraits average, so a new one sits among them rather than
# looming over them or floating small.
TARGET_HEIGHT = 61
CENTRE_X = 59


def open_any(path):
    if path.lower().endswith(".blp"):
        im, description = read_blp(path)
        if im is None:
            sys.exit("cannot read %s: %s" % (path, description))
        return im.convert("RGBA")
    return Image.open(path).convert("RGBA")


def has_alpha(im):
    low, _ = im.split()[3].getextrema()
    return low < 250


def chroma_signature(key):
    """How strongly coloured the backdrop is: its highest channel minus its lowest.

    Magenta and green score around 255; any grey scores 0. It is what tells a
    backdrop chosen to be unmistakable from one that merely happens to be there.
    """
    high = [c for c in range(3) if key[c] >= 128]
    low = [c for c in range(3) if key[c] < 128]
    return (min(key[c] for c in high) - max(key[c] for c in low)
            if high and low else 0)


def drop_enclosed(im, key, tolerance):
    """Clear backdrop the flood cannot reach, where the backdrop is a chroma key.

    The flood only clears what joins the edge, so backdrop seen *through* a model
    survives: Marrowgar is a cage of bone and the gaps between his ribs came out
    filled with magenta, which no tolerance fixes because the pixels are correct
    and merely unreachable.

    Clearing them everywhere is safe only because of how the backdrop is chosen.
    The studio offers magenta and green precisely as colours the creature cannot
    contain -- that is the whole premise of the keyer -- so a pixel that still
    matches one is backdrop wherever it sits. A grey backdrop carries no such
    promise, which is why the flood alone handles those.
    """
    px = im.load()
    w, h = im.size
    cleared = 0
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if a == 0:
                continue
            if abs(r - key[0]) + abs(g - key[1]) + abs(b - key[2]) <= tolerance * 3:
                px[x, y] = (0, 0, 0, 0)
                cleared += 1
    return cleared


def drop_background(im, tolerance):
    """Clear the backdrop by flooding in from the edges.

    A flood rather than a colour match everywhere: a grey backdrop and a grey
    creature are common, and only the part connected to the edge is background.
    Where the backdrop is a chroma key, drop_enclosed then takes the parts the
    flood could not reach.
    """
    im = im.copy()
    px = im.load()
    w, h = im.size
    seeds = [(x, y) for x in range(w) for y in (0, h - 1)]
    seeds += [(x, y) for y in range(h) for x in (0, w - 1)]
    key = px[0, 0][:3]
    seen = bytearray(w * h)
    queue = deque()
    for x, y in seeds:
        if not seen[y * w + x]:
            seen[y * w + x] = 1
            queue.append((x, y))
    cleared = 0
    while queue:
        x, y = queue.popleft()
        r, g, b, _ = px[x, y]
        if abs(r - key[0]) + abs(g - key[1]) + abs(b - key[2]) > tolerance * 3:
            continue
        px[x, y] = (0, 0, 0, 0)
        cleared += 1
        for nx, ny in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
            if 0 <= nx < w and 0 <= ny < h and not seen[ny * w + nx]:
                seen[ny * w + nx] = 1
                queue.append((nx, ny))
    if chroma_signature(key) >= 60:
        cleared += drop_enclosed(im, key, tolerance)
    defringe(im, key, tolerance)
    return im, cleared


def erode(im, pixels):
    """Shave the outermost pixels of the matte.

    Unmixing recovers a soft edge but cannot rescue a pixel that is mostly
    backdrop, and those are what is left of a halo. Shaving them costs a sliver of
    silhouette at the source's resolution, which is far finer than the 64pt canvas
    this ends up on, and is the difference between a cut-out and a cut-out with a
    coloured rim around it.
    """
    if pixels < 1:
        return
    px = im.load()
    w, h = im.size
    for _ in range(pixels):
        doomed = [(x, y) for y in range(h) for x in range(w)
                  if px[x, y][3] != 0
                  and any(px[nx, ny][3] == 0
                          for nx, ny in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1))
                          if 0 <= nx < w and 0 <= ny < h)]
        for x, y in doomed:
            px[x, y] = (0, 0, 0, 0)


def defringe(im, key, tolerance, band=3):
    """Take the backdrop's colour back out of the edge pixels.

    An edge pixel is a blend of model and backdrop, so it survives the flood and
    keeps a rim of the backdrop's colour -- the green or magenta halo that makes a
    cut-out look cut out. Reading that blend as C = a*model + (1-a)*backdrop gives
    both the pixel's real alpha and its real colour.
    """
    px = im.load()
    w, h = im.size
    edge = []
    for y in range(h):
        for x in range(w):
            if px[x, y][3] != 0:
                continue
            for dy in range(-band, band + 1):
                for dx in range(-band, band + 1):
                    nx, ny = x + dx, y + dy
                    if 0 <= nx < w and 0 <= ny < h and px[nx, ny][3] == 255:
                        edge.append((nx, ny))
    # How much backdrop is in a pixel, by colour difference rather than by
    # distance from the backdrop's colour. Distance does not work: half a dark
    # model mixed into magenta still lands far from magenta, so the pixel reads as
    # pure model and keeps its rim. What separates them is the backdrop's shape --
    # magenta is high red and blue against low green -- and that gap shrinks in
    # proportion as model is mixed in.
    high = [c for c in range(3) if key[c] >= 128]
    low = [c for c in range(3) if key[c] < 128]
    signature = chroma_signature(key)
    reach = max(1.0, tolerance * 2.5)

    def backdrop_share(pixel):
        if signature >= 60:
            gap = min(pixel[c] for c in high) - max(pixel[c] for c in low)
            return max(0.0, min(1.0, gap / signature))
        # A backdrop with no colour of its own: distance is all there is.
        distance = max(abs(pixel[c] - key[c]) for c in range(3))
        return max(0.0, 1.0 - min(1.0, distance / reach))

    for x, y in set(edge):
        r, g, b, _ = px[x, y]
        alpha = 1.0 - backdrop_share((r, g, b))
        if alpha >= 0.995:
            continue
        if alpha <= 0.02:
            px[x, y] = (0, 0, 0, 0)
            continue
        unmixed = tuple(
            max(0, min(255, int((c - (1 - alpha) * k) / alpha)))
            for c, k in ((r, key[0]), (g, key[1]), (b, key[2])))
        px[x, y] = unmixed + (int(alpha * 255),)


def build(source, tolerance=32, target_height=TARGET_HEIGHT, centre_x=CENTRE_X,
          erode_px=None):
    im = open_any(source)
    if im.size == (WIDTH, HEIGHT) and has_alpha(im):
        return im, "already a portrait, copied as is"
    note = "used the source's own alpha"
    if not has_alpha(im):
        im, cleared = drop_background(im, tolerance)
        share = 100.0 * cleared / (im.width * im.height)
        note = "cleared %.0f%% as background" % share
        if share < 2:
            note += " -- looks wrong, try --tolerance higher"
        elif share > 97:
            note += " -- looks wrong, try --tolerance lower"
        box = im.split()[3].getbbox()
        if box:
            # One finished pixel's worth, so the shave is invisible once scaled.
            auto = max(1, min(6, round((box[3] - box[1]) / target_height)))
            erode(im, auto if erode_px is None else erode_px)
    box = im.split()[3].getbbox()
    if not box:
        sys.exit("nothing left after removing the background -- lower --tolerance")
    model = im.crop(box)

    scale = target_height / model.height
    if model.width * scale > WIDTH:
        scale = WIDTH / model.width
    model = model.resize((max(1, round(model.width * scale)),
                          max(1, round(model.height * scale))), Image.LANCZOS)

    out = Image.new("RGBA", (WIDTH, HEIGHT), (0, 0, 0, 0))
    x = round(centre_x - model.width / 2)
    x = max(0, min(WIDTH - model.width, x))
    out.alpha_composite(model, (x, HEIGHT - model.height))
    return out, note


def cmd_build(args):
    out, note = build(args.source, args.tolerance, args.height, args.centre_x,
                      args.erode)
    name = args.name
    for prefix in ("I.UIEJBoss", "UIEJBoss"):
        if name.startswith(prefix):
            name = name[len(prefix):]
    path = args.out or os.path.join(AG_ROOT, "images", "UIEJBoss%s.png" % name)
    print("  %s" % note)
    if args.dry_run:
        print("would write %s" % os.path.relpath(path, AG_ROOT))
        return
    out.save(path)
    print("%s  %dx%d" % (os.path.relpath(path, AG_ROOT).replace("\\", "/"),
                         out.width, out.height))
    print("    portrait = I.UIEJBoss%s," % name)


# The id every boss with no art of its own carries.
PLACEHOLDER = "521744"
ENCOUNTER_RE = re.compile(r'^\t\tname = "([^"]+)",(.*?)(?=^\t\tname = "|\Z)',
                          re.M | re.S)
PORTRAIT_RE = re.compile(r"^\t\tportrait = ([^,\r\n]+),", re.M)


def art_key(boss):
    """LynTheIgnored from "Lyn the Ignored"."""
    words = re.findall(r"[A-Za-z0-9]+", boss)
    return "".join(w[:1].upper() + w[1:] for w in words)


def normalise(text):
    return re.sub(r"[^a-z0-9]", "", text.lower())


def read_text(path):
    with open(path, newline="", encoding="utf-8") as fh:
        return fh.read()


def placeholder_bosses():
    """Every encounter still carrying the placeholder, in file order."""
    found = []
    pattern = os.path.join(AG_ROOT, "data", "*", "*", "*.lua")
    for path in sorted(glob.glob(pattern)):
        text = read_text(path)
        instance = re.search(r'^\tname = "([^"]+)"', text, re.M)
        if not instance:
            continue
        for match in ENCOUNTER_RE.finditer(text):
            portrait = PORTRAIT_RE.search(match.group(2))
            if portrait and portrait.group(1).strip() == PLACEHOLDER:
                found.append((path, instance.group(1), match.group(1)))
    return found


def cmd_worklist(args):
    found = placeholder_bosses()
    current = None
    for path, instance, boss in found:
        if instance != current:
            current = instance
            print("\n%s" % instance)
        if args.names:
            print("    %s.png" % boss)
        else:
            print("    %-28s -> images/UIEJBoss%s.png" % (boss, art_key(boss)))
    print("\n%d bosses still on the placeholder." % len(found))
    if not args.names:
        print("`worklist --names` prints just the filenames to shoot, one per line.")


def wire(path, boss, key):
    """Point one encounter's portrait at its new art, leaving the rest alone."""
    # Only the matched `portrait = ...,` is replaced, so every line ending in the
    # file survives untouched and none of this has to know what they are.
    text = read_text(path)
    for match in ENCOUNTER_RE.finditer(text):
        if match.group(1) != boss:
            continue
        body = match.group(2)
        portrait = PORTRAIT_RE.search(body)
        if not portrait:
            return False, "no portrait line"
        start = match.start(2) + portrait.start()
        end = match.start(2) + portrait.end()
        new = "\t\tportrait = I.UIEJBoss%s," % key
        text = text[:start] + new + text[end:]
        with open(path, "w", newline="", encoding="utf-8") as fh:
            fh.write(text)
        return True, None
    return False, "encounter not found"


def cmd_batch(args):
    wanted = {normalise(boss): (path, boss) for path, _, boss in placeholder_bosses()}
    sources = [p for p in sorted(glob.glob(os.path.join(args.folder, "*")))
               if p.lower().endswith((".png", ".jpg", ".jpeg", ".blp", ".tga"))]
    if not sources:
        sys.exit("no images in %s" % args.folder)

    done, unmatched = 0, []
    for source in sources:
        stem = os.path.splitext(os.path.basename(source))[0]
        hit = wanted.get(normalise(stem))
        if not hit:
            unmatched.append(stem)
            continue
        path, boss = hit
        key = art_key(boss)
        out, note = build(source, args.tolerance, args.height, args.centre_x,
                          args.erode)
        target = os.path.join(AG_ROOT, "images", "UIEJBoss%s.png" % key)
        if not args.dry_run:
            out.save(target)
        print("  %-28s -> UIEJBoss%s.png   (%s)" % (boss, key, note))
        if args.wire and not args.dry_run:
            ok, why = wire(path, boss, key)
            if not ok:
                print("      could not wire it up: %s" % why)
        done += 1

    print("\n%d portrait%s%s" % (done, "" if done == 1 else "s",
                                 " (dry run, nothing written)" if args.dry_run else ""))
    if args.wire and not args.dry_run:
        print("data files updated; the rest still carry the placeholder.")
    elif done:
        print("run again with --wire to point the data files at them.")
    if unmatched:
        print("\n%d file%s matched no boss still on the placeholder:"
              % (len(unmatched), "" if len(unmatched) == 1 else "s"))
        for stem in unmatched:
            print("    %s" % stem)
        print("Name each file after the boss -- `worklist --names` prints them.")


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(required=True)
    b = sub.add_parser("build", help="make images/UIEJBoss<Name>.png")
    b.add_argument("source", help="PNG, JPEG or BLP of the model")
    b.add_argument("name", help="boss name, no spaces, e.g. LynTheIgnored")
    b.add_argument("--tolerance", type=int, default=32,
                   help="how close to the corner colour still counts as background")
    b.add_argument("--height", type=int, default=TARGET_HEIGHT,
                   help="model height in the 64pt canvas (default %d)" % TARGET_HEIGHT)
    b.add_argument("--centre-x", type=int, default=CENTRE_X,
                   help="where the model centres (default %d)" % CENTRE_X)
    b.add_argument("--erode", type=int, default=None,
                   help="source pixels to shave off the edge; raise it if a rim of "
                        "the backdrop's colour survives (default: one output pixel)")
    b.add_argument("--out", help="write here instead of images/")
    b.add_argument("--dry-run", action="store_true")
    b.set_defaults(func=cmd_build)

    w = sub.add_parser("worklist", help="bosses still carrying the placeholder")
    w.add_argument("--names", action="store_true",
                   help="print just the filenames to shoot, one per line")
    w.set_defaults(func=cmd_worklist)

    t = sub.add_parser("batch", help="build every image in a folder at once")
    t.add_argument("folder", help="folder of exports, each named after its boss")
    t.add_argument("--wire", action="store_true",
                   help="also point the data files at the new art")
    t.add_argument("--tolerance", type=int, default=32)
    t.add_argument("--height", type=int, default=TARGET_HEIGHT)
    t.add_argument("--centre-x", type=int, default=CENTRE_X)
    t.add_argument("--erode", type=int, default=None)
    t.add_argument("--dry-run", action="store_true")
    t.set_defaults(func=cmd_batch)

    args = ap.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
