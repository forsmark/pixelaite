// Brief: steampunk fish, watercolor
// - Canvas 512x384 (landscape). Watercolor with light ink line work.
// - A mechanical steampunk fish in side view, facing left. Riveted brass and copper body, round porthole eye,
//   two meshing gears set into its side, a small exhaust vent on its back, fins and tail of thin metal plates.
// - Background: a loose, pale underwater wash with a few bubbles. Quieter than the fish.
// - Light from the top-left. Warm brass highlights (saved paper), cool blue-green shadows on the belly and
//   the lower right. Verdigris accents on the copper.
// - Use: a card or icon in a cozy pirate game. It must read at 1/4 size.
// - Palette: brass, copper, verdigris, shadow teal, pale sea wash, sepia ink.
export const meta = { w: 512, h: 384, seed: 7, paper: "#f4efe2", frames: 10, duration: 95 }

const PAPER = "#f4efe2"
const BRASS = "#e2ae42"
const BRASS_D = "#c07f28"
const COPPER = "#b4502a"
const VERD = "#4fa58c"
const SHADOW = "#27566a"
const SEA = "#8fc2c0"
const INK = "#2b1d18"

export default function draw(brush, W, H, ctx) {
  const TAU = 2 * Math.PI
  const s1 = Math.sin(TAU * ctx.t)

  // ---- motion: everything is a function of ctx.t, so the loop closes ----
  // Loop: 10 frames. Tail wags as two linked pieces. Gear A (12 teeth, 3 holes) turns 120 degrees per loop,
  // gear B (8 teeth, 4 holes) turns 180 degrees the other way: 4 tooth pitches each, so they stay meshed
  // and each gear maps onto itself at the loop point. Four steam puffs, a quarter of a loop apart.
  const bob = 1.5 * Math.sin(TAU * ctx.t + 0.6)
  const tailA = 7 * s1                                  // inner tail link, degrees
  const fanA = 9 * Math.sin(TAU * ctx.t - 0.9)          // outer fan lags behind
  const turn = ctx.t                                    // 0..1 over the loop
  const steamT = ctx.t

  // ---- helpers ----
  const wc = (color, op, bleed = 0.15, tex = 0.4, border = 0.5) => {
    brush.noStroke(); brush.noWash()
    brush.fill(color, op); brush.fillBleed(bleed, "out"); brush.fillTexture(tex, border)
  }
  const shape = (pts, curv = 0) => {
    brush.beginShape(curv)
    for (const p of pts) brush.vertex(p[0], p[1])
    brush.endShape(true)
  }
  const mask = (pts, curv = 0) => {         // masking fluid: keeps the paper under a part
    brush.noStroke(); brush.noFill(); brush.wash(PAPER, 255)
    shape(pts, curv)
    brush.noWash()
  }
  const ink = (w = 1, name = "pen") => { brush.noFill(); brush.noWash(); brush.set(name, INK, w * 1.9) }
  const dot = (x, y, r, color = INK, op = 235) => {   // small flat dark: tiny watercolor fills dry too pale
    brush.noStroke(); brush.noFill(); brush.wash(color, op)
    brush.polygon(circPts(x, y, r, 10)); brush.noWash()
  }
  const rivet = (x, y) => dot(x, y, 1.5, INK, 215)
  const circPts = (cx, cy, r, n = 28) =>
    Array.from({ length: n }, (_, i) => [cx + r * Math.cos(TAU * i / n), cy + r * Math.sin(TAU * i / n)])

  // ---- background (still) ----
  ctx.part("bg")
  wc(SEA, 55, 0.35, 0.5, 0.2)
  shape([[30, 120], [200, 40], [420, 20], [505, 110], [500, 360], [300, 378], [60, 370], [10, 250]], 0.6)
  ctx.part("bg-deep")
  wc(SHADOW, 70, 0.4, 0.5, 0.2)
  shape([[230, 300], [400, 250], [505, 200], [506, 375], [260, 380]], 0.6)
  ctx.part("bg-weed")
  wc(VERD, 75, 0.3, 0.5, 0.3)
  shape([[20, 384], [34, 320], [28, 270], [46, 300], [52, 250], [66, 310], [80, 384]], 0.5)
  brush.noFill()

  ctx.part("bubbles")
  const bubbles = [[52, 150, 7], [38, 110, 4], [66, 84, 9], [50, 46, 5], [452, 70, 6], [470, 40, 4], [140, 330, 5], [120, 300, 3]]
  for (const [x, y, r] of bubbles) {
    wc(SHADOW, 60, 0.05, 0.2, 0.8); shape(circPts(x, y, r).filter(q => q[0] - x + q[1] - y > -r * 0.5))
    ink(0.55); brush.circle(x, y, r, 0.1)
  }
  brush.noFill()

  // ---- the fish: everything bobs together ----
  brush.push()
  brush.translate(0, bob)

  // -- tail: inner link and outer fan, each around its own pivot --
  const TP = [384, 195]
  brush.push()
  brush.translate(TP[0], TP[1]); brush.rotate(tailA)
  // outer fan
  brush.push()
  brush.translate(30, 0); brush.rotate(fanA)
  const upper = [[0, -7], [38, -56], [76, -74], [68, -32], [32, -5]]
  const lower = [[0, 7], [32, 5], [68, 32], [76, 74], [38, 56]]
  const mid = [[4, -6], [54, -15], [64, 0], [54, 15], [4, 6]]
  mask(upper); mask(lower); mask(mid)
  ctx.part("tail-upper"); wc(BRASS_D, 150, 0.08, 0.4, 0.6); shape(upper)
  ctx.part("tail-lower"); wc(COPPER, 175, 0.08, 0.4, 0.6); shape(lower)
  ctx.part("tail-lower-sh"); wc(SHADOW, 130, 0.1, 0.3, 0.3); shape([[30, 12], [66, 34], [76, 74], [40, 56]])
  ctx.part("tail-mid"); wc(VERD, 160, 0.08, 0.5, 0.6); shape(mid)
  ctx.part("tail-ink")
  ink(1)
  brush.spline([[0, -7], [38, -56], [76, -74], [68, -32], [32, -5]], 0.15)
  brush.spline([[0, 7], [38, 56], [76, 74], [68, 32], [32, 5]], 0.15)
  brush.spline([[4, -6], [54, -15], [64, 0], [54, 15], [4, 6]], 0.2)
  ink(0.6)
  brush.line(14, -16, 66, -58); brush.line(16, 18, 66, 58); brush.line(10, 0, 52, 0)
  ink(1.4)
  rivet(60, -44); rivet(60, 44); rivet(46, -6); rivet(46, 6)
  brush.pop()
  // inner link (sleeve) and hinge
  const sleeve = [[-10, -13], [34, -9], [36, 9], [-10, 13]]
  mask(sleeve)
  ctx.part("tail-sleeve"); wc(COPPER, 200, 0.06, 0.4, 0.6); shape(sleeve)
  ctx.part("tail-hinge"); dot(30, 0, 4.5, SHADOW, 235); dot(29, -1, 1.6, BRASS, 255)
  ctx.part("tail-sleeve-ink")
  ink(1); brush.line(-8, -13, 34, -9); brush.line(36, 9, -8, 13); brush.line(35, -9, 36, 9)
  ink(0.7); brush.line(14, -11, 15, 11)
  brush.pop()

  // -- dorsal fin: three plates (still) --
  const dorsal = [
    [[232, 126], [262, 82], [286, 92], [280, 124]],
    [[206, 128], [226, 78], [256, 86], [246, 126]],
    [[180, 132], [190, 88], [222, 84], [220, 128]],
  ]
  dorsal.forEach((p, i) => {
    mask(p)
    ctx.part("dorsal" + i); wc([COPPER, VERD, BRASS_D][i], 165, 0.08, 0.5, 0.6); shape(p)
  })
  ctx.part("dorsal-ink")
  ink(0.9)
  for (const p of dorsal) { brush.line(p[0][0], p[0][1], p[1][0], p[1][1]); brush.line(p[1][0], p[1][1], p[2][0], p[2][1]); brush.line(p[2][0], p[2][1], p[3][0], p[3][1]) }

  // -- vent: a pipe on the back, drawn around its base --
  const VP = [318, 134]
  brush.push()
  brush.translate(VP[0], VP[1]); brush.rotate(12)
  const pipe = [[-8, 8], [-8, -26], [8, -26], [8, 8]]
  const cap = [[-12, -26], [-11, -36], [11, -36], [12, -26]]
  mask(pipe); mask(cap)
  ctx.part("vent-pipe"); wc(COPPER, 200, 0.05, 0.4, 0.6); shape(pipe)
  ctx.part("vent-cap"); wc(BRASS_D, 200, 0.05, 0.4, 0.6); shape(cap)
  ctx.part("vent-sh"); wc(SHADOW, 150, 0.05, 0.3, 0.3); shape([[1, 8], [1, -36], [11, -36], [12, -26], [8, -26], [8, 8]])
  ctx.part("vent-ink")
  ink(1); brush.line(-8, 6, -8, -26); brush.line(8, 6, 8, -26)
  brush.line(-12, -26, 12, -26); brush.line(-12, -26, -11, -36); brush.line(12, -26, 11, -36); brush.line(-11, -36, 11, -36)
  ink(0.7); brush.line(-8, -10, 8, -10)
  brush.pop()

  // -- ventral fin behind the body --
  const ventral = [[268, 262], [300, 300], [318, 292], [300, 256]]
  mask(ventral)
  ctx.part("ventral"); wc(COPPER, 170, 0.08, 0.5, 0.6); shape(ventral)
  ctx.part("ventral-sh"); wc(SHADOW, 140, 0.1, 0.3, 0.3); shape(ventral)
  ctx.part("ventral-ink"); ink(0.9); brush.line(268, 264, 300, 300); brush.line(300, 300, 318, 292); brush.line(318, 292, 302, 258)

  // -- body --
  const body = [[72, 202], [92, 172], [135, 145], [200, 124], [270, 120], [330, 134], [372, 168], [388, 195],
                [372, 222], [330, 252], [265, 270], [195, 270], [135, 252], [92, 228]]
  mask(body, 0.6)
  ctx.part("body-base")
  wc(BRASS, 95, 0.05, 0.35, 0.5); shape(body, 0.6)
  ctx.part("body-mid")
  wc(BRASS_D, 150, 0.2, 0.5, 0.2)
  shape([[98, 206], [150, 176], [230, 158], [320, 158], [376, 178], [388, 195], [372, 222], [330, 252],
         [265, 270], [195, 270], [135, 252], [94, 228]], 0.6)
  ctx.part("body-copper")
  wc(COPPER, 165, 0.1, 0.5, 0.5)
  shape([[322, 132], [348, 146], [372, 168], [388, 195], [372, 222], [340, 247], [318, 256], [330, 195]], 0.4)
  ctx.part("head-copper")
  wc(COPPER, 110, 0.15, 0.5, 0.4)
  shape([[76, 206], [110, 200], [150, 214], [166, 262], [135, 252], [92, 228]], 0.5)
  ctx.part("body-shadow")
  wc(SHADOW, 150, 0.2, 0.4, 0.2)
  shape([[100, 234], [140, 238], [200, 250], [270, 248], [335, 232], [384, 200], [372, 222], [330, 252],
         [265, 270], [195, 270], [135, 252]], 0.6)
  ctx.part("body-core")       // darker core toward the lower right
  wc(SHADOW, 90, 0.25, 0.4, 0.15)
  shape([[250, 262], [320, 238], [366, 205], [386, 196], [372, 222], [330, 252], [265, 270]], 0.6)
  ctx.part("body-belly2")     // second cool glaze: the belly line and the lower right
  wc(SHADOW, 120, 0.2, 0.4, 0.2)
  shape([[150, 252], [200, 262], [268, 262], [330, 244], [378, 212], [372, 222], [330, 252], [265, 270], [195, 270]], 0.6)
  ctx.part("verd1"); wc(VERD, 170, 0.3, 0.6, 0.4); brush.circle(196, 252, 11, 0.4)
  ctx.part("verd2"); wc(VERD, 170, 0.3, 0.6, 0.4); brush.circle(352, 160, 9, 0.4)
  ctx.part("verd3"); wc(VERD, 160, 0.3, 0.6, 0.4); brush.circle(176, 150, 7, 0.4)
  ctx.part("verd4"); wc(VERD, 170, 0.3, 0.6, 0.4); brush.circle(336, 240, 8, 0.4)
  brush.noFill()

  // -- gear recess: a dark window in the side --
  const GA = [248, 204], RA = 30, NA = 12
  const GB = [GA[0] + 50 * Math.cos(-25 * Math.PI / 180), GA[1] + 50 * Math.sin(-25 * Math.PI / 180)], RB = 20, NB = 8
  ctx.part("recessA"); wc(SHADOW, 240, 0.03, 0.3, 0.7); brush.circle(GA[0], GA[1], RA + 9)
  ctx.part("recessB"); wc(SHADOW, 240, 0.03, 0.3, 0.7); brush.circle(GB[0], GB[1], RB + 8)
  ctx.part("recess-ink"); ink(1); brush.circle(GA[0], GA[1], RA + 9, 0.1); brush.circle(GB[0], GB[1], RB + 8, 0.1)
  brush.noFill()

  // -- gears: each drawn around its own centre; identical teeth share one seed so a turn of
  //    one tooth pitch (or one hole pitch) maps the gear onto itself --
  const gear = (name, c, R, N, holes, color, angle) => {
    const pitch = 360 / N, ro = R + 4, rr = R - 3
    const hw = 0.23 * pitch * Math.PI / 180
    const pol = (r, a) => [r * Math.cos(a), r * Math.sin(a)]
    const tooth = [pol(rr - 2, -hw * 1.5), pol(ro, -hw * 0.8), pol(ro, hw * 0.8), pol(rr - 2, hw * 1.5)]
    brush.push()
    brush.translate(c[0], c[1])
    // paper mask: disc and teeth
    mask(circPts(0, 0, rr))
    for (let k = 0; k < N; k++) { brush.push(); brush.rotate(angle + k * pitch); mask(tooth); brush.pop() }
    // disc: round, so it does not need to turn
    ctx.part(name + "-disc"); wc(color, 170, 0.02, 0.4, 0.5); brush.circle(0, 0, rr)
    for (let k = 0; k < N; k++) {
      brush.push(); brush.rotate(angle + k * pitch)
      ctx.part(name + "-tooth"); wc(color, 190, 0.02, 0.3, 0.5); shape(tooth)
      ctx.part(name + "-tooth-ink"); ink(0.8)
      brush.line(tooth[0][0], tooth[0][1], tooth[1][0], tooth[1][1]); brush.line(tooth[1][0], tooth[1][1], tooth[2][0], tooth[2][1])
      brush.line(tooth[2][0], tooth[2][1], tooth[3][0], tooth[3][1])
      brush.pop()
    }
    const hp = 360 / holes
    for (let k = 0; k < holes; k++) {
      brush.push(); brush.rotate(angle + k * hp + hp / 2)
      ctx.part(name + "-hole"); dot(R * 0.5, 0, R * 0.2, SHADOW, 235)
      ctx.part(name + "-hole-ink"); ink(0.7); brush.arc(R * 0.5, 0, R * 0.2, 150, 330)
      brush.pop()
    }
    // lower-right shade and hub (round: still)
    ctx.part(name + "-shade"); wc(SHADOW, 95, 0.05, 0.3, 0.2)
    shape(circPts(0, 0, rr).filter(p => p[0] + p[1] > -2))
    ctx.part(name + "-hub"); dot(0, 0, R * 0.15)
    ctx.part(name + "-ring"); ink(0.7); brush.circle(0, 0, rr - 2, 0.05)
    brush.noFill()
    brush.pop()
  }
  const dir = -25
  gear("gearA", GA, RA, NA, 3, BRASS, dir + turn * 120)
  gear("gearB", GB, RB, NB, 4, COPPER, dir + 180 + 180 / NB - turn * 180)

  // -- porthole eye --
  const E = [122, 188]
  ctx.part("eye-rim"); wc(COPPER, 210, 0.03, 0.4, 0.7); brush.circle(E[0], E[1], 19)
  mask(circPts(E[0], E[1], 12.5))
  ctx.part("eye-glass"); wc(SEA, 150, 0.02, 0.3, 0.6); brush.circle(E[0], E[1], 12)
  ctx.part("eye-glass-sh"); wc(SHADOW, 170, 0.05, 0.3, 0.3); shape(circPts(E[0], E[1], 12).filter(p => p[0] - E[0] + p[1] - E[1] > -4))
  ctx.part("eye-pupil"); dot(E[0] - 1, E[1] + 1, 5.5)
  mask(circPts(E[0] - 4, E[1] - 3, 2, 10))
  ctx.part("eye-ink")
  ink(1.1); brush.circle(E[0], E[1], 19, 0.08); brush.circle(E[0], E[1], 12.5, 0.05)
  ink(1.4)
  for (let k = 0; k < 8; k++) rivet(E[0] + 15.7 * Math.cos(TAU * k / 8 + 0.4), E[1] + 15.7 * Math.sin(TAU * k / 8 + 0.4))

  // -- pectoral fin over the body --
  const pect = [[[176, 226], [222, 262], [214, 284], [182, 262]], [[170, 228], [196, 284], [176, 298], [160, 258]]]
  pect.forEach((p, i) => {
    mask(p)
    ctx.part("pect" + i); wc([VERD, COPPER][i], 185, 0.06, 0.5, 0.6); shape(p)
  })
  ctx.part("pect-sh"); wc(SHADOW, 110, 0.1, 0.3, 0.2); shape([[182, 262], [222, 262], [214, 284], [196, 284], [176, 298], [170, 270]])
  ctx.part("pect-ink")
  ink(0.9)
  for (const p of pect) for (let k = 0; k < 4; k++) brush.line(p[k][0], p[k][1], p[(k + 1) % 4][0], p[(k + 1) % 4][1])
  ink(1.4); rivet(175, 232)

  // -- ink: outline, seams, rivets --
  ctx.part("body-ink")
  ink(1.1)
  // belly and back: heavier below (shadow side), broken on the lit top
  brush.spline([[72, 202, 1], [92, 228, 1], [135, 252, 1.1], [195, 270, 1.2], [265, 270, 1.2], [330, 252, 1.1], [372, 222, 1], [388, 195, 1]], 0.6)
  ink(0.7)
  brush.spline([[72, 202], [92, 172], [135, 145], [176, 130]], 0.6)
  brush.spline([[288, 122], [330, 134], [372, 168], [388, 195]], 0.6)
  // mouth
  ink(1); brush.spline([[73, 207], [88, 213], [104, 211]], 0.5)
  // gill seam and plate seams
  ink(0.8)
  brush.spline([[168, 134], [182, 170], [184, 215], [168, 262]], 0.6)
  brush.spline([[322, 132], [334, 165], [334, 215], [318, 256]], 0.6)
  brush.spline([[186, 162], [226, 154], [262, 151]], 0.5)
  ink(1.5)
  for (const [x, y] of [[176, 150], [186, 172], [189, 196], [186, 220], [178, 244],
                        [328, 148], [339, 172], [340, 196], [337, 220], [328, 242],
                        [208, 152], [236, 147], [264, 146], [292, 148], [356, 190], [356, 206]]) rivet(x, y)
  brush.pop()

  // ---- steam: puffs leave the vent, rise, drift, grow and fade ----
  ctx.part("steam", ctx.frame)
  const vx = VP[0] + 36 * Math.sin(12 * Math.PI / 180), vy = VP[1] - 36 * Math.cos(12 * Math.PI / 180) + bob
  const PUFFS = 4
  for (let i = 0; i < PUFFS; i++) {
    const u = (steamT + i / PUFFS) % 1            // age 0..1
    const x = vx + 34 * u * u + 5 * Math.sin(TAU * (u + i * 0.3))
    const y = vy - 2 - 80 * u
    const r = 4 + 15 * Math.sqrt(u)
    const op = 125 * (1 - u) * Math.min(1, u * 8 + 0.5)
    wc(SHADOW, op, 0.3, 0.5, 0.25)
    brush.circle(x, y, r, 0.5)
    wc(SHADOW, op * 0.6, 0.3, 0.5, 0.2)
    brush.circle(x + r * 0.6, y + r * 0.2, r * 0.6, 0.5)
  }
  brush.noFill()
  void s1
}
