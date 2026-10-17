// Draws two patches of open, flowing contour lines (contour-a.svg and
// contour-b.svg, written next to this file). They are used as a CSS mask, so
// the lines take whatever colour the page gives them. Change the seeds, sizes
// or level counts at the bottom for a different patch:
//   node draw-contours.mjs
import { writeFileSync } from 'node:fs';

const CELL = 8;

function rng(seed) {
  let a = seed >>> 0;
  return () => {
    a = (a + 0x6d2b79f5) >>> 0;
    let t = a;
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

/** A long slope with ripples running over it: its contours cross the patch
    side to side like a current, and do not close into rings. */
function terrain(seed, w, h) {
  const r = rng(seed);
  const dir = r() * Math.PI;
  const cx = Math.cos(dir);
  const cy = Math.sin(dir);
  const waves = Array.from({ length: 9 }, (_, k) => {
    const f = 0.8 + k * 0.75 + r() * 0.5;
    const t = r() * Math.PI * 2;
    return { fx: (f * Math.cos(t)) / w, fy: (f * Math.sin(t)) / w, p: r() * 6.28, a: 0.11 / (1 + k * 0.8) };
  });
  return (x, y) => {
    // Bend the ground a little first, so the lines drift instead of running straight.
    const bx = x + 0.06 * w * Math.sin((6.28 * 1.3 * y) / h + 1.7);
    const by = y + 0.06 * h * Math.sin((6.28 * 0.9 * x) / w + 0.4);
    let v = (bx * cx + by * cy) / w;
    for (const s of waves) v += s.a * Math.sin(6.28 * (s.fx * bx + s.fy * by) + s.p);
    return v;
  };
}
/** Marching squares: the lines along which the field equals `level`. */
function trace(field, nx, ny, level) {
  const at = (i, j) => field[j * (nx + 1) + i];
  const points = new Map();
  const links = new Map();
  const mix = (a, b) => (level - a) / (b - a);
  const edge = (kind, i, j) => {
    const key = `${kind}${i},${j}`;
    if (!points.has(key)) {
      points.set(key, kind === 'h' ? [(i + mix(at(i, j), at(i + 1, j))) * CELL, j * CELL] : [i * CELL, (j + mix(at(i, j), at(i, j + 1))) * CELL]);
    }
    return key;
  };
  const join = (a, b) => {
    (links.get(a) ?? links.set(a, []).get(a)).push(b);
    (links.get(b) ?? links.set(b, []).get(b)).push(a);
  };
  const SIDES = { 1: ['LB'], 2: ['BR'], 3: ['LR'], 4: ['TR'], 5: ['TL', 'BR'], 6: ['TB'], 7: ['TL'], 8: ['TL'], 9: ['TB'], 10: ['TR', 'LB'], 11: ['TR'], 12: ['LR'], 13: ['BR'], 14: ['LB'] };
  for (let j = 0; j < ny; j++) {
    for (let i = 0; i < nx; i++) {
      const c = (at(i, j) > level ? 8 : 0) | (at(i + 1, j) > level ? 4 : 0) | (at(i + 1, j + 1) > level ? 2 : 0) | (at(i, j + 1) > level ? 1 : 0);
      const side = { T: () => edge('h', i, j), B: () => edge('h', i, j + 1), L: () => edge('v', i, j), R: () => edge('v', i + 1, j) };
      for (const pair of SIDES[c] ?? []) join(side[pair[0]](), side[pair[1]]());
    }
  }

  const seen = new Set();
  const walk = (start) => {
    const line = [start];
    seen.add(start);
    let here = start;
    for (;;) {
      const next = links.get(here).find((k) => !seen.has(k));
      if (!next) break;
      seen.add(next);
      line.push(next);
      here = next;
    }
    return line;
  };
  const lines = [];
  // Open lines first (they start at an end), then the closed rings.
  for (const [key, to] of links) if (to.length === 1 && !seen.has(key)) lines.push({ keys: walk(key), closed: false });
  for (const key of links.keys()) if (!seen.has(key)) lines.push({ keys: walk(key), closed: true });
  return lines.map((l) => ({ closed: l.closed, pts: l.keys.map((k) => points.get(k)) }));
}

const n = (v) => String(Math.round(v * 10) / 10);

/** A smooth path through the midpoints, each traced point pulling the curve. */
function path({ pts, closed }) {
  // Rings and scraps are left out: only the long open lines are drawn.
  if (closed || pts.length < 24) return '';
  const mid = (a, b) => [(a[0] + b[0]) / 2, (a[1] + b[1]) / 2];
  if (closed) {
    const first = mid(pts[pts.length - 1], pts[0]);
    let d = `M${n(first[0])} ${n(first[1])}`;
    for (let k = 0; k < pts.length; k++) {
      const m = mid(pts[k], pts[(k + 1) % pts.length]);
      d += `Q${n(pts[k][0])} ${n(pts[k][1])} ${n(m[0])} ${n(m[1])}`;
    }
    return d + 'Z';
  }
  let d = `M${n(pts[0][0])} ${n(pts[0][1])}`;
  for (let k = 1; k < pts.length - 1; k++) {
    const m = mid(pts[k], pts[k + 1]);
    d += `Q${n(pts[k][0])} ${n(pts[k][1])} ${n(m[0])} ${n(m[1])}`;
  }
  const last = pts[pts.length - 1];
  return d + `L${n(last[0])} ${n(last[1])}`;
}

function draw(file, { seed, w, h, levels }) {
  const nx = w / CELL;
  const ny = h / CELL;
  const f = terrain(seed, w, h);
  const field = new Float64Array((nx + 1) * (ny + 1));
  let top = -Infinity;
  let bottom = Infinity;
  for (let j = 0; j <= ny; j++) {
    for (let i = 0; i <= nx; i++) {
      const v = f(i * CELL, j * CELL);
      field[j * (nx + 1) + i] = v;
      top = Math.max(top, v);
      bottom = Math.min(bottom, v);
    }
  }
  let thin = '';
  let index = '';
  for (let k = 1; k <= levels; k++) {
    const level = bottom + ((top - bottom) * k) / (levels + 1);
    const d = trace(field, nx, ny, level).map(path).join('');
    // Every fifth line is an index contour, drawn a little heavier.
    if (k % 5 === 0) index += d;
    else thin += d;
  }
  // The patch thins out to nothing towards its edge, so it has no outline.
  const svg =
    `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${w} ${h}" fill="none" stroke="#000">` +
    `<defs><radialGradient id="f"><stop offset=".35" stop-color="#fff"/><stop offset="1" stop-color="#000"/></radialGradient>` +
    `<mask id="m"><rect width="${w}" height="${h}" fill="url(#f)"/></mask></defs>` +
    `<g mask="url(#m)"><path stroke-width="1" d="${thin}"/><path stroke-width="1.6" d="${index}"/></g></svg>\n`;
  writeFileSync(new URL(`./${file}`, import.meta.url), svg);
  console.log(file, `${(svg.length / 1024).toFixed(1)} KB`);
}

draw('contour-a.svg', { seed: 20261013, w: 960, h: 720, levels: 26 });
draw('contour-b.svg', { seed: 7741, w: 800, h: 800, levels: 22 });
