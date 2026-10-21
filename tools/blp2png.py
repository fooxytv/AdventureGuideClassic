#!/usr/bin/env python3
"""Convert Blizzard BLP textures to PNG, so a sheet can be measured before it is used.

The client reads PNG, so conversion is not needed to ship art -- it is needed to look
at it. Picking tex coords for an Atlas.lua entry means knowing where a piece sits on
its sheet, and that cannot be done without seeing the pixels.

    python tools/blp2png.py <file.blp|directory> [-o OUTDIR] [-r] [--info]

--info prints format and dimensions without writing anything, which is usually all
that is wanted when deciding whether a texture is worth shipping at all. It reads
only the 148-byte header, so a sweep over a whole art directory decodes nothing.

Handles BLP2, which is what the interface art is: palettised, DXT1/3/5, or raw BGRA.
BLP1 is reported rather than guessed at; nothing in the UI art set uses it.
"""
import argparse
import struct
import sys
from pathlib import Path

try:
    from PIL import Image
except ImportError:
    sys.exit("Pillow is required: pip install pillow")

ENCODING_PALETTE, ENCODING_DXT, ENCODING_ARGB = 1, 2, 3
DXT1, DXT3, DXT5 = 0, 1, 7


def _rgb565(value):
    r = (value >> 11) & 0x1F
    g = (value >> 5) & 0x3F
    b = value & 0x1F
    return ((r << 3) | (r >> 2), (g << 2) | (g >> 4), (b << 3) | (b >> 2))


def _colour_block(data, offset, opaque):
    """The 8-byte colour half shared by DXT1, DXT3 and DXT5."""
    c0, c1 = struct.unpack_from("<HH", data, offset)
    a, b = _rgb565(c0), _rgb565(c1)
    # c0 > c1 selects the four-colour mode. DXT3 and DXT5 always use it, whatever the
    # endpoints say, because their alpha lives in the other half of the block.
    if c0 > c1 or opaque:
        palette = [
            a, b,
            tuple((2 * a[i] + b[i]) // 3 for i in range(3)),
            tuple((a[i] + 2 * b[i]) // 3 for i in range(3)),
        ]
        alpha = [255, 255, 255, 255]
    else:
        palette = [a, b, tuple((a[i] + b[i]) // 2 for i in range(3)), (0, 0, 0)]
        alpha = [255, 255, 255, 0]
    bits = struct.unpack_from("<I", data, offset + 4)[0]
    return palette, alpha, bits


def _decode_dxt(data, width, height, flavour):
    out = bytearray(width * height * 4)
    block_stride = 8 if flavour == DXT1 else 16
    offset = 0
    for by in range(0, height, 4):
        for bx in range(0, width, 4):
            alphas = None
            if flavour == DXT3:
                raw = struct.unpack_from("<Q", data, offset)[0]
                alphas = [((raw >> (4 * i)) & 0xF) * 17 for i in range(16)]
            elif flavour == DXT5:
                a0, a1 = data[offset], data[offset + 1]
                if a0 > a1:
                    table = [a0, a1] + [((7 - i) * a0 + i * a1) // 7 for i in range(1, 7)]
                else:
                    table = [a0, a1] + [((5 - i) * a0 + i * a1) // 5 for i in range(1, 5)]
                    table += [0, 255]
                bits = int.from_bytes(data[offset + 2:offset + 8], "little")
                alphas = [table[(bits >> (3 * i)) & 0x7] for i in range(16)]

            colour_at = offset + (0 if flavour == DXT1 else 8)
            palette, alpha, bits = _colour_block(data, colour_at, flavour != DXT1)

            for i in range(16):
                px, py = bx + (i % 4), by + (i // 4)
                if px >= width or py >= height:
                    continue
                code = (bits >> (2 * i)) & 0x3
                r, g, b = palette[code]
                a = alphas[i] if alphas is not None else alpha[code]
                at = (py * width + px) * 4
                out[at:at + 4] = bytes((r, g, b, a))
            offset += block_stride
    return bytes(out)


def _decode_palette(data, palette, width, height, alpha_depth):
    count = width * height
    out = bytearray(count * 4)
    for i in range(count):
        b, g, r, _ = palette[data[i] * 4:data[i] * 4 + 4]
        out[i * 4:i * 4 + 3] = bytes((r, g, b))

    base = count
    if alpha_depth == 0:
        for i in range(count):
            out[i * 4 + 3] = 255
    elif alpha_depth == 1:
        for i in range(count):
            bit = (data[base + (i >> 3)] >> (i & 7)) & 1
            out[i * 4 + 3] = 255 if bit else 0
    elif alpha_depth == 4:
        for i in range(count):
            nibble = data[base + (i >> 1)]
            value = (nibble & 0xF) if i % 2 == 0 else (nibble >> 4)
            out[i * 4 + 3] = value * 17
    elif alpha_depth == 8:
        for i in range(count):
            out[i * 4 + 3] = data[base + i]
    else:
        raise ValueError("unsupported alpha depth %d" % alpha_depth)
    return bytes(out)


HEADER_BYTES = 148


def _header(head):
    """Returns (fields or None, description). None means nothing here can be decoded.

    Everything --info reports lives in these first 148 bytes, so this does no pixel
    work and needs no more of the file than that.
    """
    magic = head[:4]
    if magic == b"BLP1":
        return None, "BLP1 (not supported; nothing in the UI art set uses it)"
    if magic != b"BLP2":
        return None, "not a BLP file"

    _type, encoding, alpha_depth, alpha_encoding, _has_mips = struct.unpack_from(
        "<IBBBB", head, 4)
    width, height = struct.unpack_from("<II", head, 12)

    if encoding == ENCODING_PALETTE:
        kind = "palettised, alpha %d" % alpha_depth
    elif encoding == ENCODING_DXT:
        if alpha_encoding not in (DXT1, DXT3, DXT5):
            return None, "unknown DXT flavour %d" % alpha_encoding
        kind = {DXT1: "DXT1", DXT3: "DXT3", DXT5: "DXT5"}[alpha_encoding]
    elif encoding == ENCODING_ARGB:
        kind = "raw BGRA"
    else:
        return None, "unknown encoding %d" % encoding

    fields = (encoding, alpha_depth, alpha_encoding, width, height)
    return fields, "%dx%d %s" % (width, height, kind)


def describe_blp(path):
    """Returns (readable, description) from the header alone -- what --info needs.

    Reading the pixels to report a size would be wasted work on a directory sweep,
    and it would turn a file with a sound header and truncated data into an error
    when its format and size are perfectly reportable.
    """
    with open(path, "rb") as handle:
        head = handle.read(HEADER_BYTES)
    fields, description = _header(head)
    return fields is not None, description


def read_blp(path):
    """Returns (PIL image or None, description). The image is None if unsupported."""
    raw = Path(path).read_bytes()
    fields, description = _header(raw[:HEADER_BYTES])
    if fields is None:
        return None, description
    encoding, alpha_depth, alpha_encoding, width, height = fields

    offsets = struct.unpack_from("<16I", raw, 20)
    sizes = struct.unpack_from("<16I", raw, 84)
    body = raw[offsets[0]:offsets[0] + sizes[0]]
    if len(body) < sizes[0]:
        return None, "%s, truncated: %d of %d pixel bytes" % (
            description, len(body), sizes[0])

    if encoding == ENCODING_PALETTE:
        palette = raw[HEADER_BYTES:HEADER_BYTES + 1024]
        pixels = _decode_palette(body, palette, width, height, alpha_depth)
    elif encoding == ENCODING_DXT:
        pixels = _decode_dxt(body, width, height, alpha_encoding)
    else:
        pixels = bytearray(len(body))
        for i in range(0, len(body) - 3, 4):
            b, g, r, a = body[i:i + 4]
            pixels[i:i + 4] = bytes((r, g, b, a))
        pixels = bytes(pixels)

    return Image.frombytes("RGBA", (width, height), pixels), description


def main():
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("source", help="a .blp file or a directory of them")
    parser.add_argument("-o", "--outdir", help="where the PNGs go (default: alongside)")
    parser.add_argument("-r", "--recursive", action="store_true")
    parser.add_argument("--info", action="store_true",
                        help="report format and size, write nothing")
    args = parser.parse_args()

    source = Path(args.source)
    if source.is_dir():
        files = sorted(source.rglob("*.blp") if args.recursive else source.glob("*.blp"))
    else:
        files = [source]
    if not files:
        sys.exit("no .blp files found in %s" % source)

    failed = 0
    for path in files:
        try:
            if args.info:
                readable, description = describe_blp(path)
            else:
                image, description = read_blp(path)
                readable = image is not None
        except Exception as error:                       # noqa: BLE001
            print("%-50s ERROR %s" % (path.name, error))
            failed += 1
            continue
        if not readable:
            print("%-50s %s" % (path.name, description))
            failed += 1
            continue
        if args.info:
            print("%-50s %s" % (path.name, description))
            continue
        outdir = Path(args.outdir) if args.outdir else path.parent
        outdir.mkdir(parents=True, exist_ok=True)
        target = outdir / (path.stem + ".png")
        image.save(target)
        print("%-50s %s -> %s" % (path.name, description, target))

    if failed:
        print("\n%d of %d could not be read" % (failed, len(files)))
    return 1 if failed == len(files) else 0


if __name__ == "__main__":
    sys.exit(main())
