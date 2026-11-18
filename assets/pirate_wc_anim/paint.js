// Brief: pirate, watercolor
// - Canvas 384x512 (portrait). Watercolor with light ink line work, like a storybook illustration.
// - Subject: a pirate character, full body, standing, three-quarter view facing RIGHT.
//   A tricorn hat, a beard, a long red coat, a belt with a gold buckle, a cutlass held forward,
//   one wooden peg leg and one black boot.
// - Background: a light, loose suggestion of a ship deck, sea and sky. Quieter than the figure.
// - Light from the top-left. Warm light, cool shadows.
// - Use: character card art for a cozy pirate game. It must read at 1/4 size.
// - Palette (7 pigments): cadmium red, ochre, burnt sienna, indigo, sky blue, violet (shadow glaze), skin.
export const meta = { w: 384, h: 512, seed: 7, paper: "#f4efe2", frames: 8, duration: 140 }

const RED = "#c23a2b"
const DEEP = "#8e2226"
const OCHRE = "#d9a23a"
const SIENNA = "#a4572a"
const INDIGO = "#27324d"
const SKY = "#86b3cf"
const VIOLET = "#55508c"
const SKIN = "#e3a57c"
const INK = "#33262a"

export default function draw(brush, W, H, ctx) {
  // ---------- motion (all zero in a still: ctx.t is 0) ----------
  const TAU = 2 * Math.PI * ctx.t
  const breath = -(1 - Math.cos(TAU))        // 0 .. -2 px, torso and head rise
  const sway = Math.sin(TAU)                 // -1 .. 1, wind
  const drift = Math.sin(TAU - 1) + Math.sin(1) // slow background drift, 0 at t = 0
  const clamp = (v) => Math.max(0, Math.min(1, v))
  // Rigid moves only: a fill whose outline deforms gets a new texture (flicker), a translated one does not.
  const F = ([x, y]) => [x, y + breath]                         // upper body: breath
  const TL = ([x, y]) => [x - sway * 3, y + breath - sway]      // coat tail flap: wind
  const BT = ([x, y]) => [x - sway * 1.8, y + breath]           // beard tip: wind
  const B = F
  const S = (dx, dy = 0) => ([x, y]) => [x + dx, y + dy]
  const ID = (p) => p

  const wc = (color, op, bleed = 0.06, tex = 0.35, border = 0.35) => {
    brush.noWash()
    brush.noStroke()
    brush.fill(color, op)
    brush.fillBleed(bleed, "out")
    brush.fillTexture(tex, border)
  }
  const flat = (color, op = 255) => { brush.noFill(); brush.noStroke(); brush.wash(color, op) }
  const shape = (pts, curv = 0.25, M = ID) => {
    brush.beginShape(curv)
    for (const p of pts) { const q = M(p); brush.vertex(q[0], q[1]) }
    brush.endShape(true)
  }
  const fig = (pts, curv = 0.25) => shape(pts, curv, F)
  const ink = (pts, w = 0.8, curv = 0.5, M = F, name = "pen", color = INK) => {
    brush.noFill(); brush.noWash()
    brush.set(name, color, w * 2)
    brush.spline(pts.map(M), curv)
  }
  const box = (x, y, w, h) => [[x, y], [x + w, y], [x + w, y + h], [x, y + h]]
  const disc = (x, y, r) => { const o = []; for (let i = 0; i < 8; i++) o.push([x + r * Math.cos(i * Math.PI / 4), y + r * Math.sin(i * Math.PI / 4)]); return o }

  // ---------- background: pale and loose ----------
  ctx.part("sky")
  wc(SKY, 46, 0.35, 0.5, 0.15)
  shape([[-10, -10], [250, -10], [300, 40], [235, 120], [120, 150], [60, 250], [-10, 290]], 0.6, S(drift * 4))
  ctx.part("sky2")
  wc(SKY, 54, 0.3, 0.5, 0.1)
  shape([[268, 120], [330, 96], [394, 108], [394, 320], [262, 322], [282, 230]], 0.6, S(-drift * 3))

  ctx.part("sea")
  wc("#5f95ad", 68, 0.12, 0.5, 0.2)
  const seaM = S(sway * 3, Math.cos(TAU) - 1)
  shape([[-14, 330], [50, 326], [106, 331], [102, 364], [50, 366], [-14, 366]], 0.3, seaM)
  shape([[238, 333], [300, 329], [398, 332], [398, 366], [300, 368], [238, 366]], 0.3, seaM)
  brush.noFill()
  brush.set("2H", "#4d7f97", 1.6)
  brush.spline([[14, 344], [26, 341], [38, 344], [50, 341]].map(S(-sway * 4)), 0.5)
  brush.spline([[300, 348], [312, 345], [324, 348], [338, 345]].map(S(-sway * 4)), 0.5)
  brush.spline([[262, 340], [272, 338], [282, 340]].map(S(sway * 2)), 0.5)

  ctx.part("gunwale")
  wc(SIENNA, 46, 0.1, 0.5, 0.2)
  shape([[-10, 368], [394, 364], [394, 408], [-10, 410]], 0.05)
  wc(SIENNA, 60, 0.05, 0.4, 0.3)
  shape([[-10, 362], [394, 358], [394, 369], [-10, 373]], 0.05) // cap rail
  brush.noFill()
  brush.set("2H", "#6b5a4a", 1.8)
  brush.line(0, 362, 100, 361)
  brush.line(240, 359, 384, 358)
  brush.line(0, 373, 96, 372)
  brush.line(244, 370, 384, 369)
  for (const x of [34, 84, 268, 322, 366]) brush.line(x, 374, x, 404)

  ctx.part("deck")
  wc(OCHRE, 28, 0.2, 0.5, 0.15)
  shape([[-10, 408], [394, 404], [394, 522], [-10, 522]], 0.1)
  brush.noFill()
  brush.set("2H", "#6b5a4a", 1.8)
  brush.line(0, 409, 132, 408)
  brush.line(262, 405, 384, 404)
  brush.line(0, 432, 128, 431)
  brush.line(290, 430, 384, 429)
  brush.line(110, 456, 136, 456)
  brush.line(0, 492, 150, 491)
  brush.line(322, 500, 384, 499)
  brush.line(100, 432, 100, 456)
  brush.line(330, 430, 330, 462)
  brush.line(40, 492, 40, 512)
  brush.line(250, 498, 250, 512)

  ctx.part("rope")
  wc(OCHRE, 90, 0.05, 0.4, 0.4)
  shape([[30, 452], [44, 442], [66, 440], [86, 446], [92, 456], [80, 466], [56, 468], [36, 462]], 0.6)
  wc(VIOLET, 50, 0.1, 0.2, 0.1)
  shape([[44, 462], [70, 466], [92, 458], [104, 464], [84, 474], [52, 472]], 0.5)
  brush.noFill()
  brush.set("HB", "#7a5a34", 1.6)
  brush.spline([[32, 453], [46, 443], [66, 441], [86, 447], [90, 456], [78, 465], [56, 467], [36, 461], [32, 453]], 0.6)
  brush.spline([[42, 453], [52, 447], [68, 446], [80, 451], [80, 457], [70, 461], [54, 461], [44, 458]], 0.6)
  brush.spline([[54, 453], [62, 451], [70, 453], [66, 456], [58, 456]], 0.6)
  brush.spline([[88, 458], [100, 464], [112, 462]], 0.5)

  ctx.part("shadow")
  wc(VIOLET, 105, 0.1, 0.3, 0.1)
  shape([[138, 465], [200, 462], [258, 466], [326, 478], [348, 490], [300, 499], [214, 492], [152, 479]], 0.5)

  ctx.part("gull")
  brush.noFill()
  brush.set("2H", "#6b5a4a", 1.6)
  brush.spline([[60, 96], [68, 90], [74, 96], [81, 89], [90, 94]].map(S(drift * 2)), 0.5)

  // ---------- figure ----------
  // far arm: held back for balance, behind the body, cooler and darker
  ctx.part("fararm")
  const farArm = [[162, 160], [150, 168], [129, 204], [119, 240], [133, 245], [143, 214], [164, 186]]
  wc(DEEP, 240, 0.03, 0.3, 0.3)
  fig(farArm, 0.3)
  wc(SKIN, 190, 0.03, 0.2, 0.3)
  fig(disc(124, 250, 7), 0.6)
  wc(VIOLET, 185, 0.04, 0.2, 0.15)
  fig([[162, 160], [150, 168], [129, 204], [119, 240], [117, 252], [124, 258], [132, 253], [133, 245], [143, 214], [164, 186]], 0.3)

  // coat: warm light red, a second layer leaves the lit back edge lighter
  ctx.part("coat")
  const coat = [
    [200, 150], [172, 151], [157, 164], [150, 204], [147, 258], [141, 300], [130, 340], [122, 372],
    [128, 378], [170, 383], [224, 378], [225, 320], [224, 272], [217, 256], [213, 200], [210, 162],
  ]
  wc(RED, 228, 0.03, 0.3, 0.35)
  fig(coat, 0.2)
  fig([[200, 152], [176, 154], [166, 168], [160, 206], [157, 260], [152, 302], [142, 346], [134, 372],
    [170, 381], [223, 377], [224, 320], [223, 272], [216, 256], [212, 200], [209, 163]], 0.2)

  ctx.part("tail")
  wc(RED, 228, 0.03, 0.3, 0.35)
  shape([[150, 288], [139, 304], [121, 344], [104, 367], [128, 377], [158, 381], [160, 300]], 0.2, TL)

  ctx.part("skin")
  wc(SKIN, 190, 0.03, 0.2, 0.3)
  fig([[180, 104], [216, 104], [219, 116], [228, 126], [220, 131], [218, 140], [182, 140]], 0.3)
  fig(disc(268, 206, 8), 0.6)

  // legs stay planted: no transform
  ctx.part("peg")
  const peg = [[146, 398], [172, 398], [168, 416], [165, 418], [151, 468], [142, 468], [153, 418], [149, 416]]
  wc(OCHRE, 230, 0.03, 0.4, 0.4)
  shape(peg, 0.05)
  wc(SIENNA, 190, 0.02, 0.4, 0.4)
  shape([[154, 398], [172, 398], [168, 416], [165, 418], [151, 468], [145, 468], [157, 418], [155, 416]], 0.05)
  wc(INDIGO, 170, 0.02, 0.3, 0.3)
  shape([[163, 398], [172, 398], [168, 416], [165, 418], [151, 468], [148, 468], [161, 418], [162, 416]], 0.05)

  ctx.part("hilt")
  wc(OCHRE, 245, 0.02, 0.2, 0.4)
  fig([[258, 196], [276, 190], [282, 204], [266, 218], [258, 214]], 0.4)

  // blade: masked back to paper (like masking fluid), a cool wash on the belly half
  ctx.part("blade")
  const bladeBack = [[274, 196], [302, 172], [328, 142], [350, 116]]
  const bladeBelly = [[352, 132], [340, 160], [314, 190], [284, 212]]
  flat(meta.paper)
  fig([...bladeBack, ...bladeBelly], 0.4)
  wc("#6f9dbd", 175, 0.02, 0.2, 0.35)
  fig([[280, 206], [310, 184], [336, 154], [350, 124], ...bladeBelly], 0.4)
  // glint: travels from the hilt to the tip once per loop (animation only)
  if (ctx.frames > 1 && ctx.frame >= 1 && ctx.frame <= 6) {
    const c = [[283, 203], [311, 180], [336, 151], [350, 127]]
    const u = ((ctx.frame - 1) / 5) * 2.999
    const i = Math.floor(u), f = u - i
    const gx = c[i][0] + (c[i + 1][0] - c[i][0]) * f, gy = c[i][1] + (c[i + 1][1] - c[i][1]) * f
    const dx = c[i + 1][0] - c[i][0], dy = c[i + 1][1] - c[i][1], L = Math.hypot(dx, dy)
    const ux = dx / L, uy = dy / L
    flat("#fffdf6")
    fig([[gx - ux * 8, gy - uy * 8], [gx - uy * 3.5, gy + ux * 3.5], [gx + ux * 8, gy + uy * 8], [gx + uy * 3.5, gy - ux * 3.5]], 0.3)
  }

  // ---------- mid values ----------
  ctx.part("beard")
  wc(SIENNA, 235, 0.04, 0.4, 0.3)
  shape([[176, 118], [186, 130], [204, 131], [222, 130], [229, 142], [226, 166], [210, 188], [194, 182], [181, 164], [172, 140]], 0.4, B)

  ctx.part("beard-tip")
  wc(SIENNA, 150, 0.04, 0.4, 0.3)
  shape([[196, 158], [227, 158], [225, 170], [210, 189], [194, 183]], 0.4, BT)

  ctx.part("coat-shade")
  wc(DEEP, 215, 0.06, 0.3, 0.2)
  fig([[192, 160], [210, 162], [213, 200], [217, 256], [224, 272], [225, 320], [224, 378], [184, 382], [188, 320], [186, 262], [178, 215]], 0.25)
  // inside of the flared tail
  ctx.part("tail-shade")
  wc(DEEP, 150, 0.05, 0.3, 0.2)
  shape([[140, 318], [150, 330], [146, 378], [128, 377], [112, 370]], 0.3, TL)

  ctx.part("sleeve")
  const sleeve = [[166, 160], [190, 158], [222, 208], [252, 196], [258, 216], [216, 236], [200, 232], [170, 190]]
  wc(RED, 235, 0.02, 0.3, 0.3)
  fig(sleeve, 0.3)
  wc(DEEP, 225, 0.03, 0.3, 0.3)
  fig([[170, 184], [198, 216], [218, 222], [254, 206], [258, 216], [216, 236], [200, 232], [170, 190]], 0.3)
  ctx.part("cuff")
  wc(OCHRE, 240, 0.02, 0.2, 0.4)
  fig([[244, 192], [256, 190], [262, 218], [250, 222]], 0.2)

  ctx.part("breeches")
  wc(INDIGO, 220, 0.03, 0.3, 0.3)
  for (let i = 0; i < 2; i++) {
    shape([[146, 377], [174, 378], [172, 400], [146, 400]], 0.1)
    shape([[186, 378], [221, 377], [221, 400], [188, 400]], 0.1)
  }

  // ---------- darks ----------
  ctx.part("hat")
  const hat = [[136, 104], [150, 88], [168, 86], [172, 66], [190, 57], [210, 64], [216, 84], [238, 90], [254, 102], [226, 108], [190, 109], [160, 109]]
  wc(INDIGO, 240, 0.03, 0.4, 0.4)
  for (let i = 0; i < 3; i++) fig(hat, 0.3)
  ctx.part("hair")
  wc(SIENNA, 240, 0.03, 0.4, 0.3)
  fig([[172, 108], [182, 108], [182, 128], [174, 146], [166, 140]], 0.4)
  ctx.part("belt")
  wc(SIENNA, 250, 0.02, 0.3, 0.3)
  fig([[146, 257], [196, 259], [196, 270], [145, 270]], 0.05)
  wc(INDIGO, 200, 0.02, 0.3, 0.3)
  fig([[146, 257], [196, 259], [196, 270], [145, 270]], 0.05)
  fig([[214, 259], [219, 260], [223, 271], [214, 270]], 0.05)
  ctx.part("boot")
  wc(INDIGO, 245, 0.02, 0.35, 0.4)
  for (let i = 0; i < 4; i++) shape([[187, 398], [223, 396], [220, 438], [230, 452], [252, 458], [255, 469], [195, 469], [194, 440]], 0.15)

  // cool shadow glazes (light from top-left)
  ctx.part("glaze")
  wc(VIOLET, 185, 0.08, 0.2, 0.1)
  fig([[205, 166], [210, 162], [213, 200], [217, 256], [224, 272], [225, 320], [224, 378], [202, 381], [207, 300], [204, 240]], 0.3) // coat front (right) side
  fig([[178, 200], [200, 234], [214, 238], [216, 257], [186, 258]], 0.3) // cast by the sword arm
  wc(INDIGO, 150, 0.03, 0.2, 0.25)
  fig([[182, 106], [218, 106], [220, 117], [184, 118]], 0.2) // under the hat brim
  brush.noFill()

  // buckle and brass buttons: opaque body colour first, then a gold wash
  ctx.part("buckle")
  flat("#e9bb4c")
  fig(box(195, 253, 20, 20), 0.02)
  for (const y of [292, 314, 336, 358]) fig(disc(216, y, 3.2), 0.6)
  wc(OCHRE, 190, 0.01, 0.2, 0.5)
  fig(box(195, 253, 20, 20), 0.02)
  flat(INK)
  fig(box(202, 259, 6, 8), 0.02)
  brush.noWash()

  // ---------- ink line: selective, hardest at the face and the blade ----------
  ctx.part("ink")
  ink([[136, 104], [150, 88], [168, 86], [172, 66], [190, 57], [210, 64], [216, 84], [238, 90], [254, 102]], 0.9, 0.5)
  ink([[254, 102], [226, 108], [190, 109], [160, 109], [136, 104]], 0.8, 0.4)
  ink([[150, 92], [170, 90], [214, 89], [240, 95]], 1.25, 0.5, F, "pen", OCHRE)
  // face
  ink([[216, 106], [219, 116], [228, 126], [220, 131]], 1.0, 0.4)
  ink([[202, 114], [212, 112.5]], 1.4, 0.3) // brow
  ink([[207.5, 119], [210.5, 119.5]], 1.6, 0.3) // eye
  ink([[204, 136], [214, 133], [224, 137]], 0.8, 0.5, B) // moustache
  ink([[229, 142], [227, 160]], 0.7, 0.5, B) // beard edge
  ink([[227, 160], [225, 170], [210, 189], [194, 183]], 0.7, 0.5, BT)
  ink([[200, 152], [204, 170]], 0.5, 0.5, BT)
  ink([[212, 150], [214, 172]], 0.5, 0.5, BT)
  // far arm
  ink([[150, 168], [129, 204], [119, 240]], 0.5, 0.4)
  ink([[118, 246], [118, 254], [125, 258], [131, 252]], 0.5, 0.5)
  // coat
  ink([[172, 151], [157, 164], [150, 204], [147, 258], [141, 298]], 0.6, 0.4)
  ink([[141, 298], [121, 344], [104, 367]], 0.6, 0.4, TL)
  ink([[104, 367], [128, 377], [158, 381]], 0.7, 0.4, TL)
  ink([[158, 382], [170, 383], [224, 378]], 0.7, 0.4)
  ink([[210, 190], [213, 200], [217, 256]], 0.6, 0.3)
  ink([[224, 272], [225, 320], [224, 378]], 0.8, 0.3)
  ink([[150, 300], [140, 330], [146, 376]], 0.4, 0.5, TL) // folds
  ink([[166, 292], [160, 372]], 0.4, 0.4)
  ink([[192, 285], [190, 374]], 0.4, 0.4)
  // sleeve
  ink([[190, 158], [222, 208], [246, 198]], 0.8, 0.4)
  ink([[170, 190], [200, 232], [216, 236], [250, 221]], 0.8, 0.4)
  ink([[244, 192], [256, 190], [262, 218], [250, 222], [244, 192]], 0.7, 0.2)
  // hand and hilt
  ink([[262, 200], [272, 198], [277, 206], [270, 214], [262, 212]], 0.8, 0.5)
  ink([[258, 196], [276, 190], [282, 204], [266, 218]], 0.8, 0.5)
  // blade: the crispest lines
  ink(bladeBack, 1.1, 0.5)
  ink([[350, 116], ...bladeBelly], 1.0, 0.5)
  // buckle and buttons
  ink([...box(195, 253, 20, 20), [195, 253]], 0.8, 0.02)
  for (const y of [292, 314, 336, 358]) ink([[213.5, y + 2.5], [216.5, y + 3.6], [219.4, y + 1.5]], 0.6, 0.5)
  // legs
  ink([[146, 398], [172, 398], [168, 416], [149, 416], [146, 398]], 0.7, 0.1, ID)
  ink([[153, 418], [142, 468], [151, 468], [165, 418]], 0.7, 0.1, ID)
  ink([[187, 398], [223, 396]], 0.8, 0.2, ID)
  ink([[220, 438], [230, 452], [252, 458], [255, 469], [195, 469]], 0.8, 0.3, ID)
}
