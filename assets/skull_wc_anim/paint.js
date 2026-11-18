// Brief: laughing skull, watercolor
// - Canvas 512x512. Medium: watercolor with light ink line work.
// - Subject: a human skull seen from the FRONT, laughing: the jaw dropped open, the teeth showing,
//   the eye sockets tilted as if squinting with laughter. Cheerful and a little mischievous, not horror.
// - Background: a loose, pale wash that frames the skull. It stays quieter than the skull.
// - Light from the top-left. Warm bone light (save the paper), cool violet or blue shadows in the sockets,
//   the nose cavity, under the cheekbones and inside the mouth.
// - Use: a card or icon in a cozy pirate game. It must read at 1/4 size.
// - Palette: limited, about 4 to 6 pigments.
export const meta = { w: 512, h: 512, seed: 7, paper: "#f6f0e1", frames: 8, duration: 100 }

// Pigments
const PAPER = "#f6f0e1"   // opaque base under the moving pieces, same as the paper
const OCHRE = "#d9a23f"   // warm bone, gold tooth
const SIENNA = "#4a2c26"  // ink line
const VIOLET = "#6a5a9c"  // cool shadow glaze
const INDIGO = "#2b2650"  // darks: sockets, nose, mouth
const TEAL = "#4d8a8f"    // background

const mx = (p) => [512 - p[0], p[1], p[2]]
const mirror = (pts) => pts.map(mx)

// Curves shared by the teeth, the mouth and the jaw
const gumY = (x) => 353 - 13 * ((x - 256) / 74) ** 2      // upper gum line
const mouthTopY = (x) => 376 - 14 * ((x - 256) / 64) ** 2 // bottom of the upper teeth
const mouthBotY = (x) => 420 - 14 * ((x - 256) / 60) ** 2 // top of the lower teeth
const jawInY = (x) => 444 - 20 * ((x - 256) / 66) ** 2    // bottom of the lower teeth

// Laugh cycle, one entry per frame (two "ha" per loop). A still uses the first pose.
const JAW_DY = [0, -10, -24, -12, -2, -12, -24, -10]
const BOB = [-4, -2, 0, -1, -4, -2, 0, -1]
const TILT = [1.5, 0.8, 0, 0.3, -1.5, -0.8, 0, -0.3]
const GLINT = [0, 0, 0, 0, 1, 0.5, 0, 0]

export default function draw(brush, W, H, ctx) {
  const anim = ctx.frames > 1, f = ctx.frame % 8
  const jawDy = anim ? JAW_DY[f] : 0, bob = anim ? BOB[f] : 0, tilt = anim ? TILT[f] : 0
  const glint = anim ? GLINT[f] : 0

  const shape = (pts, curv = 0.35) => {
    brush.beginShape(curv)
    for (const p of pts) brush.vertex(p[0], p[1])
    brush.endShape(true)
  }
  const wc = (color, op, bleed = 0.12, tex = 0.4, border = 0.45) => {
    brush.noWash()
    brush.noStroke()
    brush.fill(color, op)
    brush.fillBleed(bleed, "out")
    brush.fillTexture(tex, border)
  }
  const glaze = (name, op, pts, bleed = 0.15, curv = 0.35, border = 0.3) => {
    ctx.part(name)
    wc(VIOLET, op, bleed, 0.3, border)
    shape(pts, curv)
  }
  const dark = (pts, curv, passes = 2) => {
    for (let i = 0; i < passes; i++) {
      wc(i ? INDIGO : VIOLET, 235, 0.05, 0.35, 0.5)
      shape(pts, curv)
    }
  }
  // opaque paper: hides what lies behind a moving piece
  const base = (pts, curv) => {
    brush.noStroke()
    brush.noFill()
    brush.wash(PAPER, 255)
    if (curv === undefined) brush.polygon(pts)
    else shape(pts, curv)
    brush.noWash()
  }
  const ink = (pts, weight = 1, curv = 0.5, name = "pen") => {
    brush.noFill()
    brush.noWash()
    brush.set(name, SIENNA, weight * 2.2)
    brush.spline(pts, curv)
  }

  // Silhouette of skull + dropped jaw, right half from the crown to the chin:
  // cranium, temple dip, cheekbone, jaw hinge, jaw
  const SR = [[256, 52], [310, 60], [356, 88], [386, 130], [396, 178], [388, 218], [373, 246], [377, 262],
    [391, 279], [388, 298], [374, 314], [369, 328], [364, 372], [352, 408], [316, 450], [256, 474]]
  const SIL = SR.concat(mirror(SR.slice(1, 15)).reverse())
  const CX = 256, CY = 264
  const silR = (th) => {
    const dx = Math.cos(th), dy = Math.sin(th)
    let best = 0
    for (let i = 0; i < SIL.length; i++) {
      const a = SIL[i], b = SIL[(i + 1) % SIL.length]
      const ex = b[0] - a[0], ey = b[1] - a[1], den = dx * ey - dy * ex
      if (Math.abs(den) < 1e-9) continue
      const ax = a[0] - CX, ay = a[1] - CY
      const t = (ax * ey - ay * ex) / den, s = (ax * dy - ay * dx) / den
      if (t > 0 && s >= 0 && s <= 1) best = Math.max(best, t)
    }
    return best
  }

  // ---- background: two large soft washes around the skull, tapering at their ends ----
  const cWash = (name, a0, a1, op, R, ph) => {
    ctx.part(name)
    const inner = [], outer = []
    for (let u = 0; u <= 1.0001; u += 1 / 48) {
      const th = (a0 + (a1 - a0) * u) * Math.PI / 180
      const r0 = silR(th) + 11
      const taper = Math.sin(Math.PI * Math.min(1, u)) ** 0.6
      const Rout = Math.max(r0 + 22, R + 20 * Math.sin(2 * th + ph) + 9 * Math.sin(5 * th + 2 * ph))
      const r1 = r0 + (Rout - r0) * taper
      inner.push([CX + Math.cos(th) * r0, CY + Math.sin(th) * r0])
      outer.push([CX + Math.cos(th) * r1, CY + Math.sin(th) * r1])
    }
    wc(TEAL, op, 0.2, 0.35, 0.06)
    brush.polygon(inner.concat(outer.reverse()))
  }
  cWash("bg_a", 95, 335, 58, 244, 0.6)   // lower left, left, top
  cWash("bg_b", 295, 515, 62, 226, 2.1)  // top right, right, bottom
  brush.noFill()

  // ---- mouth cavity: drawn behind, the upper teeth and the jaw cover its edges ----
  ctx.part("mouth")
  const cav = []
  for (let x = 190; x <= 322; x += 16.5) cav.push([x, mouthTopY(x) - 10])
  cav.push([334, 366], [335, 398])
  for (let x = 318; x >= 194; x -= 15.5) cav.push([x, mouthBotY(x) + 9])
  cav.push([177, 398], [178, 366])
  dark(cav, 0.2, 3)
  ctx.part("mouth_deep")
  wc(INDIGO, 230, 0.15, 0.3, 0.1)
  shape([[192, 366], [224, 376], [256, 380], [288, 376], [320, 366], [318, 388], [256, 396], [196, 388]], 0.4)
  brush.noFill()

  // ================= jaw: moves as one piece =================
  brush.push()
  brush.translate(0, jawDy)

  const JAW = [[150, 320], [148, 372], [160, 415], [196, 460], [256, 486], [316, 460], [352, 415], [364, 372],
    [362, 320], [338, 328], [336, 372], [322, jawInY(322) + 2], [290, jawInY(290) + 2], [256, 446],
    [222, jawInY(222) + 2], [190, jawInY(190) + 2], [176, 372], [174, 328]]
  const JB = [[150, 320], [148, 372], [160, 415], [196, 460], [256, 486], [316, 460], [352, 415], [364, 372],
    [362, 320], [338, 328], [336, 372], [331, 398]]
  for (let x = 318; x >= 194; x -= 15.5) JB.push([x, mouthBotY(x)])
  JB.push([181, 398], [176, 372], [174, 328])
  base(JB, 0.25)

  ctx.part("jawbone")
  wc(OCHRE, 38, 0.08, 0.3, 0.3)
  shape(JAW, 0.25)

  glaze("shade_jaw", 125, [[340, 328], [362, 322], [364, 372], [352, 415], [316, 460], [256, 486], [214, 474],
    [256, 466], [302, 448], [334, 410], [342, 372]], 0.15, 0.3)
  glaze("shade_jaw_l", 50, [[150, 320], [174, 328], [175, 352], [149, 350]], 0.15, 0.3)
  brush.noFill()

  ctx.part("ink_jaw")
  ink([[362, 317, 0.6], [369, 327, 1], [364, 342, 1], [364, 372, 1.2], [352, 415, 1.3], [316, 460, 1.3],
    [256, 486, 1.2], [214, 476, 0.8]], 1.1)
  ink([[150, 317, 0.5], [143, 327, 0.8], [148, 342, 0.8], [148, 372, 1], [160, 415, 1], [196, 460, 0.9],
    [226, 476, 0.5]], 0.9)
  ctx.part("ink_teeth_low")
  const bot = [], low = []
  for (let x = 196; x <= 316; x += 20) bot.push([x, mouthBotY(x), 1])
  for (let x = 192; x <= 320; x += 16) low.push([x, jawInY(x), 0.7])
  ink(bot, 0.9); ink(low, 0.6)
  for (const x of [196, 214, 235, 256, 277, 298, 316]) {
    brush.set("pen", SIENNA, 1.4)
    brush.line(x, mouthBotY(x), x, jawInY(x) - 1)
  }
  brush.noStroke()
  brush.pop()

  // ================= cranium: bobs and tilts as one piece =================
  brush.push()
  brush.translate(256, 340 + bob)
  brush.rotate(tilt)
  brush.translate(-256, -340)

  const CR = [[256, 52], [310, 60], [356, 88], [386, 130], [396, 178], [388, 218], [373, 246], [377, 262],
    [391, 279], [388, 298], [374, 314], [346, 326], [331, 340], [327, 360]]
  const CRAN = CR.slice()
  for (let x = 322; x >= 190; x -= 16.5) CRAN.push([x, mouthTopY(x) + 1])
  CRAN.push(...mirror(CR.slice(1)).reverse())
  base(CRAN)

  // ---- bone: pale warm wash, the top-left forehead stays paper ----
  ctx.part("bone")
  wc(OCHRE, 34, 0.18, 0.3, 0.12)
  shape([[300, 62], [356, 90], [386, 130], [395, 178], [387, 218], [372, 246], [376, 262], [389, 279],
    [386, 298], [372, 314], [346, 326], [330, 340], [292, 350], [256, 353], [220, 350], [182, 340],
    [166, 326], [140, 314], [126, 298], [124, 279], [137, 263], [152, 256], [196, 238], [226, 200],
    [262, 128]], 0.3)

  // ---- cool shadow glazes, on the side away from the light ----
  glaze("shade_cranium", 88, [[318, 64], [358, 92], [387, 132], [396, 178], [388, 218], [373, 246], [350, 252],
    [338, 200], [332, 130]], 0.25, 0.4, 0.15)
  glaze("shade_cranium_core", 140, [[346, 84], [386, 131], [396, 178], [388, 218], [371, 244], [361, 236],
    [373, 180], [364, 130]], 0.25, 0.4, 0.2)
  glaze("shade_temple_r", 90, [[360, 222], [387, 219], [373, 246], [377, 262], [356, 258]], 0.15, 0.4)
  glaze("shade_temple_l", 45, [[152, 222], [125, 219], [139, 246], [135, 262], [156, 258]], 0.15, 0.4)
  glaze("shade_lower", 62, [[292, 300], [300, 256], [340, 252], [376, 262], [389, 280], [386, 298], [372, 314],
    [346, 326], [330, 340], [298, 350], [284, 330]], 0.3, 0.4, 0.05)
  glaze("shade_cheek_r", 150, [[316, 302], [350, 294], [385, 292], [386, 300], [373, 314], [346, 327],
    [330, 341], [314, 334]], 0.12, 0.3)
  glaze("shade_cheek_l", 88, [[196, 302], [162, 294], [127, 292], [126, 300], [139, 314], [166, 327],
    [182, 341], [198, 334]], 0.12, 0.3)
  glaze("shade_brow", 55, [[236, 232], [256, 222], [276, 232], [272, 268], [256, 262], [240, 268]], 0.3, 0.4, 0.1)

  // ---- darks: deep sockets (squinting), nose ----
  const SOCK = [[145, 252], [147, 226], [167, 201], [198, 190], [227, 200], [241, 226], [241, 250],
    [226, 256], [200, 244], [174, 249], [156, 262]]
  const SOCK_DEEP = [[152, 243], [154, 224], [171, 205], [198, 196], [224, 205], [235, 226], [234, 240],
    [216, 231], [196, 229], [172, 236]]
  const GL = [[180, 214, 4.6], [189, 223, 2]]
  const socket = (name, flip) => {
    const m = (pts) => (flip ? mirror(pts).reverse() : pts)
    ctx.part(name)
    dark(m(SOCK), 0.45)
    wc(INDIGO, 240, 0.08, 0.3, 0.2)
    shape(m(SOCK_DEEP), 0.45)
    shape(m(SOCK_DEEP), 0.45)
    // glint: paper showing through, on the light side of both sockets
    brush.noFill()
    brush.wash(PAPER, 255)
    for (const g of GL) {
      const o = []
      for (let a = 0; a < 12; a++) o.push([g[0] + (flip ? 122 : 0) + g[2] * Math.cos(a * Math.PI / 6), g[1] + g[2] * Math.sin(a * Math.PI / 6)])
      brush.polygon(o)
    }
    brush.noWash()
  }
  socket("socket_l", false)
  socket("socket_r", true)

  ctx.part("nose")
  dark([[256, 268], [240, 298], [235, 320], [246, 329], [256, 320], [266, 329], [277, 320], [272, 298]], 0.4, 3)

  // ---- gold tooth: the one saturated warm accent ----
  ctx.part("goldtooth")
  wc(OCHRE, 190, 0.03, 0.3, 0.6)
  brush.polygon([[283, gumY(283) + 1], [303, gumY(303) + 1], [303, mouthTopY(303) - 1], [283, mouthTopY(283) - 1]])
  brush.noFill()
  if (glint > 0) {
    const gx = 290, gy = 357, r = 11 * glint
    brush.wash(PAPER, 255)
    brush.polygon([[gx, gy - r], [gx + 1.6, gy - 1.6], [gx + r, gy], [gx + 1.6, gy + 1.6], [gx, gy + r],
      [gx - 1.6, gy + 1.6], [gx - r, gy], [gx - 1.6, gy - 1.6]])
    brush.noWash()
  }

  // ---- ink: heavier on the shadow side ----
  ctx.part("ink_outline")
  ink([[262, 53, 0.6], [310, 60, 1], [356, 88, 1.2], [386, 130, 1.3], [396, 178, 1.3], [388, 218, 1.2],
    [373, 246, 1], [377, 262, 1], [391, 279, 1.2], [388, 298, 1.2], [374, 314, 1.1], [346, 326, 0.9],
    [331, 340, 0.6]], 1.1)
  ink([[250, 53, 0.6], [202, 60, 0.9], [156, 88, 1], [126, 130, 0.9], [116, 178, 0.9], [124, 218, 1],
    [139, 246, 0.9], [135, 262, 0.9], [121, 279, 1], [124, 298, 1], [138, 314, 1], [166, 326, 0.9],
    [181, 339, 0.6]], 0.95)

  ctx.part("ink_face")
  // brows: the squint
  const BROW = [[144, 254, 0.5], [146, 226, 1], [167, 199, 1.2], [198, 188, 1.2], [228, 198, 1], [242, 226, 0.6]]
  ink(BROW, 1)
  ink(mirror(BROW), 1)
  // cheeks pushed up under the eyes
  const LID = [[158, 264, 0.4], [174, 250, 0.8], [200, 244, 0.9], [226, 256, 0.7], [241, 252, 0.4]]
  ink(LID, 0.7)
  ink(mirror(LID), 0.7)
  // nose
  ink([[256, 266, 0.5], [273, 298, 0.9], [278, 321, 0.9], [266, 330, 0.6]], 0.7)
  // suture crack on the brow
  ink([[296, 62, 0.5], [290, 82, 0.8], [300, 98, 0.6], [291, 116, 0.8], [297, 134, 0.3]], 0.6, 0.1)
  // cheekbone ridges
  ink([[388, 282, 0.5], [364, 282, 0.8], [340, 291, 0.4]], 0.6)
  ink([[124, 282, 0.4], [148, 282, 0.7], [172, 291, 0.3]], 0.6)

  ctx.part("ink_teeth")
  const gum = [], top = []
  for (let x = 186; x <= 326; x += 20) gum.push([x, gumY(x), 0.8])
  for (let x = 190; x <= 322; x += 22) top.push([x, mouthTopY(x), 1])
  ink(gum, 0.6); ink(top, 0.9)
  for (const x of [190, 208, 230, 256, 282, 304, 322]) {
    brush.set("pen", SIENNA, x === 256 ? 1.8 : 1.4)
    brush.line(x, gumY(x) + 1, x, mouthTopY(x))
  }
  brush.noStroke()
  brush.pop()
}
