#!/usr/bin/env python3
"""Build the black chess pieces by palette swap, and a board preview of the full set.

Usage: .venv/bin/python tools/chess_set.py [pieces_dir]
pieces_dir holds the chess_<piece> folders. Default: assets.
Output: <pieces_dir>/chess_set/board.png, and <pieces_dir>/chess_<piece>_black/sprite.lua + PNG.
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from PIL import Image, ImageDraw  # noqa: E402

from pixelaite import ASSETS as DEFAULT_ASSETS, composite, run_script  # noqa: E402

PIECES = ["rook", "knight", "bishop", "queen", "king", "bishop", "knight", "rook"]
KINDS = ["king", "queen", "rook", "bishop", "knight", "pawn"]

# White hex -> black hex. The outline stays the same.
SWAP = {
    "#8b9bb4": "#1b1f33",  # dk
    "#c0cbdc": "#3a4466",  # mid
    "#e4ebf2": "#5a6988",  # lt
    "#ffffff": "#8b9bb4",  # hl
}
SQUARE_LIGHT = (222, 206, 170, 255)
SQUARE_DARK = (152, 112, 82, 255)


ASSETS = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else DEFAULT_ASSETS


def render(kind, black):
    src = ASSETS / f"chess_{kind}" / "sprite.lua"
    if not black:
        return composite(run_script(src))[0]
    text = src.read_text()
    for a, b in SWAP.items():
        text = text.replace(f'"{a}"', f'"{b}"')
    out_dir = ASSETS / f"chess_{kind}_black"
    out_dir.mkdir(exist_ok=True)
    (out_dir / "sprite.lua").write_text(text)
    img = composite(run_script(out_dir / "sprite.lua"))[0]
    img.save(out_dir / f"chess_{kind}_black.png")
    return img


def main():
    white = {k: render(k, False) for k in KINDS}
    black = {k: render(k, True) for k in KINDS}
    rows = [
        [black[p] for p in PIECES],
        [black["pawn"]] * 8,
        [None] * 8,
        [None] * 8,
        [white["pawn"]] * 8,
        [white[p] for p in PIECES],
    ]
    # Board at 1x: 8 columns, 6 rows of 16 px squares.
    board = Image.new("RGBA", (8 * 16, len(rows) * 16))
    d = ImageDraw.Draw(board)
    for r, row in enumerate(rows):
        for c, piece in enumerate(row):
            color = SQUARE_LIGHT if (r + c) % 2 == 0 else SQUARE_DARK
            d.rectangle([c * 16, r * 16, c * 16 + 15, r * 16 + 15], fill=color)
            if piece:
                board.alpha_composite(piece, (c * 16, r * 16))
    # Sheet: the board at 6x, plus 1x and 2x copies to the right.
    scale = 6
    big = board.resize((board.width * scale, board.height * scale), Image.NEAREST)
    pad = 16
    sheet = Image.new("RGBA", (big.width + board.width * 2 + pad * 3, big.height + pad * 2), (48, 48, 56, 255))
    sheet.alpha_composite(big, (pad, pad))
    sheet.alpha_composite(board, (big.width + pad * 2, pad))
    sheet.alpha_composite(board.resize((board.width * 2, board.height * 2), Image.NEAREST),
                          (big.width + pad * 2, pad + board.height + pad))
    out = ASSETS / "chess_set"
    out.mkdir(exist_ok=True)
    board.save(out / "board_1x.png")
    sheet.save(out / "board.png")
    print(out / "board.png")


if __name__ == "__main__":
    main()
