# Brief: cat

- Canvas 20x20. Keep a 1 px margin: no colored pixel at x=0, x=19, y=0 or y=19 (the outline needs room).
- Subject: an orange tabby cat, sitting, side view facing RIGHT. Tail curls around the front feet.
  Pointed ears, a visible eye, a white muzzle and chest, 2 or 3 darker tabby stripes on the back.
- Use: a game sprite, for example a pet or NPC in a cozy RPG. It must read as a cat at 1x.
- Light from the top-left.
- Palette. Use exactly these names and colors, in this order, and no others:
    {"outline", "#2b1b18"}, {"dk", "#a14f2b"}, {"mid", "#e0812f"}, {"lt", "#f4b45e"},
    {"hl", "#fce3a8"}, {"white", "#f4f4f4"}, {"eye", "#7ec850"}, {"pink", "#e88a9a"}
- Layers: draw colors on one or more layers, then make a final layer "outline" with
  ol:outline("outline", {from = {<all color layers>}}). The script must end with `return s`.
