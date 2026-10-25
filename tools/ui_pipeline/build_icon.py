"""Builds the game icon: assets/icon/icon.png (256, for Godot) and assets/icon/halfaciv.ico (Windows).

Hand-specified pixel art in the manner of mid-90s 4X program icons (dark outline, light top-left /
dark bottom-right bevel, few flat colours, a single readable motif): an isometric block of land with
a blue-roofed cottage and a banner, the village of the game. Two masters are drawn by hand, 16x16 and
32x32; every other size is a whole-number nearest-neighbour enlargement of one of them, never a
reduction or fractional resample. No third-party icon art is used.

    python tools/ui_pipeline/build_icon.py
"""
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "tools" / "python_libs"))
from PIL import Image  # noqa: E402

OUT = ROOT / "assets" / "icon"

COLOURS = {
    "k": (13, 20, 22),       # outline
    "l": (138, 186, 92),     # grass, lit edge
    "g": (86, 132, 60),      # grass
    "G": (52, 92, 42),       # grass, shade
    "d": (156, 118, 72),     # earth, left face
    "D": (102, 72, 44),      # earth, right face
    "w": (70, 122, 160),     # water
    "W": (128, 176, 204),    # water glint
    "H": (126, 160, 222),    # roof, lit
    "r": (62, 99, 166),      # roof
    "R": (38, 62, 116),      # roof, shade
    "b": (196, 134, 82),     # wall, lit
    "B": (130, 82, 48),      # wall, shade
    "y": (240, 204, 104),    # window light / finial
    "f": (200, 64, 52),      # banner
    "F": (132, 36, 34),      # banner, shade
    "s": (206, 210, 204),    # pole
}

ICON_32 = [
    "................................",
    "......kk........................",
    "......ksk.......................",
    "......kskkkkkk..................",
    "......ksffffffk.................",
    "......ksfffffFk.......kk........",
    "......ksffffFFk......kyyk.......",
    "......kskkkkkk......kHHrRk......",
    "......ksk..........kHHrrrRk.....",
    "......ksk.........kHHrrrrrRk....",
    "......ksk........kHHrrrrrrrRk...",
    "......ksk.......kHHrrrrrrrrrRk..",
    "......ksk......kkkkkkkkkkkkkkkk.",
    "......ksk.......kbbbbbbbbBBBBk..",
    "......ksk.......kbbkkkbbbBkkBk..",
    "......ksk.....kkkbbkykbbbBkkBk..",
    "......ksk...kklkbbkkkbbbBkkBkk..",
    "....kkkskkkllggkbbbbbbbbBkkBkGkk",
    "..kklllllllgggggkkkkkkkkkkkkkGGk",
    "kklllggggggggggggggggggggwwwwwGk",
    "kgggggggggggggggggggggwwwwWwwwGk",
    "kddkgggggggggggggggggwwWwwwwwGkk",
    "kddddkkgggggggggggggwwwwwwwGkDDk",
    "kddddddkkggggggggggggwwwwGGkDDDk",
    ".kkddddddkkggggggggggggGGkkDDDk.",
    "...kkddddddkkgggggggggGkkDDDkk..",
    ".....kkddddddkkgggggGkkDDDDk....",
    ".......kkddddddkkgGGkkDDDkk.....",
    ".........kkddddddkkkDDDDk.......",
    "...........kkddddddDDDkk........",
    ".............kkkkkkkkk..........",
    "................................",
]

ICON_16 = [
    "...k............",
    "...ksk..........",
    "...ksffk...kk...",
    "...ksfFk..kHrk..",
    "...kskk..kHrrRk.",
    "...ksk..kkkkkkkk",
    "...ksk...kbykBk.",
    "..kkskk..kbbkBk.",
    ".kllgggkkkkkkkGk",
    "klgggggggggwwwGk",
    "kdkggggggggwWGkk",
    "kddkkggggggwGkDk",
    ".kdddkkgggGkkDk.",
    "...kdddkkkkDDk..",
    ".....kkkkkkk....",
    "................",
]


def draw(rows):
    size = len(rows)
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    for y, row in enumerate(rows):
        assert len(row) == size, (size, y, row)
        for x, ch in enumerate(row):
            if ch != ".":
                img.putpixel((x, y), COLOURS[ch] + (255,))
    return img


def enlarge(img, factor):
    return img.resize((img.width * factor, img.height * factor), Image.NEAREST)


def frames():
    small, large = draw(ICON_16), draw(ICON_32)
    return {16: small, 32: large, 48: enlarge(small, 3), 64: enlarge(large, 2), 128: enlarge(large, 4), 256: enlarge(large, 8)}


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    sizes = frames()
    for size, img in sizes.items():
        if size in (16, 32):
            img.save(OUT / f"icon_{size}.png")
    sizes[256].save(OUT / "icon.png")
    order = sorted(sizes)
    sizes[order[-1]].save(OUT / "halfaciv.ico", format="ICO", sizes=[(s, s) for s in order], append_images=[sizes[s] for s in order[:-1]])
    print(f"ICON_OK sizes={order} in {OUT}")


if __name__ == "__main__":
    main()
