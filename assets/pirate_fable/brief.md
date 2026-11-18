# Brief: pirate

- Canvas 30x20 (30 wide, 20 high). Keep a 1 px margin: no colored pixel at x=0, x=29, y=0 or y=19.
- Subject: a pirate character, full body, side view facing RIGHT, standing.
  A tricorn hat, a beard, a long coat, a belt with a gold buckle.
  The right arm holds a cutlass (curved sword) pointing forward to the right.
  One leg is a wooden peg leg. The other leg wears a black boot.
- Use: a game sprite, for example an enemy or NPC in a 2D platformer. It must read as a pirate at 1x.
- Light from the top-left.
- Palette. Use exactly these names and colors, in this order, and no others:
    {"outline", "#1a1423"}, {"skin", "#e8b48a"}, {"skin_dk", "#b97a57"},
    {"coat", "#a8323e"}, {"coat_dk", "#6b1f33"}, {"black", "#2e2a3a"},
    {"wood", "#a0703c"}, {"wood_dk", "#6e4a2a"}, {"steel", "#b8c4d0"}, {"steel_hl", "#f0f4f8"},
    {"gold", "#f2c14e"}, {"beard", "#5a3a2a"}, {"shirt", "#ece4d0"}
- Layers: draw colors on one or more layers, then make a final layer "outline" with
  ol:outline("outline", {from = {<all color layers>}}). The script must end with `return s`.
