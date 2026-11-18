// Brief: <subject, size, view, palette mood, use>
export const meta = { w: 512, h: 512, seed: 1, paper: "#f4efe2" }

export default function draw(brush, W, H) {
  // 1. Light washes first, large shapes.
  brush.noStroke()
  brush.fill("#7fa7c9", 90)
  brush.fillBleed(0.2)
  brush.fillTexture(0.4, 0.5)
  brush.rect(0, 0, W, H * 0.6)
  brush.noFill()

  // 2. Darker shapes, then 3. line work and details on top.
  brush.set("HB", "#2b2233", 1)
  brush.spline([[W * 0.2, H * 0.7], [W * 0.5, H * 0.62], [W * 0.8, H * 0.72]], 0.5)
}
