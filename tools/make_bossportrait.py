"""Build an Encounter Journal boss portrait from a picture of the model.

The journal draws a boss as a 128x64 cut-out standing on the bottom edge. Making
one means removing the background, cropping to the model, scaling it to the right
height and placing it -- four mechanical steps that are slow by hand and identical
every time, which is the whole of this script.

    python tools/make_bossportrait.py build shot.png LynTheIgnored
    python tools/make_bossportrait.py build shot.png LynTheIgnored --tolerance 40
    python tools/make_bossportrait.py build "<retail UI-EJ-BOSS art>.blp" TheButcher
    python tools/make_bossportrait.py build shot.png Boss --crop 1596,813,648,309

`--crop` is the rectangle the portrait studio prints beside each shot, and it is
the guide box the studio drew on screen. Pass it. Everything below crops to the
outline of whatever is not backdrop, so without it a shot framed perfectly inside
the box is still cut to the whole creature: measured on one plate, 18% of the
result was solid pixels cropped to the creature and 36% cropped to the box, and
the shipped and retail portraits sit at 34-55%. The difference is entirely legs
and the lit ground under them.

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

from PIL import Image, ImageFilter

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from blp2png import read_blp  # noqa: E402

HERE = os.path.dirname(os.path.abspath(__file__))
AG_ROOT = os.path.dirname(HERE)

WIDTH, HEIGHT = 128, 64
# What the shipped portraits average, so a new one sits among them rather than
# looming over them or floating small.
TARGET_HEIGHT = 61
CENTRE_X = 59

# The drop shadow, recovered from the 64 portraits that already ship rather than
# guessed. Modelling each as opacity * blur(shift(silhouette)) and fitting the
# four numbers gives the same answer on every one of them: four pixels to the
# right, no vertical offset, a Gaussian of three, at full strength, in black.
#
# It is what lifts a cut-out off the panel behind it, and the reason the art made
# in Photoshop reads as placed rather than pasted. Retail's own portraits have no
# shadow at all, so art taken from there needs one adding to sit with ours --
# which is why this is on by default rather than a flag to remember.
SHADOW_OFFSET = (4, 0)
SHADOW_RADIUS = 3.0
SHADOW_OPACITY = 1.0
SHADOW_COLOUR = (0, 0, 0)


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


def drop_background(im, tolerance, key=None):
    """Clear the backdrop by flooding in from the edges.

    A flood rather than a colour match everywhere: a grey backdrop and a grey
    creature are common, and only the part connected to the edge is background.
    Where the backdrop is a chroma key, drop_enclosed then takes the parts the
    flood could not reach.

    `key` is the backdrop's colour. It defaults to the top-left pixel, which is
    backdrop in any shot framed with room around the creature -- but a --crop
    deliberately has none, and a creature covering that corner made the whole
    thing run backwards: the model keyed out and the magenta kept. So a caller
    that crops reads the colour off the plate first and passes it in.
    """
    im = im.copy()
    px = im.load()
    w, h = im.size
    seeds = [(x, y) for x in range(w) for y in (0, h - 1)]
    seeds += [(x, y) for y in range(h) for x in (0, w - 1)]
    key = tuple(key)[:3] if key else px[0, 0][:3]
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


def add_shadow(im, offset=SHADOW_OFFSET, radius=SHADOW_RADIUS,
               opacity=SHADOW_OPACITY):
    """Lay a blurred copy of the silhouette under the model.

    Blurred on a padded canvas and cropped back, so the shadow does not fade
    towards the edges of a model that reaches them -- blurring in place treats
    everything outside the canvas as empty and eats the edge.

    Running this on art that already carries a shadow doubles it. Nothing detects
    that, because a shadow is indistinguishable from dark pixels that belong to
    the creature; rebuild from the source rather than from `images/`.
    """
    width, height = im.size
    pad = int(radius * 3) + max(abs(offset[0]), abs(offset[1])) + 2
    canvas = Image.new("L", (width + pad * 2, height + pad * 2), 0)
    canvas.paste(im.getchannel("A"), (pad + offset[0], pad + offset[1]))
    canvas = canvas.filter(ImageFilter.GaussianBlur(radius))
    mask = canvas.crop((pad, pad, pad + width, pad + height))
    if opacity != 1.0:
        mask = mask.point(lambda v: int(max(0, min(255, v * opacity))))
    shadow = Image.new("RGBA", (width, height), SHADOW_COLOUR + (0,))
    shadow.putalpha(mask)
    return Image.alpha_composite(shadow, im)


def parse_crop(text):
    """`x,y,w,h` as the portrait studio prints it, in screenshot pixels."""
    if not text:
        return None
    parts = [p.strip() for p in text.replace(" ", "").split(",")]
    if len(parts) != 4 or not all(p.lstrip("-").isdigit() for p in parts):
        sys.exit("--crop wants four numbers, x,y,w,h -- got %r" % text)
    x, y, w, h = (int(p) for p in parts)
    if w <= 0 or h <= 0:
        sys.exit("--crop width and height must be positive")
    return (x, y, x + w, y + h)


def build(source, tolerance=32, target_height=TARGET_HEIGHT, centre_x=CENTRE_X,
          erode_px=None, shadow=True, crop=None):
    im = open_any(source)
    key = None
    if crop:
        # The guide box, as the studio measured it on screen. Taking it before
        # anything else is the whole point: the steps below crop to the outline
        # of what is left, so whatever is still in the picture -- the legs, and
        # the lit ground they stand on -- is what the 61pt height gets spent on.
        # The backdrop's colour is read off the full plate first, because a good
        # crop may well have no backdrop in any of its corners.
        key = im.convert("RGB").getpixel((0, 0))
        im = im.crop(crop)
    if im.size == (WIDTH, HEIGHT) and has_alpha(im):
        if shadow:
            return add_shadow(im), "already a portrait, shadow added"
        return im, "already a portrait, copied as is"
    note = "used the source's own alpha"
    if not has_alpha(im):
        im, cleared = drop_background(im, tolerance, key)
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
    if shadow:
        out = add_shadow(out)
        note += ", with shadow"
    return out, note


def cmd_build(args):
    out, note = build(args.source, args.tolerance, args.height, args.centre_x,
                      args.erode, not args.no_shadow, parse_crop(args.crop))
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


#--------------------------------------------------------------------------
# Checking a finished portrait.
#
# Three things have gone wrong in practice and none of them is visible at
# 128x64 on a dark panel, which is why they are measured rather than looked at:
#
#   * backdrop left in the picture. A creature covering the plate's top-left
#     corner once inverted the key entirely and the result -- solid magenta with
#     bone fragments in it -- scored *better* on coverage than the real thing,
#     because the magenta counted as creature.
#   * too little of the creature. Below about 25% of its own box a model stops
#     reading as itself and becomes scattered specks.
#   * art behind the boss name. The row draws the 128x64 at TOPLEFT (-4, 13)
#     and the name at LEFT 105, so x 109 onwards is under the first letters.
#--------------------------------------------------------------------------

NAME_STARTS_AT = 109
THIN = 25.0


def check(path, key):
    im = open_any(path)
    alpha = im.getchannel("A")
    box = alpha.getbbox()
    if not box:
        return ["%s: nothing in it at all" % os.path.basename(path)]

    values = list(alpha.get_flattened_data())
    solid = sum(1 for v in values if v >= 200)
    fill = 100.0 * solid / ((box[2] - box[0]) * (box[3] - box[1]))

    # Only pixels that are actually drawn can be leftover backdrop; the shadow
    # is black at low alpha and would otherwise read as a near miss on green.
    left = 0
    if key:
        for r, g, b, a in im.get_flattened_data():
            if a >= 32 and abs(r - key[0]) + abs(g - key[1]) + abs(b - key[2]) <= 150:
                left += 1

    strip = list(alpha.crop((NAME_STARTS_AT, 0, WIDTH, HEIGHT)).get_flattened_data())
    under = 100.0 * sum(1 for v in strip if v >= 32) / len(strip)

    lines = ["%s  %dx%d, filling %.1f%% of its box" % (
        os.path.basename(path), im.width, im.height, fill)]
    if fill < THIN:
        lines.append("  [warn] thin -- shipped art runs 34-55% and retail's own "
                     "34-37%; frame tighter on the creature, or accept it for "
                     "something as full of gaps as a spider")
    if key and left:
        lines.append("  [warn] %d pixels still match the backdrop %s -- raise "
                     "--tolerance, or shoot against the other colour if the "
                     "creature shares it" % (left, key))
    if under > 12:
        lines.append("  [warn] %.0f%% of the strip behind the boss name is drawn; "
                     "lower --height to narrow it, then --centre-x to move it "
                     "left" % under)
    if len(lines) == 1:
        lines.append("  nothing to report")
    return lines


def cmd_check(args):
    key = None
    if args.key:
        parts = args.key.split(",")
        if len(parts) != 3 or not all(p.strip().isdigit() for p in parts):
            sys.exit("--key wants three numbers, r,g,b")
        key = tuple(int(p) for p in parts)
    for path in args.portraits:
        for line in check(path, key):
            print(line)


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
                          args.erode, not args.no_shadow)
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
    b.add_argument("--crop", metavar="X,Y,W,H",
                   help="keep only this rectangle of the source; the portrait "
                        "studio prints the guide box in this form beside each shot")
    b.add_argument("--tolerance", type=int, default=32,
                   help="how close to the corner colour still counts as background")
    b.add_argument("--height", type=int, default=TARGET_HEIGHT,
                   help="model height in the 64pt canvas (default %d)" % TARGET_HEIGHT)
    b.add_argument("--centre-x", type=int, default=CENTRE_X,
                   help="where the model centres (default %d)" % CENTRE_X)
    b.add_argument("--erode", type=int, default=None,
                   help="source pixels to shave off the edge; raise it if a rim of "
                        "the backdrop's colour survives (default: one output pixel)")
    b.add_argument("--no-shadow", action="store_true",
                   help="skip the drop shadow the shipped portraits all carry")
    b.add_argument("--out", help="write here instead of images/")
    b.add_argument("--dry-run", action="store_true")
    b.set_defaults(func=cmd_build)

    c = sub.add_parser("check", help="measure a finished portrait")
    c.add_argument("portraits", nargs="+", help="images/UIEJBoss<Name>.png")
    c.add_argument("--key", metavar="R,G,B",
                   help="the backdrop it was shot against, so leftovers of it "
                        "can be counted -- 242,0,242 for magenta, 0,242,0 for green")
    c.set_defaults(func=cmd_check)

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
    t.add_argument("--no-shadow", action="store_true")
    t.add_argument("--dry-run", action="store_true")
    t.set_defaults(func=cmd_batch)

    args = ap.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
